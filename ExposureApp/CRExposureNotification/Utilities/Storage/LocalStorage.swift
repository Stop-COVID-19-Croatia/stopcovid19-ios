import Foundation

class LocalStorage {
    
    static let shared = LocalStorage()
        
    @Storable(userDefaultsKey: "dateLastPerformedExposureDetection", defaultValue: nil)
    var dateLastPerformedExposureDetection: Date?
    
    @Storable(userDefaultsKey: "exposureDetectionErrorLocalizedDescription", defaultValue: nil)
    var exposureDetectionErrorLocalizedDescription: String?
  
    @Storable(userDefaultsKey: "urlCheckedList", defaultValue: [])
    var urlCheckedList: [String]
    
    @Storable(userDefaultsKey: "transmissionRisk", defaultValue: nil)
    var transmissionRisk: TransmissionRisk?
    
    @Storable(userDefaultsKey: "passedEnableExposure", defaultValue: nil)
    var passedEnableExposure: Bool?
    
    @Storable(userDefaultsKey: "onboardingPassed", defaultValue: false)
    var onboardingPassed: Bool
}
