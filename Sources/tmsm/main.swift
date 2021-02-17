import Foundation
import ArgumentParser

let options = tmsm.parseOrExit()

do {
  let timestamp = try newTimeMachineSnapshot()
  defer { try? deleteTimeMachineSnapshot(timestamp: timestamp) }

  let mountpoint = try createMountpoint()
  defer { try? removeMountpoint(path: mountpoint) }

  let snapshot = try getTimeMachineSnapshot(pathname: options.pathname, timestamp: timestamp)
  try mountSnapshot(snapshot: snapshot, pathname: options.pathname, mountpoint: mountpoint)
  defer { try? unmountSnapshot(from: mountpoint) }

  try launch(arguments: options.subcommand,
             environment: ["SNAPSHOTMOUNTPOINT": mountpoint, "SOURCEMOUNTPOINT": options.pathname])
}
catch let error as ExitCode {
  exit(error.rawValue)
}
