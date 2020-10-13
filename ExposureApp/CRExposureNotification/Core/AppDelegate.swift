import UIKit
import ExposureNotification
import BackgroundTasks
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static let backgroundTaskIdentifier = Bundle.main.bundleIdentifier! + ".exposure-notification"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Language.setDefaultLanguage(language: Language.getDefaultLanguage())
        UNUserNotificationCenter.current().delegate = self
        _ = ExposureManager.shared
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppDelegate.backgroundTaskIdentifier, using: .main) { task in
            NotificationsManager.shared.showBluetoothOffUserNotificationIfNeeded()
            
            let progress = ExposureManager.shared.detectExposures { success in
                task.setTaskCompleted(success: success)
            }
            
            task.expirationHandler = {
                progress.cancel()
                LocalStorage.shared.exposureDetectionErrorLocalizedDescription = NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error")
            }
            
            AppDelegate.scheduleBackgroundTaskIfNeeded()
        }
        
        AppDelegate.scheduleBackgroundTaskIfNeeded()
        setupAppearance()
        UIUtil.presentInitialController()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: .updateBluetooth, object: nil)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: .updateBluetooth, object: nil)
        }
    }
    
    private func setupAppearance() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.sfCompactRegular(ofSize: 14)], for: .normal)
    }
    
    public func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, _) in
            if granted  {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                            UNUserNotificationCenter.current().delegate = self
                        }
                    }
                }
            }
        })
    }
    
    static func scheduleBackgroundTaskIfNeeded() {
        guard ENManager.authorizationStatus == .authorized else {
            return
        }
        let taskRequest = BGProcessingTaskRequest(identifier: AppDelegate.backgroundTaskIdentifier)
        taskRequest.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            print("Unable to schedule background task: \(error)")
            
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        UIUtil.presentMainController()
    }
}

