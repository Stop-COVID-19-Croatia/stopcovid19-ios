import Foundation
import ExposureNotification

class ConfigurationProvider {
    
    static func checkForUpdate(success: @escaping (Update)-> Void, failure: @escaping (CustomError) -> Void) {
        ApiConnector.request(url: Configuration.updateUrlString, params: nil, method: .get, completion: { (response: UpdateWrapper) in
            success(response.update)
        }) { error in
            failure(error)
        }
    }
    
    static func getExposureConfiguration(completion: (Result<ENExposureConfiguration, Error>) -> Void) {
        let en = ENExposureConfiguration()
        
        en.metadata = ["attenuationDurationThresholds": [50, 70] as [NSNumber]] // Requires iOS 13.6
        en.attenuationWeight = 50
        en.minimumRiskScore = 1
        en.transmissionRiskWeight = 50
        en.daysSinceLastExposureWeight = 50
        en.daysSinceLastExposureLevelValues = [1,2,2,4,6,8,8,8] as [NSNumber]
        en.attenuationLevelValues = [0,0,1,6,6,7,8,8] as [NSNumber]
        en.transmissionRiskLevelValues = [8,8,8,8,8,8,8,8] as [NSNumber]
        en.durationLevelValues = [1,1,5,8,8,8,8,8]
        return completion(.success(en))

    }
}
