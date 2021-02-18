import Foundation
import ArgumentParser

let options = tmsm.parseOrExit()

do {
  let timestamp = try newTimeMachineSnapshot()
  defer { try? deleteTimeMachineSnapshot(timestamp: timestamp) }

  let mountpoint = try createMountpoint()
  defer { try? removeMountpoint(path: mountpoint) }

  let snapshot = try getTimeMachineSnapshot(sourceVolume: options.sourceVolume, timestamp: timestamp)
  try mountSnapshot(snapshot: snapshot, sourceVolume: options.sourceVolume, mountpoint: mountpoint)
  defer { try? unmountSnapshot(from: mountpoint) }

  try launch(arguments: options.subcommand,
             environment: ["SNAPSHOTMOUNTPOINT": mountpoint, "SOURCEVOLUME": options.sourceVolume])
}
catch let error as ExitCode {
  exit(error.rawValue)
}
