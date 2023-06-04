import Foundation

func printInConsole(_ message: Any) {
    print("==> \(message)")
}

let fileManager = FileManager.default
let homeDirectoryForCurrentUser = fileManager.homeDirectoryForCurrentUser.path
let currentPath = fileManager.currentDirectoryPath
let templatePath = "\(homeDirectoryForCurrentUser)/Library/Developer/Xcode/Templates/"

// let projectDir = "Project Templates/"
let useCaseDir = "StoreSwift/"

// let sourceProjectPath = "\(currentPath)/\(projectDir)"
let sourceUseCasePath = "\(currentPath)/\(useCaseDir)"

// let projectTemplatePath = "\(templatePath)/\(projectDir)"
let useCaseTemplatePath = "\(templatePath)/\(useCaseDir)"

func makeDir(path: String) {
    try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
}

func moveTemplate(fromPath: String, toPath: String) throws {
    let toURL = URL(fileURLWithPath: toPath)
    try _ = fileManager.removeItem(at: toURL)
    try _ = fileManager.copyItem(atPath: fromPath, toPath: toPath)
}

do {
    printInConsole("Install UseCase templates at \(useCaseTemplatePath)")
    makeDir(path: useCaseTemplatePath)
    try moveTemplate(fromPath: sourceUseCasePath, toPath: useCaseTemplatePath)

    printInConsole("All templates have been successfully installed.")
} catch let error as NSError {
    printInConsole("Could not install the templates. Reason: \(error.localizedFailureReason ?? "")")
}
