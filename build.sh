#!/bin/bash

GITHUB_ENV=${GITHUB_ENV:-env}
PACKAGES=$(tr '\n' ' ' < packages.txt)
DISABLED_SERVICES=$(tr '\n' ' ' < disabled-services.txt)
RELEASE=23.05.3

prereqs(){
  
  wget -N "https://downloads.openwrt.org/releases/${RELEASE}/targets/mediatek/filogic/openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64.tar.xz"
  
  tar -Jxf "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64.tar.xz"
  mkdir -p "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64"/{tmp,files/etc/config,files/usr/bin}

  # add pigz for faster compression
  ln -s pigz "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64"/files/usr/bin/gzip
  ln -s pigz "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64"/files/usr/bin/gunzip

  # cp ../files/dockerd openwrt-imagebuilder-*/files/etc/config
  rsync -av ../files/ openwrt-imagebuilder-*/files/
  cp ../packages/*.ipk "openwrt-imagebuilder-${RELEASE}-mediatek-filogic.Linux-x86_64"/packages/

}

make_image(){
  cd openwrt-imagebuilder-*/
  echo "REVISION=$(grep -n "REVISION:=" include/version.mk | tail -c 18)" > ${GITHUB_ENV}

  # fix missing profiles
  rm .profiles.mk; make .profiles.mk

  # make info
  make image PROFILE=bananapi_bpi-r3 PACKAGES="${PACKAGES}" DISABLED_SERVICES="${DISABLED_SERVICES}"

}

# do this in scratch
[ -d scratch ] || mkdir scratch
cd scratch

prereqs
make_image
