#!/usr/bin/env bash
cd ../
rm MiniHUD.zip
zip -r -D MiniHUD.zip MiniHUD/64/* MiniHUD/data/* MiniHUD/liblinux/* MiniHUD/README.md -x \*/.DS_Store \*/readme.txt \*/SASLLog.txt \*/state.txt
