# fs.sh: File system related functions
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

function madb_fs_init() {
    FS_ROOT=$1

    #if [ -d $FS_ROOT ]; then
        #echo "$FS_ROOT already exists"
        #echo

        #exit 1
    #fi

    mkdir -p $FS_ROOT 2>/dev/null

    if [ 0 -ne $? -o ! -d $FS_ROOT ]; then
        echo "Unable to create $FS_ROOT"
        echo

        exit 1
    fi

    trap "_madb_remove_root $FS_ROOT" EXIT HUP INT TERM

    mkdir -m 0755 -p $FS_ROOT/{dev,run,etc,var/{cache/pacman/pkg,lib/pacman,log}}
    mkdir -m 1777 -p $FS_ROOT/tmp
    mkdir -m 0555 -p $FS_ROOT/{sys,proc}

    _madb_make_dev_tree $FS_ROOT
}

function _madb_make_dev_tree() {
    DEV_DIR=$1/dev

    if [ ! -d $DEV_DIR ]; then
        echo 'Unable to build /dev tree'
        echo

        exit 1
    fi

    mknod -m 666 $DEV_DIR/null c 1 3
    mknod -m 666 $DEV_DIR/zero c 1 5
    mknod -m 666 $DEV_DIR/random c 1 8
    mknod -m 666 $DEV_DIR/urandom c 1 9
    mkdir -m 755 $DEV_DIR/pts
    mkdir -m 1777 $DEV_DIR/shm
    mknod -m 666 $DEV_DIR/tty c 5 0
    mknod -m 600 $DEV_DIR/console c 5 1
    mknod -m 666 $DEV_DIR/tty0 c 4 0
    mknod -m 666 $DEV_DIR/full c 1 7
    mknod -m 600 $DEV_DIR/initctl p
    mknod -m 666 $DEV_DIR/ptmx c 5 2
    ln -sf /proc/self/fd $DEV_DIR/fd
}

function madb_mount() {
    if [[ -z $MADB_MOUNTS ]]; then
        MADB_MOUNTS=()
        trap '_madb_umount' EXIT
    fi

    mount "$@" && MADB_MOUNTS=("$2" "${MADB_MOUNTS[@]}")
}

function _madb_umount() {
    umount "${MADB_MOUNTS[@]}"
}

function _madb_remove_root() {
    rm -fr $1

    trap - EXIT HUP INT TERM
}
