import Foundation

class LinkUtility {
    /// Validates if a string is a valid base URL for the share link system
    /// - Parameter url: The URL string to validate
    /// - Returns: Boolean indicating if the URL is valid
    static func isValidBaseUrl(_ url: String) -> Bool {
        guard !url.isEmpty else { return false }
        guard url.starts(with: "http://") || url.starts(with: "https://") else { return false }
        
        // 检查是否包含u参数
        if let urlComponents = URLComponents(string: url) {
            let queryItems = urlComponents.queryItems ?? []
            return queryItems.contains { $0.name == "u" }
        }
        return false
    }
    
    /// Validates if a string is a valid redirect URL
    /// - Parameter url: The URL string to validate
    /// - Returns: Boolean indicating if the URL is valid
    static func isValidRedirectUrl(_ url: String) -> Bool {
        return url.isEmpty || url.starts(with: "http://") || url.starts(with: "https://")
    }
    
    /// Creates a customized share URL with the given parameters
    /// - Parameters:
    ///   - baseUrl: The base URL string (must start with http:// or https://)
    ///   - redirectUrl: Optional redirect URL
    ///   - displayFormat: Optional display format string with placeholders
    /// - Returns: The customized URL string, or nil if the base URL is invalid
    static func createCustomizedUrl(baseUrl: String, redirectUrl: String?, displayFormat: String?) -> String? {
        guard isValidBaseUrl(baseUrl) else {
            return nil
        }
        
        var components = baseUrl
        
        // Add redirect URL if provided
        if let redirectUrl = redirectUrl, !redirectUrl.isEmpty, isValidRedirectUrl(redirectUrl) {
            if let encodedRedirectUrl = redirectUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                // Check if base URL already has query parameters
                let separator = components.contains("?") ? "&" : "?"
                components += separator + "r=" + encodedRedirectUrl
            }
        }
        
        // Add display format if provided
        if let displayFormat = displayFormat, !displayFormat.isEmpty {
            if let encodedDisplayFormat = displayFormat.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                // Check if we need to add ? or &
                let separator = components.contains("?") ? "&" : "?"
                components += separator + "m=" + encodedDisplayFormat
            }
        }
        
        return components
    }
    
    /// Formats the display text by replacing placeholders with actual music data
    /// - Parameters:
    ///   - format: The format string with placeholders
    ///   - artist: The artist name to replace {artist} placeholder
    ///   - title: The track title to replace {title} placeholder
    ///   - album: The album name to replace {album} placeholder
    /// - Returns: The formatted display text
    static func formatDisplayText(format: String, artist: String, title: String, album: String) -> String {
        var result = format
        result = result.replacingOccurrences(of: "{artist}", with: artist)
        result = result.replacingOccurrences(of: "{title}", with: title)
        result = result.replacingOccurrences(of: "{album}", with: album)
        return result
    }
    
    /// Attempts to parse a customized URL and extract its components
    /// - Parameter url: The customized URL to parse
    /// - Returns: A tuple containing the base URL, redirect URL (if any), and display format (if any)
    static func parseCustomizedUrl(_ url: String) -> (baseUrl: String, redirectUrl: String?, displayFormat: String?)? {
        guard let urlComponents = URLComponents(string: url) else {
            return nil
        }
        
        // Extract the query parameters
        let queryItems = urlComponents.queryItems ?? []
        
        // Find the redirect URL (r parameter)
        let rValue = queryItems.first(where: { $0.name == "r" })?.value
        
        // Find the display format (m parameter)
        let mValue = queryItems.first(where: { $0.name == "m" })?.value
        
        // Remove r and m parameters to get the base URL
        var baseUrlComponents = urlComponents
        baseUrlComponents.queryItems = queryItems.filter { $0.name != "r" && $0.name != "m" }
        
        guard let baseUrl = baseUrlComponents.url?.absoluteString else {
            return nil
        }
        
        // Decode the display format if it exists
        let displayFormat = mValue?.removingPercentEncoding
        
        // Decode the redirect URL if it exists
        let redirectUrl = rValue?.removingPercentEncoding
        
        return (baseUrl, redirectUrl, displayFormat)
    }
}