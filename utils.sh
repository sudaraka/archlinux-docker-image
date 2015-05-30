# utils.sh: Helper functions
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

function madb_print_usage() {
    echo "USAGE: build.sh <image-name>"
    echo
}

function madb_print_copyright() {
    echo 'Minimal Docker image creator for Arch Linux'
    echo 'Copyright 2015, Sudaraka Wijesinghe <sudaraka@sudaraka.org>'
    echo 'This program comes with ABSOLUTELY NO WARRANTY;'
    echo 'This is free software, and you are welcome to redistribute it and/or modify it'
    echo 'under the terms of the ISC License. See the LICENSE file for more details.'
    echo
}
