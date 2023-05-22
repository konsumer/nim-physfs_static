# simplified physfs

# ideas from https://github.com/fowlmouth/physfs
# see here for more ideas: https://github.com/treeform/staticglfw/blob/master/src/staticglfw.nim#L4-L88

{.compile: "./physfs/src/physfs.c".}
{.compile: "./physfs/src/physfs_byteorder.c".}
{.compile: "./physfs/src/physfs_unicode.c".}
{.compile: "./physfs/src/physfs_platform_posix.c".}
{.compile: "./physfs/src/physfs_platform_unix.c".}
{.compile: "./physfs/src/physfs_platform_windows.c".}
{.compile: "./physfs/src/physfs_platform_os2.c".}
{.compile: "./physfs/src/physfs_platform_qnx.c".}
{.compile: "./physfs/src/physfs_platform_android.c".}

when defined(macosx):
  {.compile: "./physfs/src/physfs_platform_apple.m".}
  {.passL: "-framework IOKit -framework Foundation".}

when defined(linux):
  {.passL: "-lpthread".}

# TODO: probly need some platform-specific stuff for windows

{.compile: "./physfs/src/physfs_archiver_dir.c".}
{.compile: "./physfs/src/physfs_archiver_zip.c".}
{.compile: "./physfs/src/physfs_archiver_unpacked.c".}
{.compile: "./physfs/src/physfs_archiver_grp.c".}
{.compile: "./physfs/src/physfs_archiver_hog.c".}
{.compile: "./physfs/src/physfs_archiver_7z.c".}
{.compile: "./physfs/src/physfs_archiver_mvl.c".}
{.compile: "./physfs/src/physfs_archiver_qpak.c".}
{.compile: "./physfs/src/physfs_archiver_wad.c".}
{.compile: "./physfs/src/physfs_archiver_slb.c".}
{.compile: "./physfs/src/physfs_archiver_iso9660.c".}
{.compile: "./physfs/src/physfs_archiver_vdf.c".}

type 
  PHYSFS_File* {.pure, final.} = object 
    opaque: pointer

{.push callconv: cdecl, importc.}
proc PHYSFS_init(name: cstring): cint
proc PHYSFS_mount(newDir: cstring, mountPoint: cstring, appendToPath:cint): cint
proc PHYSFS_openRead(filename: cstring): ptr PHYSFS_File
proc PHYSFS_openWrite(filename: cstring): ptr PHYSFS_File
proc PHYSFS_openAppend(filename: cstring): ptr PHYSFS_File
proc PHYSFS_exists(name: cstring): int
proc PHYSFS_deinit(): cint
proc PHYSFS_mountMemory(buff: pointer, length:int64, del:pointer, newDir:cstring, mountPoint:cstring, appendToPath:cint): cint
proc PHYSFS_getWriteDir(): cstring
{.pop.}

{.push callconv: cdecl, importc:"PHYSFS_$1".}
proc close*(handle: ptr PHYSFS_File)
proc fileLength*(handle: ptr PHYSFS_File): int64
proc readBytes*(handle: ptr PHYSFS_File, buffer: pointer, len: uint64): int64
proc writeBytes*(handle: ptr PHYSFS_File, buffer: pointer, len: uint64): int64

{.pop.}

# wrap more nimish

proc init*(name: string): bool =
  return PHYSFS_init(cstring(name)) == 1

proc deinit*(): bool =
  return PHYSFS_deinit() == 1

proc mount*(newDir: string, mountPoint: string, appendToPath: bool): bool =
  return PHYSFS_mount(cstring(newDir), cstring(mountPoint), (if appendToPath: cint(1) else: cint(0))) == 1

proc openRead*(filename: string): ptr PHYSFS_File =
  return PHYSFS_openRead(cstring(filename))

proc openWrite*(filename: string): ptr PHYSFS_File =
  return PHYSFS_openWrite(cstring(filename))

proc openAppend*(filename: string): ptr PHYSFS_File =
  return PHYSFS_openAppend(cstring(filename))

proc exists*(name: string): bool =
  return PHYSFS_exists(cstring(name)) == 1

proc mountMemory*(mem: string, newDir:string, mountPoint:string, appendToPath:bool): bool =
  return PHYSFS_mountMemory(unsafeAddr mem[0], mem.len, nil, cstring(newDir), cstring(mountPoint), (if appendToPath: cint(1) else: cint(0))) == 1

proc getWriteDir*():string =
  return cstring PHYSFS_getWriteDir()

proc readFile*(filepath: string): string =
  if not exists(filepath):
    raise newException(IOError, filepath & " does not exist.")
  let f = openRead(filepath)
  let l = fileLength(f)
  let outBytes = newString(l)
  var bytesRead = readBytes(f, unsafeAddr outBytes[0], uint64 l)
  if bytesRead != l:
    raise newException(IOError, "Could not read " & filepath)
  close(f)
  return outBytes

proc writeFile*(filepath: string, contents: string) =
  let f = openWrite(filepath)
  var byteswritten = writeBytes(f, unsafeAddr contents[0], uint64 contents.len)
  if byteswritten != contents.len:
    raise newException(IOError, "Could not write " & filepath)
  close(f)
