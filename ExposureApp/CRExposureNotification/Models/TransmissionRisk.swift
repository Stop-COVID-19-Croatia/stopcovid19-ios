import UIKit
import ExposureNotification

struct TransmissionRisk: Codable {
    static let VALID_TIME_FRAME = 15 * 24 * 60 * 60 * 1000
    
    var riskType: TransmissionRiskEnum = .lowRisk
    var daysSinceLastExposure: Int?
    var maximumRiskScoreFullRange: Int = 0
    var matchedKeyCount: UInt64 = 0
    var dateOfExposure: Date?
    
    init(summary: ENExposureDetectionSummary) {
        matchedKeyCount = summary.matchedKeyCount
        daysSinceLastExposure =  summary.daysSinceLastExposure
        dateOfLastExposure = Date()
        if let result = summary.metadata?["maximumRiskScoreFullRange"] as? Int {
            maximumRiskScoreFullRange = result
        }
        if maximumRiskScoreFullRange < TransmissionRiskEnum.mediumRisk.rawValue {
            riskType = .lowRisk
        } else if (maximumRiskScoreFullRange >= TransmissionRiskEnum.mediumRisk.rawValue && maximumRiskScoreFullRange < TransmissionRiskEnum.highRisk.rawValue) {
            riskType = .mediumRisk
        } else if maximumRiskScoreFullRange >= TransmissionRiskEnum.highRisk.rawValue {
            riskType = .highRisk
        }
    }
    
    var riskTitle : String {
        get {
            switch riskType {
            case .lowRisk:
                return "TransmissionRisk.TitleLow".localized()
            case .mediumRisk:
                return "TransmissionRisk.TitleMedium".localized()
            case .highRisk:
                return "TransmissionRisk.TitleHigh".localized()
            }
        }
    }
    
    var riskShortDescription : String {
        get {
            switch riskType {
            case .lowRisk:
                return "TransmissionRisk.RiskShortDescriptionLow".localized()
            case .mediumRisk:
                return "TransmissionRisk.RiskShortDescriptionMedium".localized()
            case .highRisk:
                return "TransmissionRisk.RiskShortDescriptionHigh".localized()
            }
        }
    }
    
    var information : String {
        get {
            return String(format: "ExposuresDetailsController.YouHaveBeenInContact".localized(), dateOfLastExposure.stringDMYFormat())
        }
    }
    
    var dateOfLastExposure : Date {
        get {
            return dateOfExposure ?? Date()
        }
        
        set {
            let currentDate = newValue.millisecondsSince1970  - Int64((daysSinceLastExposure! * 24 * 60 * 60 * 1000))
            dateOfExposure = Date(milliseconds: currentDate)
        }
    }
    
    var valid: Bool {
        get {
            return Date().millisecondsSince1970 - dateOfLastExposure.millisecondsSince1970 < TransmissionRisk.VALID_TIME_FRAME
        }
    }
    
    var riskLongDescription : String {
        get {
            switch riskType {
            case .lowRisk:
                return "TransmissionRisk.RiskLongDescriptionLow".localized()
            case .mediumRisk:
                return "TransmissionRisk.RiskLongDescriptionMedium".localized()
            case .highRisk:
                return "TransmissionRisk.RiskLongDescriptionHigh".localized()
            }
        }
    }
}
