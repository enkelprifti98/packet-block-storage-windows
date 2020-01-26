# packet-block-storage-windows

## Attaching block storage volumes

To attach your block storage volumes, you will need to download the attach script to your windows server instance. To do this, navigate to the [raw script source](https://raw.githubusercontent.com/enkelprifti98/packet-block-storage-windows/master/packet-block-storage-attach-windows.ps1) in your browser of choice, we are using Internet explorer since it is built in to Windows Server.

Internet Explorer will prompt you that you're visiting a secure site so you can click "OK". Once the page loads, you will notice all the code that makes up the attach script. Simply select the whole text of the page (CTRL + A) and copy it to your clipboard (CTRL + C).

Now launch the PowerShell Integrated Scripting Environment (ISE) by opening the start meny, start typing "ise" or "powershell ise" and run the "Windows Powershell ISE" application.

On the above section of the script editor, paste the code that we copied earlier (CTRL + V) and save the script as a `.ps1` file. The file can be save in any location but I'm using the Desktop folder. You can give it any name but for this example I'm naming it `packet-block-storage-attach`. On the "save as type" list, select `PowerShell Scripts (*.ps1)` and then click save.

![download-script](/images/download-script.png)

Now you need to copy the path of the script, you can do it by holding the `shift` button and right clicking the script file, and click on "Copy as path".

Now launch PowerShell as an Administrator (this is required) by opening the start menu, type "powershell" and right click on the PowerShell application result, click "Run as Administrator".

On the PowerShell window, type `powershell.exe "C:\path\to\your\script.ps1"` where the path will be the one we copied earlier. In my case the command would be `powershell.exe "C:\Users\Admin\Desktop\packet-block-storage-attach.ps1"`. Press Enter once you've typed the command to run the script.

![run-script](/images/run-script.png)

The script will then start installing the necessary features required for block storage and require you to restart the server instance. Once you're back in the server after the reboot, run the script again as done earlier, it will require one more reboot. These reboots are only done on a fresh instance, you won't have to reboot again after doing this step even when you run the script again later on to re-attach your volumes or attach new ones.

The script is interactive so it will prompt you on whether you want to attach each volume one by one. Once it has completed, you can manage your connected volumes in Disk Management to bring your volumes online or partition them if they're new.

**Note:** Please note that your connected volumes will not be persistent across reboots in Windows so you will need to run the attach script again to connect your block storage volumes.

## Detaching block storage volumes

To detach your volumes, you can follow the same process as we did for attaching the volumes but you will need to use this [script source](https://raw.githubusercontent.com/enkelprifti98/packet-block-storage-windows/master/packet-block-storage-detach-windows.ps1) instead. Before running the detach script, make sure that you have brought your volume "offline" in Disk Management to prevent any issues later.
