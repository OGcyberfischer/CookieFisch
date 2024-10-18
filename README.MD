
# Cookie Extraction and Importation Tools

This REPO provides two PowerShell tools for **extracting** cookies from a local Edge browser session and **importing** those cookies into a remote Edge browser session using the WebSocket API to interact with the Edge Developer Tools protocol.


## Overview

These two PowerShell scripts are designed to help you transfer cookies from one Edge browser session (local) to another (remote). The first tool captures the cookies from a running instance of Edge and saves them to a JSON file. The second tool loads the saved cookies and injects them into a remote Edge session.

This is useful when you need to transfer authentication cookies between environments or automate session management across different machines.

---

## Prerequisites

1. **Edge Browser**: The scripts assumes Microsoft Edge browser is installed.
2. **Local Firewall**: Edge debugging port on the local host should be open 127.0.0.1 9222 .
3. **PowerShell**: The scripts are written in PowerShell.

---

## Tool 1: Extract Cookies from Edge

The first script, `GetCookies.ps1`, captures all the cookies from a local Edge session and saves them to a JSON file (`cookies.json`), which can be transferred to another machine.

### Key Steps:
- **Step 1**: Stop any existing Edge processes.
- **Step 2**: Start Edge with the `--remote-debugging-port` option, which enables the Developer Tools protocol to expose debugging APIs.
- **Step 3**: Connect to the Developer Tools WebSocket to extract the cookies.
- **Step 4**: Save the cookies to `cookies.json`.

You can find this script under the file name `GetCookies.ps1`.

---

## Tool 2: Import Cookies into Remote Edge

The second script, `ImportCookies.ps1`, imports cookies into a remote Edge browser instance by reading them from the previously saved `cookies.json` file and using the `Network.setCookie` API.

### Key Steps:
- **Step 1**: Start the remote Edge browser with remote debugging enabled.
- **Step 2**: Load the cookies from `cookies.json`.
- **Step 3**: Connect to the WebSocket and inject each cookie using the `Network.setCookie` API.

You can find this script under the file name `ImportCookies.ps1`.

---

## Usage

### Step 1: Extract Cookies

1. Run `GetCookies.ps1` on the local machine where Edge is running.
2. The script will save the cookies to a `cookies.json` file in the current directory.

### Step 2: Transfer Cookies

1. Transfer the `cookies.json` file to the remote machine where you want to import the cookies.

### Step 3: Import Cookies

1. Run `ImportCookies.ps1` on the remote machine.
2. The cookies will be injected into the running Edge browser instance.

---

By following these steps, you can easily transfer cookies between two Edge sessions for authentication or session management purposes.
