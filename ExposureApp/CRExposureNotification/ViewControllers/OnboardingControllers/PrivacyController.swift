import UIKit

class PrivacyController: UIViewController {
    
    static func instantiate() -> PrivacyController {
        let controller = UIUtil.controllerFromStoryboard(storyboard: .onboarding, controller: .privacyController) as! PrivacyController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func next(_ sender: UIButton){
        UIUtil.setTabs(selectedIndex: 0)
    }
}
