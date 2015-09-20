# pacman.sh: Functions for running pacman and installing packages
#
# Copyright 2015, Sudaraka Wijesinghe <sudaraka@sudaraka.org>
#
# This program comes with ABSOLUTELY NO WARRANTY;
# This is free software, and you are welcome to redistribute it and/or modify it
# under the terms of the BSD 2-clause License. See the LICENSE file for more
# details.
#

SCRIPT_ROOT="$(realpath $(dirname $0))";
PKG_INSTALL='base haveged'
PKG_IGNORE=(
    cryptsetup
    device-mapper
    dhcpcd
    diffutils
    gettext
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
    netctl
    openresolv
    pciutils
    pcmciautils
    popt
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

    cp -r /var/lib/pacman/sync $FS_ROOT/var/lib/pacman/

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
