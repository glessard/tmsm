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

    let data = pipe.fileHandleForReading.availableData
    let output = String(data: data, encoding: .utf8)

    XCTAssertEqual(output?.isEmpty, true)
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
