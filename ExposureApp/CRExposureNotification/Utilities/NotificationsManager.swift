import Foundation
import UserNotifications
import ExposureNotification

class NotificationsManager {
    
    static let shared = NotificationsManager()
    
    func showBluetoothOffUserNotificationIfNeeded() {
        let identifier = "bluetooth-off"
        if ENManager.authorizationStatus == .authorized && ExposureManager.shared.manager.exposureNotificationStatus == .bluetoothOff {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("Exposure Notifications inactive", comment: "User notification title")
            content.body = NSLocalizedString("To use this feature, turn on Bluetooth", comment: "User notification")
            content.sound = .default
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error showing error user notification: \(error)")
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        }
    }
}
