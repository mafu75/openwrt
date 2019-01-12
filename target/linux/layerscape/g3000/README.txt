1) Build LEDE for g3000 board.

1.1) Clone openwrt source for g3000 (only when building for the first time)
(typically git clone ... and git checkout ...).

git clone https://github.com/mafu75/openwrt.git
cd openwrt
git checkout <g3000_branch>

./scripts/feeds update -a
./scripts/feeds install -a

1.2) Copy diffconfig (only when building for the first time)

From source directory:

cp target/linux/layerscape/g3000/diffconfig .config
make defconfig

1.3) Start build process:

make

After some time the images can be found under

bin/targets/layerscape/armv7/

2) Initial factory installation in g3000 board:

2.1) Copy files to FAT formatted Micro-SD card:

ledeenv.txt
openwrt-layerscape-armv7-g3000-nand-initramfs-kernel.bin
openwrt-layerscape-armv7-g3000-nand-ubifs-factory_dtb.bin
openwrt-layerscape-armv7-g3000-nand-ubifs-factory_kernel.bin
openwrt-layerscape-armv7-g3000-nand-ubifs-factory_ubi.bin

2.2) Insert into board and stop at U-Boot prompt

=> fatload mmc 0 82000000 ledeenv.txt
=> env import -t 82000000 ${filesize}
=> saveenv
=> run ledemmc

... wait, LEDE boots from ramdisk now


2.3) First install

After last step booted board to shell prompt enter:

mount -t auto /dev/mmcblk0p1 /mnt
ubiformat /dev/mtd2 --flash-image /mnt/openwrt-layerscape-armv7-g3000-nand-ubifs-factory_ubi.bin

flash_erase /dev/mtd0 0 0
nandwrite -q -p /dev/mtd0 /mnt/openwrt-layerscape-armv7-g3000-nand-ubifs-factory_kernel.bin

flash_erase /dev/mtd1 0 0
nandwrite -q -p /dev/mtd1 /mnt/openwrt-layerscape-armv7-g3000-nand-ubifs-factory_dtb.bin

reboot -f

# Board now boots into LEDE from NAND flash with this default IP config:
# eth0: 192.168.0.80/24
# eth1: 192.168.1.80/24
# eth2: 192.168.2.80/24 (I use this for configuration via luci)

3) sysupgrade

The file bin/targets/layerscape/armv7/openwrt-layerscape-armv7-g3000-nand-ubifs-sysupgrade.tar can be used for sysupgrade from LuCI or shell.
