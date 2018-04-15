import Foundation

public final class DRRecorder {
    private let _commandLineArgsParser: CommandLineArgsParser
    private let _dateFormatter = DateFormatter()
    
    public init(arguments: [String] = CommandLine.arguments) {
        _commandLineArgsParser = CommandLineArgsParser(arguments: arguments)
        _dateFormatter.dateFormat = "y-MM-dd HH:mm:ss"
    }

    public func run() throws {
        let params = try _commandLineArgsParser.parseArguments()
        
        //log("params = \(params)")
        
        log("Sleeping util \(_dateFormatter.string(from: params.start))...")
        Thread.sleep(until: params.start)
        try execute(params: params)
        log("Done")
    }
    
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
        if #available(OSX 10.13, *) {
            task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        } else {
            task.launchPath = "/usr/bin/env"
        }
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

        log("Recording \(params.channel) to '\(filename)' START")
        if #available(OSX 10.13, *) {
            try task.run()
        } else {
            task.launch()
        }

        setbuf(__stdoutp, nil)
        while task.isRunning && params.end.timeIntervalSinceNow >= 0 {
            print(".", terminator:"")
            Thread.sleep(forTimeInterval: 1)
        }
        
        if task.isRunning {
            print("")
            log("STOPPING", terminator: "")
            task.interrupt()

            while task.isRunning {
                print(".", terminator:"")
                Thread.sleep(forTimeInterval: 0.2)
            }
            
            print("")
            log("STOPPED")
        }
        else {
            print("")
        }
        
        if task.terminationStatus != EXIT_SUCCESS {
            log("ERROR: terminationStatus = \(task.terminationStatus)")
        }
    }
    
    func log(_ msg: String, terminator: String = "\n") {
        print("\(_dateFormatter.string(from: Date()))", msg, terminator: terminator)
    }
}
