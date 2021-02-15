//
//  launch.swift
//

import Foundation
import struct ArgumentParser.ExitCode

@discardableResult
func launch(command: String, arguments: String...) throws -> String
{
  let task = Process()
  task.launchPath = "/usr/bin/env"

  let pipe = Pipe()
  task.standardOutput = pipe
  task.standardError = FileHandle.standardError

  task.arguments = [command] + arguments
  try task.run()
  task.waitUntilExit()

  let data = pipe.fileHandleForReading.availableData
  let output = String(data: data, encoding: .utf8) ?? ""
  if task.terminationStatus != 0
  {
    FileHandle.standardOutput.write(Data(output.utf8))
    throw ExitCode(task.terminationStatus)
  }

  return output
}