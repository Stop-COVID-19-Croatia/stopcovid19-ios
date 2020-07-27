import UIKit

class InitialController: UIViewController {
    
    @IBOutlet weak var ivTopImage: UIImageView!
    @IBOutlet weak var ivMiddleImage: UIImageView!
    @IBOutlet weak var ivBottomImage: UIImageView!
    
    static func instantiate() -> InitialController {
        return UIUtil.controllerFromStoryboard(storyboard: .onboarding, controller: .initialController) as! InitialController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpleshScreen()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.checkForUpdate()
        }
    }
    
    private func checkForUpdate(){
        ConfigurationProvider.checkForUpdate(success: { (response) in
            DispatchQueue.main.async {
                if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                    let minorMajorCurrentVersion = self.matches(for: ".*(?=\\.)", in: currentVersion).first,
                    let serverVersion = response.version,
                    let minorMajorServerVersion = self.matches(for: ".*(?=\\.)", in: serverVersion).first{
                    if minorMajorCurrentVersion.compare(minorMajorServerVersion, options: .numeric ) == .orderedAscending {
                        UIUtil.presentForceUpdateController()
                        return
                    }
                }
                
                UIUtil.presentMainController()
            }
        }) { (error) in
            DispatchQueue.main.async {
                UIUtil.presentMainController()
            }
        }
        
    }
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    private func setupSpleshScreen(){
        if Language.getDefaultLanguage().languageType == .english{
            ivTopImage.image = UIImage(named: "Ministvarstvo-logo-EN")
            ivMiddleImage.image = UIImage(named: "Logo-EN")
            ivBottomImage.image = UIImage(named: "apis-image-transparent")
        } else {
            ivTopImage.image = UIImage(named: "Ministvarstvo-logo-HR")
            ivMiddleImage.image = UIImage(named: "Logo-HR")
            ivBottomImage.image = UIImage(named: "apis-image-transparent")
        }
    }
    
}
