# Using Power Automate to copy a Template Folder

When I start a project, there are usually three files that I know I'm going to need. Originally, I had template files that I would copy manually from a default folder into a new folder specifically for the project. Not a complicated process, but I only have three files. Some teams can have many files they need to copy for each new client or project! If you store your project files in SharePoint, you can take advantage of this Power Automate Instant Flow to automate your project kick-off.

The first step in creating this automation is to create a template folder in SharePoint containing all the default files you need to kick-off your project. You can store it in the same place as you want to store the project files or you can store it somewhere else. Here's mine as an example:

![View of template folder to be copied](template-folder.png)

Once you have this folder setup, you can begin creating the Power Automate Instant Flow. The trigger is the "For a selected file" SharePoint block. This will add this flow to the SharePoint document library menu so you can trigger it from the SharePoint site itself. In the trigger block, you can also add a field so you can enter the name of the client or the project to be added the new folder.

Once the trigger is setup, you can begin adding the following blocks to build the automation flow:

1. Create new folder - This block creates a new folder using the client/project name in the document library for project files.
2. List folder - This block lists all the files and sub-folders in a folder. It doesn't go into the sub-folders though. If you have sub-folders, you'll need to repeat this block for each of those to get all the files.
3. Copy File - For each file in the folder create a new copy of the file in the new client/project folder. You can choose to keep the same name as the original file or you can give it a new name that includes the client or project name.

Here's what the automation looks like in the Flow Designer:

![View of automation in Flow Designer](Flow.png)

This is a small automation that you can get up and running quickly. It's also a great way to get started with Power Automate and see what other automation options it has for you.