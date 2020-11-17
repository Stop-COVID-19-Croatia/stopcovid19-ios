import UIKit

class TabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            appdelegate.setupNotifications()
            languageChanged()
        }
    }
    
    public func languageChanged() {
        if let controller = self.viewControllers?[0] {
            controller.title = "TabbarController.Exposures".localized()
        }
        
        if let controller = self.viewControllers?[1] {
            controller.title = "TabbarController.NotifyOthers".localized()
        }
    }
}
