#!/bin/sh

rm -rf phicomm-tv-ctrl
git clone https://github.com/hanxi/phicomm-tv-ctrl.git
cd phicomm-tv-ctrl

git submodule update --init
cd skynet
make linux
cd ..

mkdir -p bin
cp -f start.sh bin/
cp -rf etc bin/
cp -rf lualib bin/
cp -rf service bin/
cp -rf static bin/
mkdir -p bin/skynet
cp -rf skynet/cservice bin/skynet/
cp -rf skynet/luaclib bin/skynet/
cp -rf skynet/lualib bin/skynet/
cp -rf skynet/service bin/skynet/
cp -f skynet/skynet bin/skynet/

