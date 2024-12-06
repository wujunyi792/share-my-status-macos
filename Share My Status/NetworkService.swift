import Foundation
import Alamofire

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
        
        print("正在发送请求到: \(settings.endpointURL)")
        
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
                    print("音乐状态更新成功")
                    continuation.resume(returning: ())
                case .failure(let error):
                    print("音乐状态更新失败: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("服务器响应: \(str)")
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}