# pacman.sh: Functions for running pacman and installing packages
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

SCRIPT_ROOT="$(realpath $(dirname $0))";
PKG_INSTALL='base haveged'
PKG_IGNORE=(
    cryptsetup
    device-mapper
    dhcpcd
    diffutils
    gettext
    glib2
    grep
    inetutils
    iproute2
    jfsutils
    libunistring
    licenses
    linux
    logrotate
    lvm2
    man-db
    man-pages
    mdadm
    nano
    nano
    netctl
    openresolv
    pciutils
    pcmciautils
    popt
    procps-ng
    psmisc
    reiserfsprogs
    s-nail
    systemd-sysvcompat
    usbutils
    util-linux
    vi
    xfsprogs
)

IFS=','
PKG_IGNORE="${PKG_IGNORE[*]}"
unset IFS

function madb_install_packages() {
    FS_ROOT=$1

    if [ ! -d $FS_ROOT ]; then
        echo "$FS_ROOT does not exists"
        echo

        exit 1
    fi

    expect << EOF
        set send_slow {1 .1}

        proc send {ignore arg} {
            sleep .1

            exp_send -s -- \$arg
        }

        set timeout 60

        spawn pacman -q --noprogressbar -r $FS_ROOT -Sy --config $SCRIPT_ROOT/pacman.conf --ignore $PKG_IGNORE $PKG_INSTALL

        expect {
            -exact "anyway? \[Y/n\] " { send -- "n\r"; exp_continue }
            -exact "(default=all): " { send -- "\r"; exp_continue }
            -exact "installation? \[Y/n\] " { send -- "y\r"; exp_continue }
        }
EOF

    # Remove man pages and pacman db
    rm -r $FS_ROOT/usr/share/{doc,man,terminfo}/*
    rm -r $FS_ROOT/var/lib/pacman/*
}
