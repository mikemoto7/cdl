#!/bin/bash

# Installation:
#
# To try out cdl temporarily, run:
# . this_file
# The '.' in front is REQUIRED.
# Then run:
# cdl
#
# To permanently use cdl:
# Copy this script to ~:
#    cp cdl_function.sh  ~
#    chmod +x ~/cdl_function.sh
# Then add the following line to your ~/.bashrc script 
# .  ~/cdl_function.sh
#

#-----------------------------------------------------------
# cd list mechanism.  This tool allows to you save the names of your most-often-visited
# directories in a file.  Then you can select them from a list to cd to them.
# Similar to the popd/pushd mechanism but this one displays the directory names in a vertical
# list rather than one long line-wrapping list.  And you don't lose your saved directory names
# if you exit your shell as with pushd/popd because the directory names are saved in a file.
                                                                                
# This is the file that will contain your saved directory names.
if [ -n "$user_name" ]; then
   CDL_FILE=~/.cdlist_${user_name}
else
   CDL_FILE=~/.cdlist_`whoami`
fi
export CDL_FILE
if [ ! -f $CDL_FILE ]
then
    touch $CDL_FILE   # Create the file.
    echo "/tmp" >> $CDL_FILE   # Example entry.
    echo "/usr/tmp" >> $CDL_FILE   # Example entry.
    echo "cdl file $CDL_FILE created with example entries."
else
    # If this is an old-style cdlist file with index numbers in them, remove these numbers from CDLFILE.
    first_line=$(head -1 $CDL_FILE )
    pattern='^[1-9][0-9]* [^ ].*$'
    if [[ $first_line =~ $pattern ]]; then
       IFS=$(echo -en '\n') readarray -t cdl_array1 < $CDL_FILE
       \cp /dev/null $CDL_FILE
       for row in ${cdl_array1[@]}; do
          # echo "row: $row"
          echo $row | sed 's/^[0-9]* //' >> $CDL_FILE
       done
    else
       readarray -t cdl_array1 < $CDL_FILE
    fi
fi
# if [ ! -f $CDL_FILE -o ! -s $CDL_FILE ]; then
#    if [ -s ~/.cdlist_$LOGNAME -a ~/.cdlist_$LOGNAME != $CDL_FILE ]; then
#       \cp ~/.cdlist_$LOGNAME $CDL_FILE
#    fi
# fi

# Add command:  Add a directory to your cd list.  You must be cd'd into the directory before you call this command.
# Runstring:   cda
# alias cda='CDL_NUM=`wc -l $CDL_FILE | sed "s/^ *\([0-9]*\).*$/\1/"`; ((CDL_NUM=CDL_NUM+1)); echo "$CDL_NUM $PWD" >> $CDL_FILE'
# alias cda='pwd >> $CDL_FILE'

# List-and-select command:  Display the directory entries in your list and select one.
# Runstring:  cdl - to display the list of directories and enter your choice
#          or cdl <id_number> - to cd immediately to that directory in the list without displaying the list itself.
#
# When the list is displayed, you will be prompted to enter the id number of the directory entry
# to cd to.  If you don't want to select any of the entries, type <enter> or <ctrl-c> to exit
# the list.


function cdl_usage {
cat <<EOH

Description:
A list to remember directories you want to cd to.

Runstring:
cdl = Interactive mode:  Display directory list and command prompt.

Interactive Mode:
<number> = cd to this directory in the list.
d <number> = Delete this entry from the list.
e = Edit the list file using the editor specified by \$EDITOR.
ls <number> = Do an ls of the directory which has <number>.
l = Display directory list.
s search_string = Similar to 'cdl search_string'
q = Quit.

Non-Interactive Command-Line Commands:
cdl <number> = cd to the directory in the list which has id <number>.
cdl <number> relative_dir = cd to the directory which is relative to the directory in the list which has id <number>.
cdl dir = cd to the directory the same as a regular cd.  If 'cdl dir' is not successful, cdl will attempt to search its list for any entries that contain the 'dir' string and list those for selecting.
cdl -a  = Add current directory to the list.
cdl -a <dir> = Add <dir> to the list.
cdl -h = Display this help screen.
cdl -l = Display the list of directories.
cdl search_string = cdl will search its list for any entries that contain search_string and display those for choosing.  If cdl finds only one matching entry, it will immediately cd to that directory instead of bringing up interactive mode.  search_string can be a string of any characters including space and special characters.  If you use a space, you must enclose search_string in single or double quotes.  

Extra Features:
The list will tell you if a directory does not exist anymore.  You or someone else may have renamed it or deleted it.  Or if the directory is an NFS directory it may not be mounted.

If you cd to a directory and it has a .cdl_execute script in it, cdl will execute the script automatically.  Useful if you want to run ls after cd'ing to a particular directory.

Directory Names/Paths:
Can contain spaces.  Can contain most special characters--  %(+.@!

CDL_FILE = $CDL_FILE

EOH
# Not available yet:
# This script will automatically create shell variables of the directories in your list.  For example, "12 /foo/dir/tempdir" will have shell var:
# d12=/foo/dir/tempdir

}


function cdl_test () {

loop=1
while true; do
   cdl -t
   loop=$((loop + 1))
   echo "loop: $loop"
   sleep 1
done

}


search_matches=()

function display_list() {
   search_string=$1

   search_matches=()

   # unset cdl_array1
   # IFS=$(echo -en '\n')
   # readarray -t cdl_array1 < $CDL_FILE
   # # mapfile -t cdl_array1 < $CDL_FILE
   # readarray -t cdl_array1 <<< "$(cat $CDL_FILE)"
   # cat $CDL_FILE | readarray -t cdl_array1
   # status=$?
   count=0
   # echo "all_lines = ${cdl_array1[@]}"
   # for directoryEntry in ${cdl_array1[@]}; do
   IFS=$(echo -en '\n')

   # THIS WORKS!  No memory error.
   # cat $CDL_FILE | while read directoryEntry; do
   while read directoryEntry; do
      count=$((count + 1))

      if [ ! -d "$directoryEntry" ]; then
         printf "%d NOT_FOUND:%s\n" $count "$directoryEntry"
      else
         if [ -z "$search_string" ]; then
            echo "$count $directoryEntry"
         else
            if [ -n "$(echo $count $directoryEntry | \grep $search_string)" ]; then
               search_matches+=("$count $directoryEntry")
            fi
         fi
      fi
      # declare d$count="$directoryEntry"
   done < $CDL_FILE

   if [ ${#search_matches[@]} -gt 1 ]; then
      for entry in ${search_matches[@]}
      do
         echo $entry
      done
      search_matches=()
   fi

}


function cdl () {

if [ -z "$CDL_FILE" ]; then
   export CDL_FILE="$HOME/.cdlist"
   touch $CDL_FILE
fi

# # Convert old style to new style file format.
# if [ -n "$(head -1 $CDL_FILE | \grep '^[0-9][0-9]*')" ]; then
#    cat $CDL_FILE | sed 's/^[0-9][0-9]*[ :]*//' > ${CDL_FILE}.tmp
#    \cp ${CDL_FILE}.tmp  ${CDL_FILE}
# fi

command=$1
id_num=$1
dir_to_cd_to=$1
add_dir=$2
relative_dir=$2

# Test
testmode=false
if [ "$command" == '-t' ]; then
   testmode=true
   id_num=
fi

# Help
if [ "$command" == '-h' ]; then
   cdl_usage
   return 1
fi

## display list or directory
# display list
if [ "$command" == '-l' ]; then
   # if [ -n "$relative_dir" ]; then
   #    ls $relative_dir
   # else
      display_list
   # fi
   return 1
fi

# Add a new entry.
if [ "$command" == '-a' ]; then
   if [ -z "$add_dir" -o "$add_dir" == '.' ]; then
      add_dir=`pwd`
   else
      if [ "$(echo $add_dir | cut -c1)" != '/' ]; then
         add_dir=`pwd`/$add_dir
      fi
   fi
   result=$(\grep "^$add_dir$" $CDL_FILE)
   if [ -n "$result" ]; then
      echo "ERROR: Directory $add_dir already exists in the list."
   else
      echo $add_dir | sed 's/  */\ /g' >> $CDL_FILE
   fi
   id_num=
   return 1
fi

if [[ $command =~ -.* ]]; then
   echo "ERROR: Unrecognized command = $command"
   return 1
fi

search_string=
display_list=true
do_cd=
if [ -n "$id_num" -a -n "$(echo $id_num | \grep '^[0-9]*$')" ]; then
   do_cd="`\grep -n '.' $CDL_FILE | \grep "^$id_num:" | sed 's/^[0-9][0-9]*://'`"
elif [ -n "$dir_to_cd_to" ]; then
   search_string=$dir_to_cd_to
   do_cd=$dir_to_cd_to
   if [ ! -d "$dir_to_cd_to" ]; then
      do_cd=
   fi

# elif [ -z "$id_num" ]; then
#    echo "ERROR: Unrecognized runstring option: $id_num"
#    do_cd=
#    return 1

fi

if [ -z "$do_cd" ]; then

   while true; do
      if [ "$display_list" == 'true' ]; then
         display_list "$search_string"
         search_string=''
      fi
      if [ $testmode == 'true' ]; then
         return
      fi

      if [ ${#search_matches[@]} -eq 0 ]; then
         display_list=false
         echo -n "Enter dir, cdl command, or h for help: "
         read dirOrCommand
         # dirOrCommand=$(HISTFILE=$CDL_FILE; history -r; read -e dirOrCommand; echo "$dirOrCommand")
         # if [ -z "$dirOrCommand" ]; then
         #     break
         # fi
      else
         do_cd=`echo ${search_matches[0]} | sed 's/^[0-9]* //'`
         break
      fi

      if [ -z "$dirOrCommand" ]; then
         continue
      fi

      case $dirOrCommand in
      h)
         cdl_usage
         continue
         ;;

      q)
         break # Do NOT use exit.  You will exit out of your Bash command shell!
         ;;

      l)
         display_list=true
         continue
         ;;

      # ls' '[0-9]*)
      ls*)
         dirIndex=`echo $dirOrCommand | sed 's/^ls.* \([0-9][0-9]*\)$/\1/'`
         ls_dirname="`\grep -n '.' $CDL_FILE | \grep "^$dirIndex:" | sed 's/^[0-9]*://'`"
         ls_option=`echo $dirOrCommand | sed 's/^ls \(\-.*\) [0-9][0-9]*$/\1/'`
         if [ $ls_option == $dirOrCommand ]; then
            ls_option=
         fi
         ls $ls_option $ls_dirname
         ;;

      e)
         if [ -n "$EDITOR" ]; then
            $EDITOR $CDL_FILE
         else
            vi $CDL_FILE
         fi
         display_list=true
         continue
         ;;

      [0-9]*)
         do_cd="`\grep -n '.' $CDL_FILE | \grep "^$dirOrCommand:" | sed 's/^[0-9]*://'`"
         relative_dir=$(echo $dirOrCommand | awk '{print $2}')
         break
         ;;

      # Delete directory entry from the cdl file.
      d' '[0-9]*)
         dirIndex=`echo $dirOrCommand | sed 's/^d \([0-9][0-9]*\)$/\1/'`
         \grep -n '.' $CDL_FILE | \grep -v "$dirIndex:" | sed 's/^[0-9][0-9]*://' > ${CDL_FILE}_new
         \mv ${CDL_FILE}_new $CDL_FILE
         display_list=true
         continue
         ;;

      # search string
      s*)
         if [ "$dirOrCommand" == 's' ]; then
            continue
         fi
         search_string=`echo $dirOrCommand | sed 's/^s \(.*\)$/\1/'`
         display_list=true
         continue
         ;;

      *)
         echo "ERROR: Unrecognized command format.  Type 'h' for help."
         continue
         ;;
      esac

   done

fi


if [ -n "$do_cd" ]; then
      # cd to the directory
      # Need to handle directory paths with spaces in them.
      if [ -n "$relative_dir" ]; then
         do_cd=$do_cd/$relative_dir
      fi
      cd "$do_cd"
      # After cd'ing, if the new directory has a .cdl_execute script in it, then run it.
      # Good for doing an "ls -ltr" on specific directories after cd'ing to them.
      if [ -x .cdl_execute ]; then
        # . .cdl_execute
        .cdl_execute
      else
       	ls
      fi
fi

}

                                                                                
# Remove command:  Remove a directory entry from your list.  The id numbers will get automatically
# resequenced to maintain consecutive order.
# Runstring:  cdr <id_number>

# function cdr() { \grep -v "$@ " $CDL_FILE | \grep -n '.' | sed -e 's/:[0-9]* / /' > ${CDL_FILE}_new; if [ -s ${CDL_FILE}_new ]; then \mv ${CDL_FILE}_new $CDL_FILE;fi; } 

