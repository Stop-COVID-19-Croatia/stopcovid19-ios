import ExposureNotification
import ObjectMapper

class TemporaryExposureKeyInput: Mappable {
    
    var key: String?
    var rollingStartNumber: ENIntervalNumber?
    var rollingPeriod: ENIntervalNumber?
    var transmissionRisk: ENRiskLevel?
    
    init(key: Data, rollingStartNumber: ENIntervalNumber, rollingPeriod: ENIntervalNumber, transmissionRisk: ENRiskLevel) {
        self.key = key.base64EncodedString()
        self.rollingStartNumber = rollingStartNumber
        self.rollingPeriod = rollingPeriod
        self.transmissionRisk = transmissionRisk
    }
    
    func mapping(map: Map) {
        key <- map["key"]
        rollingStartNumber <- map["rollingStartNumber"]
        rollingPeriod <- map["rollingPeriod"]
        transmissionRisk <- map["transmissionRisk"]
    }
    
    required init?(map: Map) { }
}
