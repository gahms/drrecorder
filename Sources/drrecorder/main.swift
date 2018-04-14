import drrecorderCore

let tool = DRRecorder()

do {
    if #available(OSX 10.13, *) {
        try tool.run()
    } else {
        print("ERROR: requires macOS 10.13 or later to run")
    }
}
catch {
    print("ERROR: \(error)")
}
