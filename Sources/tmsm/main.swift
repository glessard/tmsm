import Foundation
import Algorithms
import ArgumentParser

public struct tmsm: ParsableCommand
{
  @Argument(help: "location of APFS volume to be snapshot")
  public var pathname = "/System/Volumes/Data"

  public init() {}
}

let options = tmsm.parseOrExit()

func newTimeMachineSnapshot() throws -> String
{
  let tmutil = "/usr/bin/tmutil"
  let output = try launch(command: tmutil, arguments: "localsnapshot")

  guard let timestring = output.split(separator: ":").last?.trimming(where: \.isWhitespace)
  else { throw ExitCode.failure }

  return String(timestring)
}

func getTimeMachineSnapshot(pathname: String, timestamp: String) throws -> String
{
  let tmutil = "/usr/bin/tmutil"
  let output = try launch(command: tmutil, arguments: "listlocalsnapshots", pathname)

  guard let snapshot = output.split(separator: "\n").first(where: { $0.contains(timestamp) })
  else {
    let message = "No snapshot found for \(pathname) with timestamp \(timestamp)\n"
    FileHandle.standardError.write(Data(message.utf8))
    throw ExitCode.failure
  }

  return String(snapshot)
}

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

let output: String
var mountpoint = ""
do {
  let timestamp = try newTimeMachineSnapshot()
  let snapshot = try getTimeMachineSnapshot(pathname: options.pathname, timestamp: timestamp)

  mountpoint = try createMountpoint()
  output = try launch(command: "/sbin/mount_apfs",
                      arguments: "-o", "rdonly",
                                 "-s", snapshot,
                                 options.pathname, mountpoint)
  print(mountpoint)
}
catch let error as ExitCode {
  if !mountpoint.isEmpty
  {
    _ = try? FileManager.default.removeItem(atPath: mountpoint)
  }
  exit(error.rawValue)
}

if output.isEmpty
{
  exit(EXIT_SUCCESS)
}
else
{
  print(output.trimming(where: \.isWhitespace))
  exit(EXIT_FAILURE)
}
