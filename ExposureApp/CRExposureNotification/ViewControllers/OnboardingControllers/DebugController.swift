import UIKit
import ExposureNotification
class DebugController: UIViewController {
    
    @IBOutlet weak var lblInfo: UILabel!
    
    var uniqUrlList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let progress = detectExposures { success in
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
                    lblInfo.text! += "maximumRiskScoreFullRange: \(transmissionRisk.maximumRiskScoreFullRange)\n"
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
        
        lblInfo.text! += "Fetching urls... \n"
        ExposuresProvider.getUrls(success: { (response) in
            self.lblInfo.text! += "Successfully fetch urls\n "
            let dispatchGroup = DispatchGroup()
            var localURLResults = [Result<[URL], Error>]()
            for i in 0..<response.uniqUrlList.count {
                dispatchGroup.enter()
                let remoteUrl = response.uniqUrlList[i]
                
                ExposuresProvider.downloadDiagnosisKeyFile(zipName: i.description, at: remoteUrl) { result in
                    self.lblInfo.text! += "\(i.description).Downloaded: \(remoteUrl) \n"
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
                self.lblInfo.text! += "Zips downloaded successfully  \(localURLs.count.description)\n"
                self.lblInfo.text! += "Getting configuration \n"
                ConfigurationProvider.getExposureConfiguration { result in
                    switch result {
                    case let .success(configuration):
                        self.lblInfo.text! += "Successfully fetch configuration \nPost urls to Exposures API\n"

                        ExposureManager.shared.manager.detectExposures(configuration: configuration, diagnosisKeyURLs: localURLs) { summary, error in
                            if let error = error {
                                self.lblInfo.text! = "Error: \(String(describing: error.localizedDescription))"
                                finish(.failure(error))
                                return
                            }
                            self.lblInfo.text! += "DetectExposures successfully summary: \n \(summary.debugDescription)\n"

                            let transmissionRisk = TransmissionRisk(summary: summary!)
                            finish(.success((transmissionRisk, response.uniqUrlList)))
                        }
                        
                    case let .failure(error):
                        self.lblInfo.text! = "Error: \(String(describing: error.localizedDescription))"
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
    
    @IBAction func close(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
