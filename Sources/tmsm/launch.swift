//
//  launch.swift
//

import Foundation
import struct ArgumentParser.ExitCode

func launch(command: String, arguments: String...,
            environment: [String: String] = [:]) throws -> String
{
  let pipe = Pipe()
  do {
    try launch(command: command,
               arguments: arguments,
               environment: environment,
               output: pipe.fileHandleForWriting)
  }
  catch {
    let data = pipe.fileHandleForReading.availableData
    FileHandle.standardOutput.write(data)
    throw error
  }

  let data = pipe.fileHandleForReading.availableData
  return String(data: data, encoding: .utf8) ?? ""
}

func launch(command: String? = nil, arguments: [String], environment: [String: String] = [:],
            output: FileHandle = .standardOutput, error: FileHandle = .standardError) throws
{
  guard let exec = command ?? arguments.first
  else {
    let message = "missing command in #function\n"
    FileHandle.standardError.write(Data(message.utf8))
    throw ExitCode(EX_UNAVAILABLE)
  }

  var dir = ObjCBool(false)
  guard FileManager.default.fileExists(atPath: exec, isDirectory: &dir)
  else {
    let message = "Path \"\(exec)\" does not exist\n"
    FileHandle.standardError.write(Data(message.utf8))
    throw ExitCode(EX_UNAVAILABLE)
  }

  if dir.boolValue == true
  {
    let message = "Path \"\(exec)\" represents a directory\n"
    FileHandle.standardError.write(Data(message.utf8))
    throw ExitCode(EX_USAGE)
  }

  guard FileManager.default.isExecutableFile(atPath: exec)
  else {
    let message = "File \"\(exec)\" is not executable\n"
    FileHandle.standardError.write(Data(message.utf8))
    throw ExitCode(EX_NOPERM)
  }

  let task = Process()
  task.launchPath = command ?? "/usr/bin/env"

  task.standardOutput = output
  task.standardError = error
  if !environment.isEmpty
  {
    let env = ProcessInfo.processInfo.environment
    task.environment = env.merging(environment, uniquingKeysWith: { $1 })
  }

  task.arguments = arguments
  try task.run()
  task.waitUntilExit()

  if task.terminationStatus != 0
  {
    throw ExitCode(task.terminationStatus)
  }
}
