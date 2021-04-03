#!/bin/bash
set -e

if [[ ! -d sshpass ]]; then
	echo 'Downloading sshpass'
	curl -L# https://downloads.sourceforge.net/project/sshpass/sshpass/1.09/sshpass-1.09.tar.gz -o sshpass.tar.gz
	rm -rf sshpass
	mkdir sshpass
	tar -xf sshpass.tar.gz -C sshpass --strip-components=1
fi

export CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.11 -Os"

cd sshpass
./configure
make clean
make -j16
cd ..

cp sshpass/sshpass ../Betelguese/
