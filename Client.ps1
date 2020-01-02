function Power-Client
{
    [CmdletBinding()]
    Param (
        [Parameter()]
        [Alias('c')]
        [string]$RemoteComputer,

        [Parameter()]
        [Alias('p')]
        [int]$port
    )

    $Tcpclient = New-Object System.Net.Sockets.TcpClient
    $Tcpclient.Connect($RemoteComputer, $port)
    $serverip = [System.Net.IPAddress]::Parse($RemoteComputer)

    if($TCPClient.Connected){
        Write-Verbose "[**] Connection to $($serverip.IPAddressToString):$port [TCP] succeeded!"
    }
    else{
        Write-Verbose "[!!!] Connection to $($serverip.IPAddressToString):$port [TCP] Failed!" $($_.Exception.Message)
    }

    $TcpNetworkstream = $Tcpclient.GetStream()
    $Receivebuffer = New-Object Byte[] $TcpClient.ReceiveBufferSize
    $EncodingType = New-Object System.Text.ASCIIEncoding

    try {
        while ($TCPClient.Connected){
            $Read = $TcpNetworkstream.Read($Receivebuffer, 0, $Receivebuffer.Length)
            if( $Read -eq 0){break}
            else{
                [Array]$Bytesreceived += $Receivebuffer[0..($Read -1)]
                [Array]::Clear($Receivebuffer, 0, $Read)
            }

            if ($TcpNetworkstream.DataAvailable) {continue}
            else{
                write-host -NoNewline $EncodingType.GetString($Bytesreceived).TrimEnd("`r")

                $sendback = $EncodingType.GetBytes((read-host) + "`n")
                $TcpNetworkstream.Write($sendback, 0, $sendback.Length)
                $TcpNetworkstream.Flush()
                $Bytesreceived = $null
            }
        }
    }
    catch {Write-warning "`n[!!!]TCP connection is broken, exiting.."}
    try{
        if ($PSVersionTable.CLRVersion.Major -lt 4) { $Tcpclient.Close(); $TcpNetworkstream.Close()}
        else {$TcpNetworkstream.Dispose(); $Tcpclient.Dispose()}
        Write-host "`n[**] TCPClient Connected: $($Tcpclient.Connected)" -ForegroundColor Cyan
        Write-host "[**] TCPNetworkStream was closed/disposed gracefully..`n" -ForegroundColor Cyan
    }
    catch { Write-Warning "[!!!]Failed to close TCP Stream"}
}
