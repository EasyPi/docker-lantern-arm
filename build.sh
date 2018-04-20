#!/bin/bash
#
# build lantern for raspberry pi
#

set -xe

VERSION=${1:?version is empty}

git clone https://github.com/getlantern/lantern.git
cd lantern

VERSION=$VERSION HEADLESS=true make docker-linux-arm
mv lantern_linux_arm lantern-$VERSION-armv7h

sed -i 's/GOARM=7/GOARM=6/' Makefile

VERSION=$VERSION HEADLESS=true make docker-linux-arm
mv lantern_linux_arm lantern-$VERSION-armv6h

mkdir -p lantern/{DEBIAN,lib/systemd/system,usr/bin}/
cp lantern-$VERSION-armv6h lantern/usr/bin/lantern
cat > lantern/DEBIAN/control <<_EOF_
Package: lantern
Version: $VERSION-1
Maintainer: noreply@easypi.pro
Homepage: https://getlantern.org
Architecture: armhf
Priority: optional
Section: net
Description: Open Internet for Everyone
_EOF_
cat > lantern/lib/systemd/system/lantern.service <<_EOF_
[Unit]
Description=Open Internet for Everyone
Documentation=https://getlantern.org
After=network.target

[Service]
ExecStart=/usr/bin/lantern -addr=0.0.0.0:8787
StandardOutput=null
StandardError=null
Restart=always

[Install]
WantedBy=multi-user.target
_EOF_
dpkg -b lantern lantern_$VERSION-1_armhf.deb

sudo mv lantern-$VERSION-armv[67]h lantern_$VERSION-1_armhf.deb ..
cd ..
sudo chmod a+rw lantern-$VERSION-armv[67]h lantern_$VERSION-1_armhf.deb
