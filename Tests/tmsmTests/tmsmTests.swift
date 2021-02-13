import XCTest
import class Foundation.Bundle

final class tmsmTests: XCTestCase
{
  func testExample() throws
  {
    let fooBinary = productsDirectory.appendingPathComponent("tmsm")

    let process = Process()
    process.executableURL = fooBinary

    let pipe = Pipe()
    process.standardOutput = pipe

    try process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)

    XCTAssertEqual(output, "Hello, world!\n")
  }

  /// Returns path to the built products directory.
  var productsDirectory: URL
  {
#if os(macOS)
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest")
    {
      return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("couldn't find the products directory")
#else
    return Bundle.main.bundleURL
#endif
  }
}
