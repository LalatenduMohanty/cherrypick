#!/bin/bash

minishift_pr_number=$1
append_string='https://patch-diff.githubusercontent.com/raw/minishift/minishift/pull/'

#Errors
code_change_exists="Error: code change present"

#hard coded path
minicodeDir='/home/lmohanty/go/src/github.com/minishift/minishift'
minicodeExist=`cd ${minicodeDir}`


current_branch=`git branch  | grep '*' | tr -d '* '`

if [ ${current_branch} == ${minishift_pr_number} ]
then
        echo "${current_branch} branch already exists!"
        
        code_change=`git status | grep 'nothing to commit, working tree clean' | wc -l`
        if [ ${code_change} != "1" ]
        then
                echo "$code_change_exists"
                exit 1
        else
                git checkout master
                git branch -D ${current_branch}
                current_branch=`git branch  | grep '*' | tr -d '* '`
        fi
fi

if [ ${current_branch} != "master" ]
then
        echo "Error: Not on master branch"
        code_change=`git status | grep 'nothing to commit, working tree clean' | wc -l`
        if [ ${code_change} != "1" ]
        then
                echo "$code_change_exists"
                exit 1
        else
                git checkout master
                current_branch=`git branch  | grep '*' | tr -d '* '`
        fi
        
fi

if [ ${current_branch} == "master" ]
then
        echo "On master branch"
        code_change=`git status | grep 'nothing to commit, working tree clean' | wc -l`
        if [ ${code_change} != "1" ]
        then
                echo "$code_change_exists"
                exit 1
        fi
        
        output=`git checkout -b ${minishift_pr_number}`
        if [ $? -ne 0 ]
        then
                echo "Error: Branch ${minishift_pr_number} already exists"
                git checkout ${minishift_pr_number}
                exit 1
        fi
        patch=`curl ${append_string}${minishift_pr_number}.patch`
        echo "$patch" | git am
        if [ $? -eq 0 ]
        then
                echo -e "\nSuccess\n"
                #echo -e "\nmake clean"
                #make clean
                #echo -e "\nmake"
                #make
        fi
fi

