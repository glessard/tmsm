//
//  mountpoint.swift
//

import Foundation
import struct ArgumentParser.ExitCode

func createMountpoint(under path: String = "/tmp") throws -> String
{
  let alphanumerics = Set("abcdefghijklmnopqrstuvwxyz0123456789")
  let base = URL(fileURLWithPath: path, isDirectory: true)
  for _ in (1...8)
  {
    let randomCharacters = (1...8).compactMap { _ in alphanumerics.randomElement() }
    let candidate = "tmp-\(String(randomCharacters))"
    let candidateURL = base.appendingPathComponent(candidate, isDirectory: true)
    do {
      try FileManager.default.createDirectory(at: candidateURL,
                                              withIntermediateDirectories: false,
                                              attributes: nil)
      return candidateURL.path
    }
    catch {
      continue
    }
  }
  let message = "Could not create temporary directory under \(base.path)\n"
  FileHandle.standardError.write(Data(message.utf8))
  throw ExitCode.failure
}

func mountSnapshot(snapshot: String, pathname: String, mountpoint: String) throws
{
  try launch(command: "/sbin/mount_apfs",
             arguments: ["-o", "rdonly,noexec,nobrowse",
                         "-s", snapshot,
                         pathname, mountpoint])
}

func unmountSnapshot(from mountpoint: String) throws
{
  try launch(command: "/sbin/umount", arguments: ["-f", mountpoint])
}

func removeMountpoint(path mountpoint: String) throws
{
  let fm = FileManager.default
  if try fm.contentsOfDirectory(atPath: mountpoint).isEmpty
  {
    try fm.removeItem(atPath: mountpoint)
  }
}
