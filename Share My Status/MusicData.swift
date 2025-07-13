import Foundation

struct MusicData: Codable, Hashable, Identifiable {
    let id = UUID()
    let artist: String
    let title: String
    let album: String
    let duration: String
    let artwork: String
    var timestamp: String?
    var result: String?
    var errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case artist, title, album, duration, artwork, timestamp, result, errorMessage
    }
}