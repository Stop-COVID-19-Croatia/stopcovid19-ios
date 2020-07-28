import Foundation
import UIKit
import ExposureNotification

extension Notification.Name {
    static let updateExposureController = Notification.Name(NotificationEnum.updateExposureController.rawValue)
    static let updateBluetooth = Notification.Name(NotificationEnum.updateBluetooth.rawValue)
}

class ExposureManager {
    
    static let shared = ExposureManager()
    let manager = ENManager()
    
    init() {
        manager.activate { _ in
            if ENManager.authorizationStatus == .authorized && !self.manager.exposureNotificationEnabled {
                self.manager.setExposureNotificationEnabled(true) { _ in
                }
            }
        }
    }
    
    static func getAuthorizationStatus() -> ENAuthorizationStatus {
        return ENManager.authorizationStatus
    }
    
    static func isBluetoothOff() -> Bool {
        return ENManager.authorizationStatus == .authorized && ExposureManager.shared.manager.exposureNotificationStatus == .bluetoothOff 
    }
    
    static func setEnableExposureNotifications(isEnabled: Bool, completionHandler: @escaping (Bool, CustomError?) -> Void) {
        ExposureManager.shared.manager.setExposureNotificationEnabled(isEnabled) { error in
            let customError = error != nil ? CustomError(error: error?.localizedDescription ?? Constants.emptyStringPreview, errorCode: .internalExposure) : nil
            completionHandler(error == nil, customError)
        }
    }
    
    static func getTemporaryExposureKeys(completionHandler: @escaping ([TemporaryExposureKeyInput], CustomError?) -> Void) {
        if !Configuration.isProduction {
            getTemporaryExposureKeysForTesting(completionHandler: completionHandler)
            return
        }
        ExposureManager.shared.manager.getDiagnosisKeys { (temporaryExposureKeys, error) in
            var keys: [TemporaryExposureKeyInput] = []
            for key in temporaryExposureKeys ?? [] {
                keys.append(TemporaryExposureKeyInput(key: key.keyData,
                                                      rollingStartNumber: key.rollingStartNumber,
                                                      rollingPeriod: key.rollingPeriod,
                                                      transmissionRisk: key.transmissionRiskLevel))
            }
            
            let customError = error != nil ? CustomError(error: error?.localizedDescription ?? Constants.emptyStringPreview, errorCode: .internalExposure) : nil
            completionHandler(keys, customError)
        }
        
    }
    
    static func getTemporaryExposureKeysForTesting(completionHandler: @escaping ([TemporaryExposureKeyInput], CustomError?) -> Void) {
        ExposureManager.shared.manager.getTestDiagnosisKeys { (temporaryExposureKeys, error) in
            var keys: [TemporaryExposureKeyInput] = []
            for key in temporaryExposureKeys ?? [] {
                keys.append(TemporaryExposureKeyInput(key: key.keyData,
                                                      rollingStartNumber: key.rollingStartNumber,
                                                      rollingPeriod: key.rollingPeriod,
                                                      transmissionRisk: key.transmissionRiskLevel))
            }
            
            let customError = error != nil ? CustomError(error: error?.localizedDescription ?? Constants.emptyStringPreview, errorCode: .internalExposure) : nil
            completionHandler(keys, customError)
        }
        
    }
    
    var detectingExposures = false
    
    func detectExposures(completionHandler: ((Bool) -> Void)? = nil) -> Progress {
        
        let progress = Progress()
        
        guard !detectingExposures else {
            detectingExposures = false
            completionHandler?(false)
            return progress
        }
        detectingExposures = true
        
        var localURLs = [URL]()
        
        func finish(_ result: Result<(TransmissionRisk, [String]), Error>) {
            
            try? deleteDiagnosisKeyFile(at: localURLs)
            
            let success: Bool
            if progress.isCancelled {
                success = false
            } else {
                switch result {
                case let .success((transmissionRisk, urlCheckedList)):
                    if let transRisk = LocalStorage.shared.transmissionRisk {
                        if transRisk.maximumRiskScoreFullRange <= transmissionRisk.maximumRiskScoreFullRange && transmissionRisk.maximumRiskScoreFullRange != 0{
                            LocalStorage.shared.transmissionRisk = transmissionRisk
                            self.scheduleNotification(transmissionRisk: transmissionRisk)
                        }
                    } else {
                        if LocalStorage.shared.transmissionRisk == nil && transmissionRisk.maximumRiskScoreFullRange != 0 {
                            LocalStorage.shared.transmissionRisk = transmissionRisk
                            self.scheduleNotification(transmissionRisk: transmissionRisk)
                        }
                    }
                    LocalStorage.shared.dateLastPerformedExposureDetection = Date()
                    LocalStorage.shared.exposureDetectionErrorLocalizedDescription = nil
                    LocalStorage.shared.urlCheckedList.append(contentsOf: urlCheckedList)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationEnum.updateExposureController.rawValue), object: nil)
                    success = true
                case let .failure(error):
                    LocalStorage.shared.exposureDetectionErrorLocalizedDescription = error.localizedDescription
                    success = false
                }
            }
            
            detectingExposures = false
            completionHandler?(success)
        }
        
        ExposuresProvider.getUrls(success: { (response) in
            let dispatchGroup = DispatchGroup()
            var localURLResults = [Result<[URL], Error>]()
            for i in 0..<response.uniqUrlList.count {
                dispatchGroup.enter()
                let remoteUrl = response.uniqUrlList[i]
                ExposuresProvider.downloadDiagnosisKeyFile(zipName: i.description, at: remoteUrl) { result in
                    localURLResults.append(result)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                for result in localURLResults {
                    switch result {
                    case let .success(urls):
                        localURLs.append(contentsOf: urls)
                    case let .failure(error):
                        finish(.failure(error))
                        return
                    }
                }
                ConfigurationProvider.getExposureConfiguration { result in
                    switch result {
                    case let .success(configuration):
                        ExposureManager.shared.manager.detectExposures(configuration: configuration, diagnosisKeyURLs: localURLs) { summary, error in
                            if let error = error {
                                finish(.failure(error))
                                return
                            }
                            
                            let transmissionRisk = TransmissionRisk(summary: summary!)
                            
                            finish(.success((transmissionRisk, response.uniqUrlList)))
                        }
                        
                    case let .failure(error):
                        finish(.failure(error))
                    }
                }
            }
        }) { (error) in
            
        }
        return progress
    }
    
    private func deleteDiagnosisKeyFile(at localURLs: [URL]) throws {
        for localURL in localURLs {
            try FileManager.default.removeItem(at: localURL)
        }
    }
    
    private func scheduleNotification(transmissionRisk: TransmissionRisk) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = transmissionRisk.riskTitle
        content.body = transmissionRisk.riskShortDescription
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    deinit {
        manager.invalidate()
    }
}
