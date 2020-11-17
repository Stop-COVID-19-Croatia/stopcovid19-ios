import ObjectMapper

class DiagnosisKeyInput: Mappable {
    
    var temporaryExposureKeys: [TemporaryExposureKeyInput]?
    var regions: [String] = ["HR"]
    var appPackageName: String = Bundle.main.bundleIdentifier ?? Constants.emptyString
    var padding: String = ""
    var consentToFederation: Bool?
    
    init(temporaryExposureKeys: [TemporaryExposureKeyInput]?) {
        self.temporaryExposureKeys = temporaryExposureKeys
        self.consentToFederation = LocalStorage.shared.consentToFederation
    }
    
    func mapping(map: Map) {
        temporaryExposureKeys <- map["temporaryExposureKeys"]
        regions <- map["regions"]
        appPackageName <- map["appPackageName"]
        consentToFederation <- map["consentToFederation"]
    }
    
    required init?(map: Map) { }
}
