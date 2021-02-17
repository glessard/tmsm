//
//  tmsm.swift
//  

import Foundation
import ArgumentParser

public struct tmsm: ParsableCommand
{
  @Option(help: "location of APFS volume to be snapshot")
  public var pathname = "/System/Volumes/Data"

  @Argument(help: "a subcommand (and arguments) to launch while the snapshot is mounted")
  public var subcommand: [String] = []

  public init() {}

  public mutating func validate() throws
  {
    if pathname == "/"
    {
      pathname = "/System/Volumes/Data"
    }

    if subcommand.isEmpty
    {
      subcommand = ["/usr/bin/env"]
    }

    if let command = subcommand.first
    {
      var dir = ObjCBool(false)
      guard FileManager.default.fileExists(atPath: command, isDirectory: &dir)
      else {
        let message = "Path \"\(command)\" does not exist\n"
        FileHandle.standardError.write(Data(message.utf8))
        throw ExitCode(EX_UNAVAILABLE)
      }

      if dir.boolValue == true
      {
        let message = "Path \"\(command)\" represents a directory\n"
        FileHandle.standardError.write(Data(message.utf8))
        throw ExitCode(EX_USAGE)
      }

      guard FileManager.default.isExecutableFile(atPath: command)
      else {
        let message = "File \"\(command)\" is not executable\n"
        FileHandle.standardError.write(Data(message.utf8))
        throw ExitCode(EX_NOPERM)
      }
    }
  }
}
