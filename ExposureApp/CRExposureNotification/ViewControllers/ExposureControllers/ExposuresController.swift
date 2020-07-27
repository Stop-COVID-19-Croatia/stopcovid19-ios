import UIKit
import ExposureNotification

class ExposuresController: UIViewController {
    
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ivStatus: UIImageView!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    @IBOutlet weak var exposureDetectionContainer: UIView!
    @IBOutlet weak var exposureInfoContainer: UIView!
    @IBOutlet weak var ivExposureInfo: UIImageView!
    @IBOutlet weak var lblExposureInfo: UILabel!
    @IBOutlet weak var lblNoItem: UILabel!
    @IBOutlet weak var statusContainerView: UIView!
    @IBOutlet weak var btnDebugInfo: UIButton!

    private var transmisionRisk: TransmissionRisk?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupExposureInfo), name: .updateExposureController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlingBluetooth), name: .updateBluetooth, object: nil)
        setupExposureInfo()
        setupLanguage()
        setupExposureNotificationStatusView(status: ExposureManager.shared.manager.exposureNotificationEnabled)
        handlingBluetooth()
        if btnDebugInfo != nil && Configuration.isProduction{
            btnDebugInfo.removeFromSuperview()
        }
    }
    
    @objc private func setupExposureInfo(){
        guard let transmissionRisk = LocalStorage.shared.transmissionRisk else {
            lblNoItem.isHidden = false
            exposureInfoContainer.isHidden = true
            return
        }
        lblNoItem.isHidden = true
        exposureInfoContainer.isHidden = false
        
        self.transmisionRisk = transmissionRisk
        lblExposureInfo.text = transmissionRisk.riskTitle

        if transmissionRisk.riskType == .highRisk {
            ivExposureInfo.image = UIImage(named: "icon-risk-high-details")
        } else {
            ivExposureInfo.image = UIImage(named: "icon-risk-details")
        }
    }
    
    private func setupLanguage() {
        titleLabel.text = "ExposuresController.Title".localized()
        languageLabel.text = Language.getDefaultLanguage().shortTitle?.uppercased()
    }
    
    private func setupExposureNotificationStatusView(status: Bool) {
        if status {
            statusContainerView.backgroundColor = .primaryGreen
            statusSwitch.setOn(true, animated: true)
            statusLabel.text = "ExposuresController.On".localized()
            ivStatus.image = UIImage(named: "icon-contacts")
            lblNoItem.text = "ExposuresController.OnMessage".localized()
            statusLabel.textColor = .white
        } else {
            statusContainerView.backgroundColor = .backgroundLightGray
            statusSwitch.setOn(false, animated: true)
            statusLabel.text = "ExposuresController.Off".localized()
            ivStatus.image = UIImage(named: "icon-nocontacts")
            lblNoItem.text = "ExposuresController.OffMessage".localized()
            statusLabel.textColor = .black
        }
    }
    
    @objc private func handlingBluetooth(){
        if ExposureManager.getAuthorizationStatus() == .authorized {
            setupExposureNotificationStatusView(status: !ExposureManager.isBluetoothOff())
        }
    }
    
    @IBAction func changeLanguage() {
        if Language.getDefaultLanguage().languageType == .english {
            Language.setDefaultLanguage(language: Language.findLanguageByType(languageType: .croatian))
        } else {
            Language.setDefaultLanguage(language: Language.findLanguageByType(languageType: .english))
        }
        if let controller = self.tabBarController as? TabbarController{
            controller.languageChanged()
        }
        setup()
    }
    
    @IBAction func exposuresSwitch() {
        if ExposureManager.isBluetoothOff(){
            setupExposureNotificationStatusView(status: false)
            UIUtil.showErrorAlert(viewController: self, message: "ExposuresController.BluetoothOff".localized())
            return
        }
        ExposureManager.setEnableExposureNotifications(isEnabled: !statusSwitch.isOn, completionHandler: { (granted, error) in
            DispatchQueue.main.async {
                if LocalStorage.shared.passedEnableExposure == nil {
                    LocalStorage.shared.passedEnableExposure = true
                    if ExposureManager.getAuthorizationStatus() == .authorized {
                        self.setupExposureNotificationStatusView(status: !self.statusSwitch.isOn)
                        self.setupLanguage()
                    }
                    return
                }
                if granted {
                    self.view.window?.windowScene?.open(URL(string: UIApplication.openSettingsURLString)!, options: nil, completionHandler: nil)
                } else {
                    if ExposureManager.getAuthorizationStatus() == .notAuthorized {
                         self.view.window?.windowScene?.open(URL(string: UIApplication.openSettingsURLString)!, options: nil, completionHandler: nil)
                    } else {
                        ErrorHandler.handle(error: error ?? CustomError(), in: self)
                    }
                }
            }
        })
    }
        
    deinit {
        print("DEINIT ExposureController")
    }
    
    @IBAction func previewExposure(_ sender: UIButton){
        if let transmisionRisk = transmisionRisk {
            self.present(ExposuresDetailsController.instantiate(transmisionRisk: transmisionRisk), animated: true, completion: nil)
        }
    }
}
