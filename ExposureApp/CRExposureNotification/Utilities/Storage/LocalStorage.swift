import Foundation

class LocalStorage {
    
    static let shared = LocalStorage()
    
    @Storable(userDefaultsKey: "dateLastPerformedExposureDetection", defaultValue: nil)
    var dateLastPerformedExposureDetection: Date?
    
    @Storable(userDefaultsKey: "exposureDetectionErrorLocalizedDescription", defaultValue: nil)
    var exposureDetectionErrorLocalizedDescription: String?
    
    @Storable(userDefaultsKey: "urlCheckedList", defaultValue: [])
    private var urlCheckedList: [String]
    
    @Storable(userDefaultsKey: "transmissionRisk", defaultValue: nil)
    var transmissionRisk: TransmissionRisk?
    
    @Storable(userDefaultsKey: "passedEnableExposure", defaultValue: nil)
    var passedEnableExposure: Bool?
    
    @Storable(userDefaultsKey: "onboardingPassed", defaultValue: false)
    var onboardingPassed: Bool
    
    @Storable(userDefaultsKey: "consentToFederation", defaultValue: false)
    var consentToFederation: Bool
    
    var urlUniqCheckedList: [String] {
        get {
            return urlCheckedList
        }
        set {
            
            var urls:[String] = []
            for url in newValue {
                if url.contains("-HR-") {
                    urls.append(url.replacingOccurrences(of: "-HR-", with: "-"))
                } else if url.contains("-EU-"){
                    urls.append(url.replacingOccurrences(of: "-EU-", with: "-"))
                } else {
                    urls.append(url)
                }
            }
            urlCheckedList = urls.removingDuplicates()
        }
    }
    
    func updateTransmissionRisk() {
        if var trans =  LocalStorage.shared.transmissionRisk,
            trans.dateOfExposure == nil {
            trans.dateOfExposure = Date(milliseconds: Date().millisecondsSince1970  - Int64((trans.daysSinceLastExposure! * 24 * 60 * 60 * 1000)))
            LocalStorage.shared.transmissionRisk = trans
        }
    }
}
