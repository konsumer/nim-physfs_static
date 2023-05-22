import unittest
import physfs_static as physfs

test "mount zip & read file":
  check(physfs.init("test"))
  check(physfs.mount("tests/test.zip", "/", true))
  var contents = physfs.readFile("test.txt")
  check(contents == "This is a test\n")
  check(physfs.deinit())

test "mount memory & read file":
  check(physfs.init("test"))
  check(physfs.mountMemory(io.readFile("tests/test.zip"), "", "/", true))
  var contents = physfs.readFile("test.txt")
  check(contents == "This is a test\n")
  check(physfs.deinit())

test "mount dir at subdir & read file":
  check(physfs.init("test"))
  check(physfs.mount("tests", "tester/", true))
  var contents = physfs.readFile("tester/test.txt")
  check(contents == "This is a test\n")
  check(physfs.deinit())

test "mount zip & write file":
  check(physfs.init("test"))
  check(physfs.mount("tests/test.zip", "/", true))
  physfs.writeFile("test2.txt", "This is a test\n")
  var contents = physfs.readFile("test2.txt")
  check(contents == "This is a test\n")
  check(physfs.deinit())