Get-Process msedge | Stop-Process
# Start Edge with remote debugging port on the remote machine
Start-Process "msedge.exe" "https://google.com --remote-debugging-port=9222 --remote-allow-origins=*"

# Wait for the browser to start
Start-Sleep -Seconds 10

# Read the cookies from the JSON file
$cookiesPath = "<COOKIE FILE PATH>"

if (Test-Path $cookiesPath) {
    $cookies = Get-Content $cookiesPath | ConvertFrom-Json
    Write-Host "Cookies loaded successfully from $cookiesPath"
} else {
    Write-Host "Cookies file not found: $cookiesPath"
    exit
}

# Open the WebSocket connection to the remote Edge instance
try {
    $jsonResponse = Invoke-WebRequest 'http://localhost:9222/json' -UseBasicParsing
    $devToolsPages = ConvertFrom-Json $jsonResponse.Content
    $ws_url = $devToolsPages[0].webSocketDebuggerUrl
    Write-Host "WebSocket URL: $ws_url"

    $ws = New-Object System.Net.WebSockets.ClientWebSocket
    $uri = New-Object System.Uri($ws_url)
    $ws.ConnectAsync($uri, [System.Threading.CancellationToken]::None).Wait()
    Write-Host "Connected to WebSocket."
} catch {
    Write-Host "Error connecting to WebSocket: $_"
    exit
}

# Send Network.setCookies command to set all cookies
foreach ($cookie in $cookies) {
    $cookieData = @{
        "name"       = $cookie.name
        "value"      = $cookie.value
        "domain"     = $cookie.domain
        "path"       = $cookie.path
        "secure"     = $cookie.secure
        "httpOnly"   = $cookie.httpOnly
        "expires"    = $cookie.expires
    }

    # Construct the WebSocket message for Network.setCookies
    $setCookieCommand = @{
        "id"      = 1
        "method"  = "Network.setCookie"
        "params"  = $cookieData
    } | ConvertTo-Json -Compress

    Write-Host "Setting cookie via WebSocket: $setCookieCommand"

    # Send the cookie command to the browser
    try {
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($setCookieCommand)
        $segment = New-Object System.ArraySegment[byte] -ArgumentList $buffer, 0, $buffer.Length
        $ws.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, [System.Threading.CancellationToken]::None).Wait()

        # Receive response and log it
        $receivedBuffer = New-Object byte[] 2048
        $receivedSegment = New-Object System.ArraySegment[byte] -ArgumentList $receivedBuffer, 0, $receivedBuffer.Length
        $result = $ws.ReceiveAsync($receivedSegment, [System.Threading.CancellationToken]::None).Result
        $receivedString = [System.Text.Encoding]::UTF8.GetString($receivedSegment.Array, $receivedSegment.Offset, $result.Count)
        Write-Host "WebSocket Response: $receivedString"
    } catch {
        Write-Host "Error sending cookie set command: $_"
    }
}

# Close WebSocket connection with error handling
try {
    $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Closing", [System.Threading.CancellationToken]::None).Wait()
    Write-Host "WebSocket connection closed successfully."
} catch {
    Write-Host "Error occurred when closing WebSocket: $_"
}

Write-Host "Cookies injected into the remote Edge instance using Network.setCookies."
