#!/bin/bash
#github sync v0.1 - ppmatrixcsk
echo "\033[33m---------------------------------"
echo "|    updating github repo...    |"
echo "---------------------------------\033[0m"
echo "\033[32m[+] Adding files...\033[0m"
git status
git add .
echo "\033[32m[+] Commit changes...\033[0m"
git commit -m "R2"
echo "\033[32m[+] Pushing...\033[0m"
git push
echo "\033[32m[+] Final status...\033[0m"
git status