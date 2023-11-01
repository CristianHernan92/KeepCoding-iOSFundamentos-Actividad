import Foundation

struct Hero: Codable {
    let id: String
    let name: String
    let description: String
    let photo: URL
    let favorite: Bool
}
