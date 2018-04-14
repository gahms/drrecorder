import Foundation
import Utility

public final class DRRecorder {
    private let _arguments: [String]
    private let _executableName: String
    private let _argsParser: ArgumentParser
    
    enum Channel: String {
        case drk = "DR-K"
        case dr1 = "DR1"
        case dr2 = "DR2"
        case dr3 = "DR3"
        case drRamasjang = "DR-Ramasjang"
        case drUltra = "DR-Ultra"
    }
    
    private var _parsedArguments: ArgumentParser.Result!
    private let _channelArg: OptionArgument<String>
    private let _startArg: OptionArgument<String>
    private let _endArg: OptionArgument<String>
    private let _nameArg: OptionArgument<String>

    private var _channel: Channel!
    private var _start: Date!
    private var _end: Date!
    private var _name: String!
    
    public init(arguments: [String] = CommandLine.arguments) {
        _arguments = Array(arguments.dropFirst())
        _executableName = URL(fileURLWithPath: arguments.first!).lastPathComponent
        _argsParser = ArgumentParser(usage: _usage, overview: _overview)
        
        _channelArg = _argsParser.add(
            option: "--channel",
            kind: String.self,
            usage: "DR channel, e.g. DR-K")
        _startArg = _argsParser.add(
            option: "--start",
            kind: String.self,
            usage: "start time, e.g. '2018-04-14 14:30'")
        _endArg = _argsParser.add(
            option: "--end",
            kind: String.self,
            usage: "end time, e.g. '2018-04-14 16:00'")
        _nameArg = _argsParser.add(
            option: "--name",
            kind: String.self,
            usage: "name to use for resulting file")
    }

    public func run() throws {
        try parseArguments()
        
        print("channel = \(_channel), start = \(_start), end = \(_end), name = \(_name)")
    }
    
    private func parseArguments() throws {
        _parsedArguments = try _argsParser.parse(_arguments)

        if let channelStr = _parsedArguments.get(_channelArg) {
            _channel = Channel(rawValue: channelStr)
        }
        else {
            throw Error.missingRequired(argument: "channel")
        }
        
        _start = try getDate(arg: _startArg, name: "start")
        _end = try getDate(arg: _endArg, name: "end")

        if let nameStr = _parsedArguments.get(_nameArg) {
            _name = nameStr
        }
        else {
            throw Error.missingRequired(argument: "name")
        }
    }
    
    private func getDate(arg: OptionArgument<String>, name: String) throws -> Date {
        let df = DateFormatter()
        df.dateFormat = "y-MM-d-HH-mm"
//        df.doesRelativeDateFormatting = true
//        df.isLenient = true
        
        if let rawstr = _parsedArguments.get(arg) {
            let str = rawstr.replacingOccurrences(of: ":", with: "-")
                .replacingOccurrences(of: " ", with: "-")
                .replacingOccurrences(of: ".", with: "-")
                .replacingOccurrences(of: "/", with: "-")
            if let dt = df.date(from: str) {
                return dt
            }
            else {
                throw Error.invalidDateFormat(argument: name)
            }
        }
        else {
            throw Error.missingRequired(argument: name)
        }

    }
    
    private let _usage =
    """
    <options>
    """
    
    private let _overview =
    """
    Wrapper around youtube-dl to schedule recording live transmissions from Danmarks Radio
    """
}

public extension DRRecorder {
    enum Error: Swift.Error {
        case missingRequired(argument: String)
        case invalidDateFormat(argument: String)
    }
}

