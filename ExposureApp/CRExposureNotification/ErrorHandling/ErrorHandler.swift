import UIKit

class ErrorHandler: NSObject {
    
    private static let internalErrorKey = "ErrorHandler.InternalError"
    private static let noInternetErrorKey = "ErrorHandler.NoInternetError"
    static func handle(error: CustomError, in controller: UIViewController) {
        guard let statusCode = error.errorCode else {
            UIUtil.showErrorAlert(viewController: controller, message: ErrorHandler.internalErrorKey.localized())
            return
        }
        switch statusCode {
        case .forbiddenHttp:
            if let error = error.errorMessage,
                error == "Code expired" {
                UIUtil.showErrorAlert(viewController: controller, message: "ErrorHandler.Expired".localized())
            } else {
                UIUtil.showErrorAlert(viewController: controller, message: "ErrorHandler.Invalid".localized())
            }
            break
        case .validationHttp:
            UIUtil.showErrorAlert(viewController: controller, message: "ErrorHandler.InvalidCall".localized())
            break
        case .internalExposure:
            UIUtil.showErrorAlert(viewController: controller, message: "ErrorHandler.InternalExposure".localized())
            break
        case .mappingHttp:
            UIUtil.showErrorAlert(viewController: controller, message: error.errorMessage ?? Constants.emptyStringPreview)
            break
        case .unauthorizedHttp:
            print("unauthorized")
            break;
        case .noInternetHttp:
            UIUtil.showErrorAlert(viewController: controller, message: ErrorHandler.noInternetErrorKey.localized())
            break
        default:
            UIUtil.showErrorAlert(viewController: controller, message: ErrorHandler.internalErrorKey.localized())
        }
    }
    
}
