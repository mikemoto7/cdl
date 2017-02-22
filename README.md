# cdl
cd List Tool

Bash shell script function.  Allows you to save Linux directory paths so that you can cd back to them later.  Similar in idea to push and pop.  But offers many more features:

- Saves you having to type long directory paths.
- Keeps track of the saved directory paths using a file so you're less likely to lose your list.
- Using a file also means that you'll be able to backup your list.
- Saving directory paths is a great way of remembering what you are working on if you are working on multiple things at the same time.
- Also good for locating where coworkers and collaborators are working on things you need to access.
- cdl displays an interactive text-based list.  Each directory path entry has a unique identification integer that you'll type in to select the entry.
- You can also select a directory path entry directly using the cdl command, e.g., "cdl 8" .
- The interactive list will tell you if a directory path is not accessible anymore, e.g., the directory was renamed or moved or not NFS-mounted.
- You can create a .cdl_execute script in a directory.  If you use cdl to cd to a directory that contains a .cdl_execute script, after cd'ing, cdl will automatically source execute the .cdl_execute script.  This is useful if you want to have specialized aliases, shell vars, or shell functions instantiated for the directory.  Or maybe the directory has a large number of log files and the first thing you want to see when you cdl to the directory is an ls of the most recent updated logfile-- "ls -ltr" .

To try it out:
. ~/cdl_function.sh

To install:
Add this dot invocation to your .bashrc script:
. ~/cdl_function.sh
Then re-source your .bashrc script.

Type:  cdl -h
for a help screen.
