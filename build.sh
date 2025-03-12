#!/bin/bash

# source env file if it exists
[ -e env ] && . env

GITHUB_ENV=${GITHUB_ENV:-env}
PACKAGES="$(tr '\n' ' ' < packages.txt) $(tr '\n' ' ' < packages-plus.txt)"
DISABLED_SERVICES=$(tr '\n' ' ' < disabled-services.txt)
RELEASE=${RELEASE:-24.10.0}

prereqs(){
  
  wget -N "https://downloads.openwrt.org/releases/${RELEASE}/targets/mediatek/filogic/openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64.tar.zst"
  
  tar --zstd -xf "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64.tar.zst"
  mkdir -p "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64"/{tmp,files/etc/config,files/usr/bin}

  # cp ../files/dockerd openwrt-imagebuilder-*/files/etc/config
  rsync -av ../files/ openwrt-imagebuilder-*/files/
  cp ../packages/*.ipk "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64"/packages/

}

add_pigz(){
  # add pigz for faster compression
  ln -s pigz "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64"/files/usr/bin/gzip
  ln -s pigz "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64"/files/usr/bin/gunzip
}

make_image(){
  cd openwrt-imagebuilder-*/ || exit
  echo "REVISION=$(grep -n "REVISION:=" include/version.mk | tail -c 18)" > "${GITHUB_ENV}"

  # fix missing profiles
  rm .profiles.mk; make .profiles.mk

  # patch config
  # sed -i '/^CONFIG_TARGET_ROOTFS_PARTSIZE/d' .config
  # sed -i '/^CONFIG_TARGET_KERNEL_PARTSIZE/d' .config

  # echo "CONFIG_TARGET_ROOTFS_PARTSIZE=448" >> .config
  # echo "CONFIG_TARGET_KERNEL_PARTSIZE=32"  >> .config

  # make info && exit
  make image PROFILE=bananapi_bpi-r3 PACKAGES="${PACKAGES}" DISABLED_SERVICES="${DISABLED_SERVICES}" FILES="files"

}

# do this in scratch
[ -d scratch ] || mkdir scratch
cd scratch || exit

prereqs
add_pigz
make_image

# look in scratch/openwrt-imagebuilder-*/bin/targets/mediatek/filogic
