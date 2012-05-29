#!/bin/bash
#======================================================
# Links the binary files in the directory 
# specified in the first argument to the 
# directory specified by the second argument.
#
# Usage:
#   link_brewed_bin /source/path /destination/path
#
# Author:
#   Anwar A. Ruff
# License:
#   GNU General Public License, version 3
#======================================================

ARGUMENTS_VALID=0
args=("$@")
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
# Validates the scripts arguments.
#
# Requirement:
#  - two arguments must be provided
#  - both arguments must refer to a directory
#-
validate_arguments(){
    local num_arguments=$1
    if [ "$num_arguments" != 2 ]; then
        display "Two arguments are required: $#"
        display "Usage:\n\tlink_brewed_bin.sh /source/path /source/destination"
    elif [ "${args[0]}" = "" ]; then
        display "arg 1 empty: ${args[0]}"
        display "Usage:\n\tlink_brewed_bin.sh /source/path /source/destination"
    elif [ "${args[1]}" = "" ]; then
        display "arg 2 empty: ${args[1]}"
        display "Usage:\n\tlink_brewed_bin.sh /source/path /source/destination"
    elif [ ! -d "${args[0]}" ]; then
        display "Directory ${args[0]} is invalid or does not exits."
    elif [ ! -d "${args[1]}" ]; then
        display "Directory ${args[1]} is invalid or does not exits."
    else
        ARGUMENTS_VALID=1
    fi
}


#- 
# Links binary files in the source directory 
# to the destination directory.
#-
link_bin_files(){
    cd ${args[0]}
    local file

    # set null globbing see: http://mywiki.wooledge.org/glob 
    shopt -s nullglob
    local files=("${args[0]}/"*)

    # Parameter expansion used to remove absolute paths
    # preceding each executable. 
    # see: http://mywiki.wooledge.org/BashFAQ/073
    for file in ${files[@]##*/}; do
        # Error: not executable 
        if [ ! -f $file ] || [ ! -x $file ] || [ -L $file ]; then
            display "Skipping non executable $file..."
        else
            display "Linking ${file} to ${args[1]}/$file"
            ln -s ${args[0]}/$file ${args[1]}/$file
        fi
    done 
    return 0
}

validate_arguments $#

if [ ! $ARGUMENTS_VALID ]; then
   exit 1 
fi

link_bin_files

