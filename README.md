# `NANO`
### Zero dependency, small footprint, cross-platform I2P Java Router with a simple tunnel controller and SAM interface
###

`NANO` is a wrapper of I2P.core using only a subset of it's massive codebase.

This project is a fork of [github.com/i2p-zero/i2p-zero](https://github.com/i2p-zero/i2p-zero) made by @nurviro, @dginovker, @Malinero, @eyedeekay, @jtgrassie & @knaccc.

#### Running
Clone it.
```sh
git clone https://github.com/syvita/nano.git
```
Enter it.
```sh
cd nano
```
Build it.
```sh
chmod 777 ./build.sh && ./build.sh
```
Unarchive it.
```sh
unzip dist-zip/NANO-${YOUR_OPERATING_SYSTEM}.${VERSION}.zip
```
Run it.
```sh
# MAC OS

chmod 777 ./dist-zip/NANO-mac.${VERSION}/router/bin/launch.sh
./dist-zip/NANO-mac.${VERSION}/router/bin/launch.sh

# LINUX

chmod 777 ./dist-zip/NANO-linux.${VERSION}/router/bin/i2p-zero
./dist-zip/NANO-linux.${VERSION}/router/bin/i2p-zero
```
