#!/bin/bash

# Copyright (c) 2023 Ben Westgate
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

###############################################################################
# Sets environment variable and launches install-core
###############################################################################

# Check for root.
if [[ $(id -u) = "0" ]]; then
  echo "
YOU SHOULD NOT RUN THIS SCRIPT AS ROOT!
"
  read -rp "PRESS ENTER TO EXIT SCRIPT, AND RUN AGAIN AS $USER. "
  exit 0
fi

DOTFILES='/live/persistence/TailsData_unlocked/dotfiles'

BAILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Installs Bails to tmpfs
rsync --recursive "$BAILS_DIR/bails/" "$HOME"

# shellcheck disable=SC1091
. "$HOME"/.profile
install-core &

until /usr/local/lib/tpscli is-unlocked && \
  /usr/local/lib/tpscli is-active Dotfiles && \
  [ -d "$DOTFILES" ] && [ -w "$DOTFILES" ]; do
    sleep 1
done
# Install Bails to Persistent Storage
rsync -r --remove-source-files "$BAILS_DIR"/bails/ $DOTFILES
rsync --remove-source-files --recursive "$BAILS_DIR"/ $DOTFILES/.local/share/bails
rm -rf "$BAILS_DIR"