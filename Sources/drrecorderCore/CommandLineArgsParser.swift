import Foundation
import Utility

public class CommandLineArgsParser {
    private let _arguments: [String]
    private let _executableName: String
    private let _argsParser: ArgumentParser
    
    public enum Channel: String {
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
    
    public struct Args {
        let channel: Channel
        let start: Date
        let end: Date
        let name: String
    }
    
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
    
    public func parseArguments() throws -> Args {
        _parsedArguments = try _argsParser.parse(_arguments)
        
        let channel: Channel
        if let channelStr = _parsedArguments.get(_channelArg) {
            if let c = Channel(rawValue: channelStr) {
                channel = c
            }
            else {
                throw Error.unknownChannel(value: channelStr)
            }
        }
        else {
            throw Error.missingRequired(argument: "channel")
        }
        
        let start = try getDate(arg: _startArg, name: "start")
        let end = try getDate(arg: _endArg, name: "end")
        
        let name: String
        if let nameStr = _parsedArguments.get(_nameArg) {
            name = nameStr
        }
        else {
            throw Error.missingRequired(argument: "name")
        }
        
        return Args(channel: channel, start: start, end: end, name: name)
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

public extension CommandLineArgsParser {
    enum Error: Swift.Error {
        case missingRequired(argument: String)
        case unknownChannel(value: String)
        case invalidDateFormat(argument: String)
    }
}
