import Foundation
import Utility

public final class DRRecorder {
    private let _commandLineArgsParser: CommandLineArgsParser
    
    public init(arguments: [String] = CommandLine.arguments) {
        _commandLineArgsParser = CommandLineArgsParser(arguments: arguments)
    }

    public func run() throws {
        let args = try _commandLineArgsParser.parseArguments()
        
        print("channel = \(args.channel), start = \(args.start), end = \(args.end), name = \(args.name)")
    }
    
}

