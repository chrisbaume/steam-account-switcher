$port = "8080"
$userList = @("user1", "user2")

# Clean up old instances
if ($global:listener) {
    try {
        if ($global:listener.IsListening) {
            $global:listener.Stop()
        }
        $global:listener.Close()
        Write-Host "Closed existing listener."
    }
    catch {
        # Ignore errors during cleanup
    }
}

$global:listener = New-Object System.Net.HttpListener
$global:listener.Prefixes.Add("http://+:$port/")

try {
    $global:listener.Start()
    Write-Host "Server started. Listening on http://+:$port/..."

    while ($global:listener.IsListening) {
        try {
            $context = $global:listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            $response.ContentType = "text/html"
            $username = $request.QueryString.Get("username")
            $shutdown = $request.QueryString.Get("shutdown")

            $html = "<!DOCTYPE html><html><head>"
            $html += "<title>Steam account switcher</title>"
            $html += "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
            $html += "</head><body>"

            if ($shutdown -eq "true") {
                Write-Host "Shutting down computer"
                Start-Process "C:\Windows\System32\shutdown.exe"
                $html += "<h1>Success</h1><p>Shutting down computer</p>"
            } elseif ($username) {
                Write-Host "Switching to user: $username"

                Start-Process "C:\Program Files (x86)\Steam\steam.exe" -ArgumentList "-shutdown"
                Start-Sleep -Seconds 10
                Start-Process "C:\Program Files (x86)\Steam\steam.exe" -ArgumentList "-login $username"

                $html += "<h1>Success</h1><p>Switching to $username</p><a href='/'>Back</a>"
            } else {
                $html += "<h1>Select a user</h1><ul>"
                foreach ($user in $userList) {
                    $html += "<li><a href='/?username=$user'>$user</a><br /></li>"
                }
                $html += "</ul><hr><ul><li><a href='/?shutdown=true'>Shutdown</a></li></ul>"
            }

            $html += "</body></html>"

            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
        }
        catch [System.Net.HttpListenerException] {
            if (-not $global:listener.IsListening) {
                Write-Host "Listener was stopped."
            } else {
                Write-Error $_.Exception.Message
            }
        }
    }
}
catch {
    Write-Error $_
}
finally {
    if ($global:listener) {
        if ($global:listener.IsListening) {
            $global:listener.Stop()
        }
        $global:listener.Close()
        Write-Host "Listener successfully closed and port released."
    }
}