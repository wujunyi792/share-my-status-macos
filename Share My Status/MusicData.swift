struct MusicData: Codable, Hashable {
    let artist: String
    let title: String
    let album: String
    let duration: String
    let artwork: String
    var timestamp: String?
    var result: String?
    var errorMessage: String?
} 