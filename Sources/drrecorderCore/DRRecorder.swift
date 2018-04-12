import Foundation

public final class DRRecorder {
    private let _arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        _arguments = arguments
    }

    public func run() throws {
        print("Running...")
    }
}
