#!/usr/bin/env bash

#The order of parameters does indeed matter ..

#rsync -avz --exclude="nobackup/sw/*"  --exclude="nobackup/rubygems/*" --include='*/' --include='README*' --exclude='*' --prune-empty-dirs  /my/home/ccls/ /my/home/jwendt/READMES/


#rsync -avz --include='*/' --include='README*' --exclude='*' --prune-empty-dirs  /my/home/ccls/ /my/home/jwendt/READMES/

