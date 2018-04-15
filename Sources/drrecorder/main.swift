import drrecorderCore

let tool = DRRecorder()

do {
    try tool.run()
}
catch {
    print("ERROR: \(error)")
}
