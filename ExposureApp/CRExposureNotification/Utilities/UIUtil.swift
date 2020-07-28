import UIKit

class UIUtil {
    
    static func controllerFromStoryboard<T:UIViewController>(storyboard: StoryboardNameEnum, controller: ViewControllersNameEnum) -> T? {
        let storyboard = UIStoryboard(name: storyboard.rawValue ,bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: controller.rawValue) as? T
        return controller
    }
    
    static func presentMainController() {
        if !(Storage.readObject(key: StorageKeys.onboardingPassed) as? Bool ?? false) {
            UIUtil.presentOnboardingInitialController()
            return
        }
        
        if ExposureManager.getAuthorizationStatus() == .authorized {
           setTabs(selectedIndex: 0)
        } else {
            UIUtil.presentPrivacyController()
        }
    }
    
    static func presentInitialController() {
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            appdelegate.window?.rootViewController = InitialController.instantiate()
        }
    }
    
    static func presentOnboardingInitialController() {
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            appdelegate.window?.rootViewController = OnboardingInitialController.instantiate()
        }
    }
    
    static func presentPrivacyController() {
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            appdelegate.window?.rootViewController = PrivacyController.instantiate()
        }
    }
    
    static func presentForceUpdateController() {
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            appdelegate.window?.rootViewController = ForceUpdateController.instantiate()
        }
    }
    
    static func setTabs(selectedIndex: Int? = nil) {
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            let storyboard =  UIStoryboard(name: StoryboardNameEnum.main.rawValue, bundle: .main)
            let tabcontroller = storyboard.instantiateInitialViewController() as! UITabBarController
            if let index = selectedIndex {
                tabcontroller.selectedIndex = index
            }
            appdelegate.window?.rootViewController = tabcontroller
        }
    }
    
    public static func showInfoAlertWithHandler(viewController: UIViewController,
                                                title: String? = "AlertInfo.Title",
                                                negativeBtnText: String? = "AlertInfo.NegativeText",
                                                positiveBtnText: String? = "AlertInfo.PositiveText",
                                                messageText: String,
                                                didChoosePositive: @escaping () -> Void,
                                                didChooseNegative: @escaping () -> Void) {
        let alert = UIAlertController(title: title?.localized(), message: messageText.localized(), preferredStyle: .alert)
        let yesButton = UIAlertAction(title: positiveBtnText?.localized(), style: .default, handler: { _ in
            didChoosePositive()
        })
        let noAction = UIAlertAction(title: negativeBtnText?.localized(), style: .default, handler: { _ in
            didChooseNegative()
        })
        alert.addAction(noAction)
        alert.addAction(yesButton)
        viewController.present(alert, animated: true)
    }
    
    public static func showInfoAlertWithHandler(viewController: UIViewController,
                                                title: String?,
                                                positiveBtnText: String? = "AlertInfo.PositiveText",
                                                messageText: String,
                                                didChoosePositive: @escaping () -> Void) {
        let alert = UIAlertController(title: title?.localized() ?? "", message: messageText.localized(), preferredStyle: .alert)
        let yesButton = UIAlertAction(title: positiveBtnText?.localized(), style: .default, handler: { _ in
            didChoosePositive()
        })
        
        alert.addAction(yesButton)
        viewController.present(alert, animated: true)
    }
    
    static func showErrorAlert(viewController: UIViewController, title: String? = "ErrorAlert.Title", message: String) {
        let alert = UIAlertController(title: title?.localized(), message: message, preferredStyle: .alert)
        let okayButton = UIAlertAction(title: "ErrorAlert.PositiveText".localized(), style: .default)
        alert.addAction(okayButton)
        viewController.present(alert, animated: true, completion: nil)
    }
}
