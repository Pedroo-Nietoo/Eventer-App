import Foundation

struct PaginationMeta: Codable {
    let totalItems: Int
    let itemCount: Int
    let itemsPerPage: Int
    let totalPages: Int
    let currentPage: Int
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let meta: PaginationMeta
}
