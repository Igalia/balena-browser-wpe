#!/bin/bash

apt update
apt-get -qq -o=Dpkg::Use-Pty=0 -y install curl git python python3

mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo

