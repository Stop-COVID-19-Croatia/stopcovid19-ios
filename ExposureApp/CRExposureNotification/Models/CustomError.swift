import Alamofire
import ObjectMapper

class CustomError: Error {
    
    var errorCode: ErrorCodeEnum?
    var errorMessage: String?
    
    init(){}
    
    init(error: String, errorCode: ErrorCodeEnum) {
        self.errorCode = errorCode
        self.errorMessage = error
    }
    
    init(response: DataResponse<String>) {
        if let httpresponse = response.response {
            errorCode = ErrorCodeEnum(rawValue: httpresponse.statusCode)
            errorMessage = response.value
        } else {
            errorCode = ErrorCodeEnum(rawValue: response.response?.statusCode ?? ErrorCodeEnum.noValue.rawValue)
            errorMessage = response.error?.localizedDescription
        }
    }
    
    init(response: DataResponse<Data>) {
        if let httpresponse = response.response {
            errorCode = ErrorCodeEnum(rawValue: httpresponse.statusCode)
            errorMessage = response.error?.localizedDescription
        } else {
            errorCode = ErrorCodeEnum(rawValue: response.response?.statusCode ?? ErrorCodeEnum.noValue.rawValue)
            errorMessage = response.error?.localizedDescription
        }
    }
}
