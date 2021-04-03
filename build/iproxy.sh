#!/bin/bash
set -e

if [[ ! -d libplist ]]; then
	echo 'Downloading libplist'
	curl -L# https://github.com/libimobiledevice/libplist/archive/2.2.0.tar.gz -o libplist.tar.gz
	rm -rf libplist
	mkdir libplist
	tar -xf libplist.tar.gz -C libplist --strip-components=1
fi

if [[ ! -d libusbmuxd ]]; then
	echo 'Downloading libusbmuxd'
	curl -L# https://github.com/libimobiledevice/libusbmuxd/archive/2.0.2.tar.gz -o libusbmuxd.tar.gz
	rm -rf libusbmuxd
	mkdir libusbmuxd
	tar -xf libusbmuxd.tar.gz -C libusbmuxd --strip-components=1
fi

export CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.11"

cd libplist
./autogen.sh \
	--disable-shared \
	--without-cython
make clean
make -j16
cd ..

cd libusbmuxd
libplist_LIBS="$PWD/../libplist/src/.libs/libplist-2.0.la" \
	./autogen.sh \
		--disable-shared
make clean
make -j16
cd ..

cp libusbmuxd/tools/iproxy ../Betelguese/
