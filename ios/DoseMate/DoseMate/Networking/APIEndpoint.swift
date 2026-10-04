import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Represents an API endpoint contract.
struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let body: Data?
    let requiresAuth: Bool
    
    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.requiresAuth = requiresAuth
    }
}

// MARK: - Endpoint Catalog
extension APIEndpoint {
    // Auth Endpoints
    static func register(request: RegisterRequest) throws -> APIEndpoint {
        let body = try JSONEncoder().encode(request)
        return APIEndpoint(path: "/auth/register", method: .post, body: body, requiresAuth: false)
    }
    
    static func login(request: LoginRequest) throws -> APIEndpoint {
        let body = try JSONEncoder().encode(request)
        return APIEndpoint(path: "/auth/login", method: .post, body: body, requiresAuth: false)
    }
    
    static func logout() -> APIEndpoint {
        APIEndpoint(path: "/auth/logout", method: .post)
    }
    
    // User Endpoints
    static func getProfile() -> APIEndpoint {
        APIEndpoint(path: "/users/me")
    }
    
    static func updateProfile(request: UserUpdateDTO) throws -> APIEndpoint {
        let body = try JSONEncoder().encode(request)
        return APIEndpoint(path: "/users/me", method: .put, body: body)
    }
    
    static func updateFlags(flags: UserFlagsDTO) throws -> APIEndpoint {
        let body = try JSONEncoder().encode(flags)
        return APIEndpoint(path: "/users/me/flags", method: .patch, body: body)
    }
    
    // Medicine Endpoints
    static func listMedicines(status: MedicineStatus? = nil) -> APIEndpoint {
        var queryItems: [URLQueryItem]?
        if let status = status {
            queryItems = [URLQueryItem(name: "status", value: status.rawValue)]
        }
        return APIEndpoint(path: "/medicines", queryItems: queryItems)
    }
    
    static func getMedicineDetails(id: Int64) -> APIEndpoint {
        APIEndpoint(path: "/medicines/\(id)")
    }
    
    static func createMedicine(request: MedicineCreateUpdateDTO) throws -> APIEndpoint {
        let body = try JSONEncoder().encode(request)
        return APIEndpoint(path: "/medicines", method: .post, body: body)
    }
    
    static func updateMedicine(id: Int64, request: MedicineCreateUpdateDTO) throws -> APIEndpoint {
        let body = try JSONEncoder().encode(request)
        return APIEndpoint(path: "/medicines/\(id)", method: .put, body: body)
    }
    
    static func pauseMedicine(id: Int64) -> APIEndpoint {
        APIEndpoint(path: "/medicines/\(id)/pause", method: .patch)
    }
    
    static func resumeMedicine(id: Int64) -> APIEndpoint {
        APIEndpoint(path: "/medicines/\(id)/resume", method: .patch)
    }
    
    static func deleteMedicine(id: Int64) -> APIEndpoint {
        APIEndpoint(path: "/medicines/\(id)", method: .delete)
    }
    
    // Dose Endpoints
    static func getTodayDoses() -> APIEndpoint {
        APIEndpoint(path: "/doses/today")
    }
    
    static func markDoseTaken(id: Int64) -> APIEndpoint {
        APIEndpoint(path: "/doses/\(id)/taken", method: .post)
    }
    
    static func markDoseSkipped(id: Int64) -> APIEndpoint {
        APIEndpoint(path: "/doses/\(id)/skipped", method: .post)
    }
    
    static func undoSkipDose(id: Int64) -> APIEndpoint {
        APIEndpoint(path: "/doses/\(id)/undo-skip", method: .post)
    }
    
    static func getHistory(
        status: String? = nil,
        search: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        page: Int = 0,
        size: Int = 50
    ) -> APIEndpoint {
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        if let status = status, status != "ALL" {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        if let search = search, !search.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        if let startDate = startDate {
            queryItems.append(URLQueryItem(name: "startDate", value: startDate))
        }
        if let endDate = endDate {
            queryItems.append(URLQueryItem(name: "endDate", value: endDate))
        }
        return APIEndpoint(path: "/doses/history", queryItems: queryItems)
    }
    
    // Inventory Endpoints
    static func getInventory(medicineId: Int64) -> APIEndpoint {
        APIEndpoint(path: "/medicines/\(medicineId)/inventory")
    }
    
    static func updateInventory(medicineId: Int64, quantity: Int) throws -> APIEndpoint {
        let body = try JSONEncoder().encode(InventoryUpdateDTO(quantity: quantity))
        return APIEndpoint(path: "/medicines/\(medicineId)/inventory", method: .patch, body: body)
    }
    
    static func refillInventory(medicineId: Int64, amount: Int) throws -> APIEndpoint {
        let body = try JSONEncoder().encode(InventoryRefillDTO(refillAmount: amount))
        return APIEndpoint(path: "/medicines/\(medicineId)/inventory/refill", method: .post, body: body)
    }
    
    // Dashboard Endpoint
    static func getDashboard() -> APIEndpoint {
        APIEndpoint(path: "/dashboard")
    }
}
