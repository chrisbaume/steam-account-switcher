# Steam Account Switcher

A simple PowerShell-based HTTP server that allows you to switch between Steam accounts and shut down your Windows PC remotely via any web browser on your local network.

This is particularly useful for couch-gaming setups (such as a PC connected to a TV) or handheld setups where switching accounts or turning off the system using a physical keyboard and mouse is inconvenient.

## Why This Exists

Steam natively supports multiple accounts, which can be used for family sharing. When connecting remotly via Steam Link, you cannot change accounts as the connection is lost in the process. Switching accounts using remote desktop also doesn't work as the screen is locked when you disconnect. As such, switching accounts requires physical interaction with the PC.

This script offers remote account switching by hosting a lightweight web page on your local network. By accessing this page from another device (such as a smartphone, tablet, or another computer), you can relaunch Steam and automatically log into a specified account, and remotely shut down the host PC.

## How It Works

The script uses Windows' built-in `System.Net.HttpListener` to host a basic HTTP server on a specified port (default is `8080`). When you select a user, the script executes Steam with the `-shutdown` flag, pauses to allow Steam to close gracefully, and then launches Steam with the `-login <username>` flag to sign in as the selected user.

## Configuration

Before setting up the script to run automatically, you need to configure the script.

1.  **Download the script:**

    Save `server.ps1` to a permanent folder on your computer (for example, `C:\Scripts\SteamSwitcher\server.ps1`).
2.  **Edit the Configuration:**
    
    Open `server.ps1` in a text editor and modify the following variables at the top of the file:
    *   `$port`: Change this if you prefer a port other than `8080`.
    *   `$userList`: Update the array with your actual Steam account usernames.
        ```powershell
        $userList = @("your_steam_username_1", "your_steam_username_2")
        ```
3.  **Default Steam Path:**
    
    The script assumes Steam is installed at `C:\Program Files (x86)\Steam\steam.exe`. If your Steam installation is in a different directory, update the paths in the script accordingly.
4.  **Allow Port Binding:**
    
    Open the command prompt as an administrator and run:
    `netsh http add urlacl url=http://+:8080/ user="BUILTIN\Users"`
5.  **Add Firewall Rule:**
    
    Open Windows Defender Firewall and add a rule to allow traffic on port `8080` (or your chosen port).

## Run on Startup

To make the script run silently in the background when your PC starts up and you log in, Windows Task Scheduler is the recommended approach. 

1.  Press the `Windows Key`, type **Task Scheduler**, and press **Enter**.
2.  In the right-hand actions pane, click **Create Task...** (do not use *Create Basic Task*).
3.  **General Tab:**
    *   **Name:** `Steam Account Switcher`
    *   **Description:** Starts the lightweight HTTP server to switch Steam accounts on login.
    *   Select **Run only when user is logged on** (this ensures the Steam GUI launches in your active desktop session rather than in the background).
    *   **Configure for:** Set this to your current operating system (e.g., Windows 10 or Windows 11) rather than the older default configurations. 
4.  **Triggers Tab:**
    *   Click **New...**
    *   Set *Begin the task* to **At log on**.
    *   Set *Settings* to **Any user** (or select your specific user account).
    *   Click **OK**.
5.  **Actions Tab:**
    *   Click **New...**
    *   Set *Action* to **Start a program**.
    *   In the **Program/script** field, type:
        ```text
        powershell.exe
        ```
    *   In the **Add arguments (optional)** field, enter the following (adjust the path to match where you saved your script):
        ```text
        -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Scripts\SteamSwitcher\server.ps1"
        ```
    *   Click **OK**.
6.  **Conditions Tab:**
    *   Uncheck **Start the task only if the computer is on AC power** (useful for gaming laptops).
7.  **Settings Tab:**
    *   Uncheck **Stop the task if it runs longer than**. (We want this script to run indefinitely).
8.  Click **OK** to save the task.

The script will now start silently in the background every time you log into your Windows account.

## Usage

To access the switcher panel from any device on your local network:

1.  Find your host PC's local IP address (e.g., `192.168.1.50`).
2.  Open a web browser on your phone, tablet, or another device.
3.  Navigate to `http://<your-pc-ip>:8080/` (replace `8080` if you configured a different port).
4.  Tap on a username to switch accounts, or tap **Shutdown** to turn off the PC.

## Security
Please now that this script does not include built-in authentication or encryption. It is intended strictly for use on a trusted home local network. Avoid exposing this port to the public internet.