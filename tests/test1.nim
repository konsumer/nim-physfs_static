import unittest
import physfs_static as physfs

{.emit: """
#define PHYSFS_SUPPORTS_ZIP 1
""".}

test "mount zip & read file":
  check(physfs.init("test"))
  check(physfs.mount("tests/test.zip", "/", true))
  var contents = physfs.readFile("test.txt")
  check(contents == "This is a test\n")
  check(physfs.deinit())

test "mount dir at subdir & read file":
  check(physfs.init("test"))
  check(physfs.mount("tests", "tester/", true))
  var contents = physfs.readFile("tester/test.txt")
  check(contents == "This is a test\n")
  check(physfs.deinit())