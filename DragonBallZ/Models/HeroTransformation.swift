import Foundation

struct HeroTransformation: Codable, Equatable{
    let id: String
    let name: String
    let description: String
    let photo: URL
    let hero:HeroID
}

struct HeroID: Codable, Equatable {
    let id: String
}
