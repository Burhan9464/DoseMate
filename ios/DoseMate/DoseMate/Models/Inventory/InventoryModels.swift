import Foundation

struct InventoryDTO: Codable, Equatable {
    var id: Int64?
    var quantity: Int
    var unit: String
    var lowStockThreshold: Int
    var isLowStock: Bool?
}

struct InventoryUpdateDTO: Codable {
    let quantity: Int
}

struct InventoryRefillDTO: Codable {
    let refillAmount: Int
}
