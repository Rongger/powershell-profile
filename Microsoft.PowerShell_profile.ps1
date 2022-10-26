Set-Alias cmd-history Get-Cmd-History
Set-Alias chrome-cors Open-Chrome-No-Cors

function Set-Wsl-Netsh {
    param (
        $Port
    )
    $Wsl_Ip = wsl -- ip -o -4 -json addr list eth0 `
    | ConvertFrom-Json `
    | ForEach-Object { $_.addr_info.local } `
    | Where-Object { $_ }

    Write-Output "Wsl Ip: $Wsl_Ip"
    sudo netsh interface portproxy add v4tov4 listenport=$Port connectaddress=$Wsl_Ip connectport=$Port listenaddress=* protocol=tcp
    Write-Output "Port($Port) now is out!"
}

function Remove-Wsl-Netsh {
    param (
        $Port
    )
    sudo netsh interface portproxy delete v4tov4 listenport=$Port protocol=tcp
    Write-Output "Port($Port) now is not out!"
}

function Set-FW-Port {
    param (
        $Port
    )
    $Port4WSL = "Port4WSL-" + $Port
    $NetFirewallRule = Get-NetFirewallRule
    if (-not $NetFirewallRule.DisplayName.Contains($Port4WSL)) {
        # sudo Remove-NetFireWallRule -DisplayName $Port4WSL
        sudo New-NetFireWallRule -DisplayName $Port4WSL -Direction Outbound -LocalPort $Port -Action Allow -Protocol TCP
        sudo New-NetFireWallRule -DisplayName $Port4WSL -Direction Inbound -LocalPort $Port -Action Allow -Protocol TCP
        Write-Output "New rule for WSL(Port: $Port)!"
    }
    else {
        Write-Output "Rule for WSL(Port: $Port) exists!"
    }
}

function Remove-FW-Port {
    param (
        $Port
    )
    $Port4WSL = "Port4WSL-" + $Port
    $NetFirewallRule = Get-NetFirewallRule
    if (-not $NetFirewallRule.DisplayName.Contains($Port4WSL)) {
        Write-Output "Rule for WSL(Port: $Port) not exists!"
    }
    else {
        sudo Remove-NetFireWallRule -DisplayName $Port4WSL
        Write-Output "Rule for WSL(Port: $Port) removed!"
    }
}

function Get-Cmd-History {
    Get-Content (Get-PSReadlineOption).HistorySavePath
}

function Open-Chrome-No-Cors {
    Set-Location -Path "C:\Program Files (x86)\Google\Chrome\Application"
    ./chrome.exe  --disable-site-isolation-trials --disable-web-security --user-data-dir="E:\temp"
}
