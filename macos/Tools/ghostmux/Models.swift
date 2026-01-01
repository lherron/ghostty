import Foundation

struct Terminal {
    let id: String
    let title: String
    let workingDirectory: String?
    let focused: Bool
    let columns: Int?
    let rows: Int?
    let cellWidth: Int?
    let cellHeight: Int?
}

struct KeyStroke {
    let key: String
    let mods: [String]
    let text: String?
    let unshiftedCodepoint: UInt32
}
