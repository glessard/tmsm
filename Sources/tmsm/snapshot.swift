//
//  snapshot.swift
//  

import Foundation
import Algorithms
import struct ArgumentParser.ExitCode

private let tmutil = "/usr/bin/tmutil"

func newTimeMachineSnapshot() throws -> String
{
  let output = try launch(command: tmutil, arguments: "localsnapshot")

  guard let timestring = output.split(separator: ":").last?.trimming(where: \.isWhitespace)
  else {
    let message = "No timestamp found in tmutil output\n"
    FileHandle.standardError.write(Data(message.utf8))
    throw ExitCode.failure
  }

  return String(timestring)
}

func getTimeMachineSnapshot(sourceVolume: String, timestamp: String) throws -> String
{
  let output = try launch(command: tmutil, arguments: "listlocalsnapshots", sourceVolume)

  guard let snapshot = output.split(separator: "\n").first(where: { $0.contains(timestamp) })
  else {
    let message = "No snapshot found for \(sourceVolume) with timestamp \(timestamp)\n"
    FileHandle.standardError.write(Data(message.utf8))
    throw ExitCode.failure
  }

  return String(snapshot)
}

func deleteTimeMachineSnapshot(timestamp: String) throws
{
  try launch(command: tmutil, arguments: ["deletelocalsnapshots", timestamp], output: .nullDevice)
}
