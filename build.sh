#!/bin/sh

rm -rf skynet
git clone https://github.com/cloudwu/skynet.git
cd skynet
git checkout v1.2.0
make linux MALLOC_STATICLIB= SKYNET_DEFINES=-DNOUSE_JEMALLOC
cd ..

mkdir -p skynet-bin
cp -rf skynet/cservice skynet-bin/
cp -rf skynet/luaclib skynet-bin/
cp -rf skynet/lualib skynet-bin/
cp -rf skynet/service skynet-bin/
cp -f skynet/skynet skynet-bin/skynet

tar -zcvf skynet-bin.tar.gz skynet-bin

