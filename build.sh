#!/usr/bin/sh
#
# build.sh: Install Arch Linux packages into a temporary location and build a
#           Docker image from it
#
# Copyright 2015, Sudaraka Wijesinghe <sudaraka@sudaraka.org>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
# OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

source ./utils.sh
source ./fs.sh
source ./pacman.sh

madb_print_copyright

if [ `id -u` -ne 0 ]; then
    echo 'Please run as root.'
    echo

    exit 1
fi

if [ ! -x "`which expect 2>/dev/null`" ]; then
    echo 'Please install "expect" and try again'
    echo

    exit 1
fi

IMAGE_NAME=$1
shift

if [ -z "$IMAGE_NAME" ]; then
    madb_print_usage
    exit 1
fi

FS_ROOT="${TMPDIR:-/tmp}/$IMAGE_NAME-root"

madb_fs_init $FS_ROOT

madb_install_packages $FS_ROOT

# Initialize pacman keys
madb_mount proc "$FS_ROOT/proc" -t proc -o nosuid,noexec,nodev
chroot $FS_ROOT /bin/sh -c 'haveged -w 1024; pacman-key --init; pkill haveged; pacman -Rcnsu --noconfirm haveged; pacman-key --populate archlinux; pkill gpg-agent'

# Set default timezone to Asia/Colombo
ln -s /usr/share/zoneinfo/Asia/Colombo $FS_ROOT/etc/localtime

# Generate locale and set default to en_US (UTF-8)
cat<<EOF >> $FS_ROOT/etc/locale.gen
en_US UTF-8
EOF

cat<<EOF > $FS_ROOT/etc/locale.conf
LANG=en_US
EOF

chroot $FS_ROOT /bin/sh -c 'locale-gen'

echo 'Done.'
echo
