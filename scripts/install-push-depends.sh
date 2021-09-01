#!/bin/bash

apt update
apt-get -qq -o=Dpkg::Use-Pty=0 -y install gnupg2 pass

