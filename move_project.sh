#!/bin/bash
#==============================================
# Copy the contents of the source directory 
# to destination directory.
#
# Accepted arguments:
#   -v      verbose
#   -h      help
#
# Author:
#   Anwar A. Ruff
# Email:
#   anwarruff@gmail.com
# License:
#   GNU General Public License, version 3
#==============================================

# Name of directories to ignore
ignore_directories=()

# Name of files to ignore
ignore_files=()

SRC_DIR="/location/to/project/source/"
DEST_PATH="/location/to/destination/directory/"

MAX_DEPTH=100
current_depth=0

verbose=0

#-
# Read command line arguments and set relavent 
# parameters.
#-
set_flags(){
    while getopts "vh" opt; do
        case $opt in
            v)
                echo "** verbose mode on **"
                verbose=1
                ;;
            h)
                echo "----------------------------------"
                echo "Usage:"
                echo -e "./transfer_enso <options>"
                echo "Options:"
                echo -e "\t-v\tverbose mode"
                echo -e "\t-h\thelp"
                echo "----------------------------------"
                exit 0
                ;;
            \?)
                echo "invalid argument"
                exit 0
                ;;
        esac
    done
}

#-
# Executes CD to a directory specified by $1.
#
# Param $1: directory
#-
move_to(){
    local directory="$1"

    if [ "$directory" == "" ]; then
        display "Error: cannot cd to an non specified directory"
        exit 0;
    fi

    cd "$directory"
    verbose_output "\t-->cd $source_dir"
}


#-
# Searches an array (haystack) for a value (needle).
# If found 1 is returned, otherwise 0 is returned.
#
# Param $1: needle
# Param $2: haystack
#-
array_search(){
    local needle=$1
    local haystack=$2

    if [ "$needle" == "" ]; then
        display "Error: Invalid file system heirarcy"
        exit 0
    fi

    local value
    for value in ${haystack[@]}; do
        if [ "$needle" == "$value" ]; then
            return 1
        fi
    done
    return 0
}


#- 
# Prints the parameter $1 (string) using
# the echo command with argument -e
#
# Param $1: string
#-
display(){
    local string=$1
    echo -e "$string"
}

 
#-
# Prints verbose output specified by 
# param $1 (string) if the global parameter
# verbose is set to 1, otherwise the string
# is not printed.
# 
# Param $1: string
#-
verbose_output(){
    local string=$1
    if [ $verbose == 1 ]; then
        display "$string"
    fi
}

#-
# Creates the directory in the name specified
# by the parameter $1 (directory) if it does
# not already exist.
#
# Parm $1: directory
#-
create_directory(){
    local directory=$1
    if [ ! -d "$directory" ]; then
        verbose_output "<-->creating directory $directory"
        mkdir $directory
    fi
}

#-
# copy source_file to destination
#
# Parm $1: source_file
# Parm $2: destination
#-
copy_file(){
    local source_file="$1"
    local destination="$2"
    
    # check the ignore array
    array_search $source_file $ignore_files
    local ignore_file=$?

    # Only skip this source_file if it's in the ingore array 
    if [ "$ignore_file" == 0 ]; then
        cp -f $source_file $destination
        verbose_output "\t\tcopying $source_file to $destination"
    else
        verbose_output "\t\t\t** ignored: $source_file **"
    fi
}

#-
# Copy all the files specified in the 
# $1 (source_dir) parameter to the $2 (destination_dir)
# directory.
#
# Param $1: source_dir 
# Param $2: destination_dir
#-
copy_directory(){
    local source_dir=$1
    local destination_dir=$2

    # create the destination directory if it doesn't exist
    if [ ! -d $destination_dir ]; then
        create_directory "$destination_dir"
    fi
  
    # move to the current source directory
    cd $source_dir 
    verbose_output "\t--->cd $source_dir"

    #/ Prevent the tree depth recursion from getting
    #\ out of control.
    current_depth=`expr $current_depth + 1`
    if [ $current_depth == $MAX_DEPTH ]; then
        display "ERROR: Max depth ($MAX_DEPTH) reached"
        exit 0
    fi

    #/ copy files in current directory, and recurse
    #  through any directory that is found.
    #\
    local source_file
    local files=(*)
    for source_file in ${files[@]}; do

        if [ -f "$source_file" ]; then
                copy_file $source_file $destination_dir$source_file
        elif [ -d "$source_file" ]; then
            local source_dir_name="$source_file" # this source_file is a directory

            # determine if this directory should be ignored
            array_search $source_dir_name $ignore_directories
            local ignore_directory=$?

            # Only skip this directory if it is in the ignore directory array
            if [ "$ignore_directory" == 0 ]; then
                copy_directory "$source_dir$source_dir_name/" "$destination_dir$source_dir_name/" 
                verbose_output "\t--->Return to $source_dir from $source_dir$source_dir_name/"
                continue
            fi

            # directory skipped
            verbose_output "\t\t\t** ignored: $source_dir_name **"
        fi
    done
   
    # return to parent directory
    cd ".."

    return 0
}

# set command line arguments flags
set_flags "${@}"

# create the destination directory if it doesn't already exist
create_directory $DEST_PATH

# copy directory
copy_directory $SRC_DIR $DEST_PATH
