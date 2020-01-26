# packet-block-storage-windows

`packet-block-stroage-windows` is a PowerShell script that automates the process of connecting / disconnecting Packet Block Storage volumes to your windows instance. It does not partition and format the volumes so you will have to manually do that after the script connects the iSCSI block storage volumes. If you need help on partitioning / formatting the volumes, the process is covered at the end of the GUI guide [here](https://www.packet.com/resources/guides/elastic-block-storage-windows-server/), under the "Partitioning and Mounting the Volume" section. 

## Downloading the script to your server instance

This script must be run from within a Packet windows server instance. There are many ways to get the script into your instance but for a fresh instance, we're using a more manual method with Internet Explorer.

To do this, navigate to the [raw script source](https://raw.githubusercontent.com/enkelprifti98/packet-block-storage-windows/master/packet-block-storage-windows.ps1) in your browser of choice within the Packet server instance, we are using Internet explorer since it is built in to Windows Server.

Internet Explorer will prompt you that you're visiting a secure site so you can click "OK". Once the page loads, you will notice all the code that makes up the attach script. Simply select the whole text of the page (CTRL + A) and copy it to your clipboard (CTRL + C).

Now launch the PowerShell Integrated Scripting Environment (ISE) by opening the start menu, start typing "ise" or "powershell ise" and run the "Windows Powershell ISE" application.

You may need to click on the arrow button near the top right of the application to show the script editor.

![script-editor-button](/images/script-editor-button.png)

On the script editor, paste the code that we copied earlier (CTRL + V) and save the script as a `.ps1` file. The file can be saved in any location but I'm using the Desktop folder. You can give it any name but for this example I'm naming it `packet-block-storage-windows`. On the "save as type" list, select `PowerShell Scripts (*.ps1)` and then click save.

![download-script](/images/download-script.png)

## Installing prerequisites (iSCSI + Multipath (MPIO) support)

Now you need to copy the path of the script, you can do it by holding the `shift` button and right clicking the script file, and click on "Copy as path".

Now launch PowerShell as an Administrator (this is required) by opening the start menu, type "powershell" and right click on the "Windows PowerShell" application result, click "Run as Administrator".

On the PowerShell window, type `powershell.exe "C:\path\to\your\script.ps1"` where the path will be the one we copied earlier. In my case the command would be `powershell.exe "C:\Users\Admin\Desktop\packet-block-storage-windows.ps1"`. Press Enter once you've typed the command to run the script.

**Note:** The PowerShell version on Windows Server 2012 R2 does not seem to accept pasting text as usual with CTRL + V. You can either right click on the PowerShell window to paste copied text or click on the top left corner of the window, select edit, and click paste.

![run-script](/images/run-script.png)

The script will then start installing the necessary features required for block storage and require you to restart the server instance. Once you're back in the server after the reboot, run the script again as done earlier, it will require one more reboot. The script will output a block of red text, don't worry, this is normal as it is checking if the iSCSI feature is enabled which it isn't on a fresh instance. These reboots are only done on a fresh instance, you won't have to reboot again after doing this step even when you run the script again later on to re-attach your volumes or attach new ones.

## Attaching block storage volumes

After the second reboot, run the script again but this time you need to pass `-attach` as an argument/parameter. If you don't pass the argument, the script will let you know that you did not pass one and show the available arguments that you can pass. The command should be ran as follows:

`powershell.exe "C:\Users\Admin\Desktop\packet-block-storage-windows.ps1" -attach`

Once you press enter, it will prompt you on whether you want to attach each volume one by one. Once it has completed, you can manage your connected volumes in Disk Management to bring your volumes online or partition and format them if they're new.

**Note:** Please note that your connected volumes will not be persistent across reboots in Windows so you will need to run the attach script again to connect your block storage volumes.

## Detaching block storage volumes

To detach your volumes, you can follow the same process as we did for attaching the volumes but you will need to pass the `-detach` argument instead. Before running the detach script, make sure that you have brought your volume "offline" in Disk Management to prevent any issues later. Run the following command to detach your volumes from Windows:

`powershell.exe "C:\Users\Admin\Desktop\packet-block-storage-windows.ps1" -detach`

The script will prompt you to confirm the disconnection of each connected volume one by one. Once it is done, you will still need to detach the volume from the Packet portal or API if you want to detach it completely from the server instance.
