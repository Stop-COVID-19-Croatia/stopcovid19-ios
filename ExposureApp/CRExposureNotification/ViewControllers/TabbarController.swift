import UIKit

class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            appdelegate.setupNotifications()
        }
    }
    
    public func languageChanged(){
        if let controller = self.viewControllers?.first {
            controller.title = "TabbarController.Exposures".localized()
        }
        
        if let controller = self.viewControllers?.elementOrNil(at: 1) {
            controller.title = "TabbarController.NotifyOthers".localized()
        }
    }
}

public extension Array {
    func elementOrNil(at index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
