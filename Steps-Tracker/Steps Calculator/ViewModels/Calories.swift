import Foundation

struct Calories: Identifiable, Codable, Equatable {
    // Unique identifier for each Calories record
    let id: UUID
    // Amount of calories (could be from food, etc)
    var amount: Double
    // Date and time when calories were recorded
    var date: Date
    // Optional description or note
    var note: String?
    
    init(id: UUID = UUID(), amount: Double, date: Date = Date(), note: String? = nil) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
    }
}
