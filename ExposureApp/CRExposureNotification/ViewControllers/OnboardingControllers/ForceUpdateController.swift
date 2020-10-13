import UIKit

class ForceUpdateController: UIViewController {
    
    @IBOutlet weak var ivTopImage: UIImageView!
    
    static func instantiate() -> ForceUpdateController {
        let controller = UIUtil.controllerFromStoryboard(storyboard: .onboarding, controller: .forceUpdateController) as! ForceUpdateController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        if Language.getDefaultLanguage().languageType == .english{
            ivTopImage.image = UIImage(named: "Ministvarstvo-logo-EN")
        } else {
            ivTopImage.image = UIImage(named: "Ministvarstvo-logo-HR")
        }
    }
    
    @IBAction func goToAppStore(_ sender: UIButton) {
        if let anURL = URL(string: Configuration.installationUrl) {
            UIApplication.shared.open(anURL)
        }
    }
}
