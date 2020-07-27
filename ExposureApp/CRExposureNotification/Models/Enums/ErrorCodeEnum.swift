import UIKit

enum ErrorCodeEnum: Int {
    case noValue = 0
    case internalExposure = 1
    case mappingHttp = 100
    case timeoutHttp = -1001
    case noInternetHttp = -1009
    case validationHttp = 400
    case unauthorizedHttp = 401
    case forbiddenHttp = 403
    case internalHttp = 500
    case successHttp = 200
}
