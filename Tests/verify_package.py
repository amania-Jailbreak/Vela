"""Inspect the actual rootless package; this does not validate SpringBoard runtime."""
import pathlib
import plistlib
import struct
import subprocess
import sys
import tarfile
import io

package = pathlib.Path(sys.argv[1])
fields = subprocess.check_output(["dpkg-deb", "-f", str(package)], text=True)
assert "Package: com.amania.vela\n" in fields
assert "Architecture: iphoneos-arm64\n" in fields
assert "firmware (>= 16.0)" in fields
data = subprocess.check_output(["dpkg-deb", "--fsys-tarfile", str(package)])
with tarfile.open(fileobj=io.BytesIO(data)) as archive:
    members = {m.name.removeprefix("./"): m for m in archive.getmembers()}
    root = "var/jb/Library/MobileSubstrate/DynamicLibraries/"
    dylib = archive.extractfile(members[root + "Vela.dylib"]).read()
    plist = plistlib.load(archive.extractfile(members[root + "Vela.plist"]))
    assert plist["Filter"]["Bundles"] == ["com.apple.springboard"]
    assert struct.unpack_from("<I", dylib)[0] == 0xFEEDFACF, "Expected thin Mach-O for Linux arm64 validation"
    _, cpu, subtype, kind, commands, _, _, _ = struct.unpack_from("<8I", dylib)
    assert cpu == 0x0100000C and subtype == 0 and kind == 6
    position, signed, ios16 = 32, False, False
    for _ in range(commands):
        command, size = struct.unpack_from("<II", dylib, position)
        assert size >= 8
        if command == 0x1D:
            signed = True  # LC_CODE_SIGNATURE exists; no device trust claim.
        if command == 0x32:
            platform, minimum = struct.unpack_from("<II", dylib, position + 8)
            ios16 = platform == 2 and minimum == 0x100000
        position += size
    assert signed and ios16
    for name in (root + "Vela.dylib", root + "Vela.plist"):
        member = members[name]
        assert member.uid == member.gid == 0
        assert member.mode & 0o444 == 0o444
print("PASS: rootless paths, package metadata, SpringBoard filter, arm64 Mach-O, iOS 16 minimum, signature command, root ownership")
