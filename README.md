
cd list tool:  This tool allows you save the names of your most-often-visited directories in a file/list.  Then you can select them from a list to cd to them.

Advantages:

1. Similar to the popd/pushd mechanism but cdl displays the directory names in a vertical list rather than one long line-wrapping list.
2. You select an entry using a very short ID number.  Saves on typing and remembering.
3. You don't lose your saved directory names if you exit your shell as with pushd/popd because the directory names are saved in a file.

Uses/Features:

1. Keep track of what you're working on if you are working on multiple projects.
2. Find out what a coworker is working on and where in the file system.
3. If a directory in the list does not exist, cdl will display a warning.
4. If you use cdl to cd to a directory that contains a .cdl_execute script, cdl will execute this script after changing to the new directory.  One example use:  cdl to a directory containing many hundreds of logfiles and you want to see the newest logfile.  So put the following command into file .cdl_execute in your logfile directory:   ls -ltr


