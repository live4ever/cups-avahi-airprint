#!/bin/sh

# Canon Linux UFRII driver file download Linux 64 driver from Canon
# CA: http://www.canon.ca/en/Contact-Support/Consumer/Downloads
# US: https://www.usa.canon.com/internet/portal/us/home/support

# try locating the downloaed driver
PKG=$(find . -maxdepth 1 -type f -name 'linux-UFRII-drv-v*-*.tar.gz' -printf '%f\n' -quit | cut -d. -f1)

# nothing found
if [ -z "${PKG}" ]; then
  echo "No Canon UFRII driver found"
  exit 0
fi

# Clean up previous install
rm -rf ${PKG}
tar zxf ${PKG}.tar.gz

# if not already unpackaged
if [ ! -x ${PKG}/install.sh ]; then
  echo "No install.sh found after extracting the driver ${PKG}"
  exit 1
fi

# check for i386 architecture and 
# switch uname -m to dpkg --print-architecture
arch=$(dpkg --print-architecture)
if [ "i386" = "${arch}" ]; then
  echo "Forcing Canon UFRII driver installation for ${arch}"
  sed -i 's;uname -m;dpkg --print-architecture;g' ${PKG}/install.sh || exit 1
fi

# install it
cd ${PKG} && echo y | ./install.sh && cd ..

check=$(which cnsetuputil)
if [ -z "${check}" ]; then
  echo "Failed to install Canon UFRII driver: cnsetuputil not found"
  exit 1
fi
