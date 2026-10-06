#!/bin/sh
# dpkg supplies root archive ownership without requiring a system fakeroot install.
set -eu
exec dpkg-deb --root-owner-group "$@"
