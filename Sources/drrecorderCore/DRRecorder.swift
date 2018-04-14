import Foundation

public final class DRRecorder {
    private let _commandLineArgsParser: CommandLineArgsParser
    
    public init(arguments: [String] = CommandLine.arguments) {
        _commandLineArgsParser = CommandLineArgsParser(arguments: arguments)
    }

    @available(OSX 10.13, *)
    public func run() throws {
        let params = try _commandLineArgsParser.parseArguments()
        
        print("params = \(params)")
        
        print("\(Date()): Sleeping util \(params.start)...")
        //Thread.sleep(until: params.start)
        try execute(params: params)
        print("\(Date()): Done")
    }
    
    @available(OSX 10.13, *)
    func execute(params: CommandLineArgsParser.Parameters) throws {
        let filename = "\(params.name).mp4"
        let outPipe = Pipe()
        let inPipe = Pipe()
        let errPipe = Pipe()
        
        let args = [
            "youtube-dl",
            "--quiet",
            "--output",
            filename,
            params.url.absoluteString
        ]
        
        let task = Process()
        //task.executableURL = URL(fileURLWithPath: "/usr/bin/python")
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = args
        task.standardInput = inPipe
        task.standardOutput = outPipe
        task.standardError = errPipe
        task.environment = ProcessInfo.processInfo.environment
        
        let outFileHandle = outPipe.fileHandleForReading
        outFileHandle.readabilityHandler = { fileHandle in
            if let string = String(data: fileHandle.availableData, encoding: .utf8) {
                if !string.isEmpty {
                    fputs("youtube-dl: \(string)", stdout)
                }
            }
        }

        let errFileHandle = errPipe.fileHandleForReading
        errFileHandle.readabilityHandler = { fileHandle in
            if let string = String(data: fileHandle.availableData, encoding: .utf8) {
                if !string.isEmpty {
                    fputs("youtube-dl ERROR: \(string)", stderr)
                }
            }
        }

        task.terminationHandler = { task in
            outFileHandle.readabilityHandler = nil
            errFileHandle.readabilityHandler = nil
        }

        print("Recording \(params.channel) to '\(filename)' START")
        try task.run()

        setbuf(__stdoutp, nil)
        while task.isRunning && params.end.timeIntervalSinceNow >= 0 {
            print(".", terminator:"")
            Thread.sleep(forTimeInterval: 1)
        }
        
        print("\nSTOPPING", terminator:"")
        if task.isRunning {
            task.interrupt()
        }
        while task.isRunning {
            print(".", terminator:"")
            Thread.sleep(forTimeInterval: 0.2)
        }
        print("\nSTOPPED")
        
        if task.terminationStatus != EXIT_SUCCESS {
            print("ERROR: terminationStatus = \(task.terminationStatus)")
        }
    }
}
