import ObjectMapper

class DiagnosisKeyInput: Mappable {
    
    var temporaryExposureKeys: [TemporaryExposureKeyInput]?
    var regions: [String] = ["HR"]
    var appPackageName: String =  Bundle.main.bundleIdentifier ?? Constants.emptyString
    var padding: String = ""

    init(temporaryExposureKeys: [TemporaryExposureKeyInput]?) {
        self.temporaryExposureKeys = temporaryExposureKeys
    }
    
    func mapping(map: Map) {
        temporaryExposureKeys <- map["temporaryExposureKeys"]
        regions <- map["regions"]
        appPackageName <- map["appPackageName"]
    }
    
    required init?(map: Map) { }
}
