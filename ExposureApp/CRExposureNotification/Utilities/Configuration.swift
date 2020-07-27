import Foundation

class Configuration {
    
    static var isProduction: Bool {
        return Bundle.main.infoDictionary?["Production"] as! Bool
    }
    
    static var configurationDictionary: [String:String] {
        get {
            return Bundle.main.infoDictionary?["Configuration"] as! [String:String]
        }
    }
    
    static var urlScheme: String? {
        get {
            return configurationDictionary["Scheme"]
        }
    }
    
    static var urlHost: String? {
        get {
            return isProduction ? configurationDictionary["ProductionHost"] : configurationDictionary["DevelopmentHost"]
        }
    }
    
    static var updateUrlString: String {
        if let updateUrlString = Bundle.main.infoDictionary?["CheckUpdateVersionUrl"] as? String{
            return updateUrlString
        }
        return Constants.emptyString
    }
    
    static var installationUrl: String {
        if let updateUrlString = Bundle.main.infoDictionary?["InstallationUrl"] as? String{
            return updateUrlString
        }
        return Constants.emptyString
    }
    
    private static var apiURL: URLComponents?
    static var URL: URLComponents = {
        if apiURL == nil {
            var urlComponents = URLComponents()
            urlComponents.scheme = urlScheme
            urlComponents.host = urlHost
            apiURL = urlComponents
            return apiURL!
        }
        return apiURL!
    }()

    static func URLCreator(path: String,_ parameters: URLQueryItem...) -> String {
        var url = URL
        url.path = path
        url.queryItems = parameters.compactMap({ $0 })
        return url.url?.absoluteString ?? ""
    }
    
    private static let appendingFormat = "%@/%@"
    static func URLCreator(path: String, component: String? = nil) -> String {
        var url = URL
        if let value = component {
            let path = String(format: appendingFormat, path, value)
            url.path = path
            return url.url?.absoluteString ?? ""
        }
        url.path = path
        return url.url?.absoluteString ?? ""
    }
}
