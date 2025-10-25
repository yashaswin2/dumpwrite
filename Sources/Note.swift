import Foundation

struct Note: Identifiable, Codable, Equatable {
    var id: UUID
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(content: String = "") {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var title: String {
        let lines = content.split(separator: "\n", maxSplits: 1)
        return lines.first?.isEmpty == false ? String(lines.first!) : "New Note"
    }

    var preview: String {
        let lines = content.split(separator: "\n", maxSplits: 2)
        if lines.count > 1 {
            return String(lines[1])
        }
        return ""
    }
}
