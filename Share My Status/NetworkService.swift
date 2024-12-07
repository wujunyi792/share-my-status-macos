import Foundation
import Alamofire

enum NetworkError: LocalizedError {
    case serverError(description: String)
    
    var errorDescription: String? {
        switch self {
        case .serverError(let description):
            return description
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    func sendMusicActivity(settings: Settings, musicData: MusicData) async throws {        
        // 准备请求参数
        let parameters: [String: Any] = [
            "key": settings.apiKey,
            "type": "music",
            "musicData": [
                "artist": musicData.artist,
                "title": musicData.title,
                "album": musicData.album,
                "duration": musicData.duration,
                "artwork": musicData.artwork
            ]
        ]
        
        // 准备请求头
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
//        print("正在发送请求到: \(settings.endpointURL)")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(settings.endpointURL,
                      method: .post,
                      parameters: parameters,
                      encoding: JSONEncoding.default,
                      headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(_):
                    continuation.resume(returning: ())
                case .failure(let error):
                    let errorDescription = error.localizedDescription
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        let combinedDescription = "\(errorDescription) - 服务器响应: \(str)"
                        continuation.resume(throwing: NetworkError.serverError(description: combinedDescription))
                    } else {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
