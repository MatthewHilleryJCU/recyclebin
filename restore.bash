#!/bin/bash

function optFunc () {
    recursive=false
    
    while getopts :r opt
    do
        case $opt in
            r) recursive=true;;
            *) echo Bad Option - $OPTARG exit 1;;
        esac
    done
}

function getFilePath () {
    filePath=$(grep $fileName ~/.restore.info | cut -d":" -f2)
    echo $filePath
}

function moveFile () {
    newPath=$(getFilePath)
    mkdir -p $(dirname $newPath)
    mv ~/deleted/$fileName $newPath
    
}

function removeRestoreInfo () {
    grep -v $fileName ~/.restore.info > ~/tempFile
    rm ~/.restore.info
    mv ~/tempFile ~/.restore.info
}

function confirmRestore () {
    if [ -e $(getFilePath) ]
    then
        while true; do
            read -p "Do you want to overwrite? y/n: " yn
            case $yn in
                [Yy]* ) moveFile; removeRestoreInfo; break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    else
        moveFile
        removeRestoreInfo
    fi
    
}

function restoreFile () {
    #checks to see if file exists already. If true asks user to confirm over                                                       write
    if [ -f ~/deleted/$fileName ]
    then
        if [ -e $(getFilePath) ]
        then
            while true; do
                read -p "Do you want to overwrite? y/n: " yn
                case $yn in
                    [Yy]* ) moveFile; removeRestoreInfo; break;;
                    [Nn]* ) exit;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        else
            moveFile
            removeRestoreInfo
        fi
    else
        echo restore: cannot restore $fileName: No such file inside dele                                                       ted
    fi
}
#handles options
optFunc $*
shift $[OPTIND-1]

if [ $# -eq 0 ]
then
    echo No filename provided: Try restore \<filename_inode\>
    exit 1
    
else
    # Handles removing mutiple files at once
    if $recursive
    then
        for fileName in $*
        do
            restoreFile
        done
    else
        fileName=$1
        restoreFile
        
    fi
fi
exit 0
