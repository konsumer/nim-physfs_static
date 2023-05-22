This will statically compile physfs with the options you want, and wrap it a bit friendlier, for nim.

## installation

Add this to your project's .nimble file:

```
requires "physfs_static >= 0.0.0"
```

## usage

```nim
import physfs_static as physfs

# set these to 1/0 to enable/disable
# not all are needed, they are 0, by default
{.emit: """

#define PHYSFS_SUPPORTS_ZIP 1
#define PHYSFS_SUPPORTS_7Z 1
#define PHYSFS_SUPPORTS_GRP 1
#define PHYSFS_SUPPORTS_WAD 1
#define PHYSFS_SUPPORTS_HOG 1
#define PHYSFS_SUPPORTS_MVL 1
#define PHYSFS_SUPPORTS_QPAK 1
#define PHYSFS_SUPPORTS_SLB 1
#define PHYSFS_SUPPORTS_ISO9660 1
#define PHYSFS_SUPPORTS_VDF 1

""".}

# initialize and mount a file
if physfs.init("yourapp") && physfs.mount("file.zip", "", true):
  # read a file
  var contents = physfs.readFile("mydir/myfile.ext")
  # shutdown physfs
  discard physfs.deinit()
```

## API

```nim
## Initialize physfs
proc init*(name: string): bool

## mount a file/dir
proc mount*(newDir: string, mountPoint: string, appendToPath: bool): bool

## Like mount, but use string of data instead of a file
proc mountMemory*(mem: string, newDir:string, mountPoint:string, appendToPath:bool): bool

## Open a file for reading
proc openRead*(filename: string): ptr PHYSFS_File

## Open a file for writing
proc openWrite*(filename: string): ptr PHYSFS_File

## Does the file exist?
proc exists*(name: string): bool

## Close the file
proc close*(handle: ptr PHYSFS_File)

## Get the byte-length of a file
proc fileLength*(handle: ptr PHYSFS_File): int64

## Read the bytes of a file
proc readBytes*(handle: ptr PHYSFS_File, buffer: pointer, len: uint64): int64

## Write the bytes to a file
proc writeBytes*(handle: ptr PHYSFS_File, buffer: pointer, len: uint64): int64

# De-initialize physfs
proc deinit*(): bool
```