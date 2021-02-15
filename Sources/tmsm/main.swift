import Foundation
import ArgumentParser

public struct tmsmOptions: ParsableCommand
{
  @Argument(help: "mount point of APFS volume to clone")
  public var pathname = "/System/Volumes/Data"

  public init() {}
}

let options = tmsmOptions.parseOrExit()

func latestSnapshot(pathname: String) throws -> (name: String, delete: Bool)
{
  var delete = false
  while true
  {
    let (value, output) = launch("/usr/bin/tmutil",
                                 "listlocalsnapshots",
                                 pathname)
    if value != 0
    {
      print(output)
      throw ExitCode(value)
    }

    if let last = output.split(separator: "\n").last,
       case let lastSplit = last.split(separator: "."),
       let timestring = lastSplit.first(where: { $0.allSatisfy({ !$0.isLetter }) })
    {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "yyyy-MM-dd-HHmmss"
      if let timestamp = formatter.date(from: String(timestring))
      {
        if Date().timeIntervalSince(timestamp) < 7500
        {
          return (String(last), delete)
        }
        else
        {
          let (value, _) = launch("/usr/bin/tmutil", "localsnapshot")
          assert(value == 0)
          delete = true
        }
      }
    }
  }
}

let pathname = "/System/Volumes/Data"
let latest = try latestSnapshot(pathname: pathname)

let alphanumerics = Set("abcdefghijklmnopqrstuvwyz0123456789")
let base = URL(fileURLWithPath: "file:///tmp", isDirectory: true)
var mountpoint = ""
repeat {
  let randomCharacters = (1...8).compactMap { _ in alphanumerics.randomElement() }
  let candidate = "tmp-\(String(randomCharacters))"
  let candidateURL = base.appendingPathComponent(candidate, isDirectory: true)
  do {
    try FileManager.default.createDirectory(at: candidateURL, withIntermediateDirectories: false, attributes: nil)
    mountpoint = candidateURL.path
  }
  catch {
    continue
  }
} while mountpoint.isEmpty

let (value, output) = launch("/sbin/mount_apfs",
                             "-o", "rdonly",
                             "-s", latest.name,
                             pathname,
                             mountpoint)
print(value)
print(output)
