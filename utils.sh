# utils.sh: Helper functions
#
# Copyright 2015, 2017 Sudaraka Wijesinghe <sudaraka@sudaraka.org>
#
# This program comes with ABSOLUTELY NO WARRANTY;
# This is free software, and you are welcome to redistribute it and/or modify it
# under the terms of the BSD 2-clause License. See the LICENSE file for more
# details.
#

function madb_print_usage() {
    echo "USAGE: build.sh <image-name>"
    echo
}

function madb_print_copyright() {
    echo 'Minimal Docker image creator for Arch Linux'
    echo 'Copyright 2015, 2017 Sudaraka Wijesinghe <sudaraka@sudaraka.org>'
    echo 'This program comes with ABSOLUTELY NO WARRANTY;'
    echo 'This is free software, and you are welcome to redistribute it and/or modify it'
    echo 'under the terms of the BSD 2-clause License. See the LICENSE file for more'
    echo 'details.'
    echo
}

# get extra build script postfix from the given image name
# Ex. when given image name `namespace/image_name`, build script postfix will be
# `image_name`
function madb_get_postfix() {
    IMAGE_NAME=$1
    shift

    IFS='/'
    SEGMENTS=($IMAGE_NAME)
    unset IFS

    SEGMENT_LENGTH=${#SEGMENTS[@]}

    echo ${SEGMENTS[$((SEGMENT_LENGTH-1))]}
}
