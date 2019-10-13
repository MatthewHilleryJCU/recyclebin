#!/bin/bash

function optFunc () {
    confirm=false
    verbose=false
    recursive=false
    
    while getopts :vir opt
    do
        case $opt in
            i) confirm=true;;
            v) verbose=true;;
            r) recursive=true;;
            *) echo Bad Option - $OPTARG exit 1;;
        esac
    done
}

function getInode () {
    inode=$(ls -li $fileName | cut -d" " -f1)
    echo $inode
}

function getNewFileName () {
    newFileName=$baseFileName\_$(getInode)
    echo $newFileName
}

function getFileLocationPath () {
    fileLocationPath=$(readlink -f $fileName)
    echo $fileLocationPath
}

function getRestoreFileName () {
    restoreFileName=$(getNewFileName):$(getFileLocationPath)
    echo $restoreFileName
}


function removeFile () {
    
    baseFileName=$(basename $fileName)
    
    if [ $fileName -ef ~/project/remove ]
    then
        echo Attempting to delete remove - operation aborted
        exit 1
        
    elif [ -f $fileName ]
    then
        # If -i is selected ask the user for confimation before removal
        if $confirm
        then
            while true; do
                read -p "rm: remove regular file \`file\'? y/n: " yn
                case $yn in
                    [Yy]* ) getRestoreFileName >> ~/.restore.info;
                        mv $fileName ~/deleted/$(getNewFileName);
                        if $verbose
                        then
                            echo $baseFileName removed
                    fi; break;;
                    [Nn]* ) exit;;
                    * ) echo "Please answer y or n.";;
                esac
            done
        else
            getRestoreFileName >> ~/.restore.info
            mv $fileName ~/deleted/$(getNewFileName)
            if $verbose
            then
                echo $baseFileName removed
            fi
        fi
    elif [ -d $fileName ]
    then
        echo remove: cannot remove $fileName: Is a directory
        exit 1
        
    else
        echo remove: cannot remove $fileName: No such file or directory
        exit 1
    fi
}

#handles options
optFunc $*
shift $[OPTIND-1]

mkdir -p ~/deleted
touch ~/.restore.info

if [ $# -eq 0 ]
then
    echo No filename provided: Try remove \<filename\>
    exit 1
else
    #Handles removing multiple files at once
    if $recursive
    then
        for i in $*
        do
            file=$i
            for fileName in $(find $file)
            do
                if [ -f $fileName ]
                then
                    removeFile
                fi
            done
            rm -r $file
            if $verbose
            then
                echo $file removed
            fi
        done
    else
        fileName=$1
        removeFile
    fi
fi
exit 0

