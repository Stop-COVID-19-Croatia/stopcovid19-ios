import UIKit

import Alamofire
import ObjectMapper

class ApiConnector {

    private static let authHeaderKey = "authorization-code"
    static var headers: HTTPHeaders = {
        return [:]
    }()
    private static let configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        return configuration
    }()
    
    private static var manager: Alamofire.SessionManager?
   private static var httpManager: Alamofire.SessionManager = {
        if manager == nil {
            let serverTrustPolicies: [String: ServerTrustPolicy] = [
                Configuration.urlHost!: .disableEvaluation
            ]
            
            manager = Alamofire.SessionManager(
                configuration: configuration,
                serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
            )
            
            manager?.delegate.sessionDidReceiveChallenge = { _, challenge in
                var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
                var credential: URLCredential?
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    disposition = URLSession.AuthChallengeDisposition.useCredential
                    credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                }
                return (disposition, credential)
            }
        }
        return manager!
    }()
    
    static func request<T:Mappable>(
        url: String,
        params:Parameters? = nil,
        authHeaderValue: String? = nil,
        method: HTTPMethod,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (T) -> Void,
        fail: @escaping (CustomError) -> Void) {
        
        request(url: url, params: params, authHeaderValue: authHeaderValue, method: method, encoding: encoding, completion: { (result:String) in
            if let instance = T(JSONString: result) {
                completion(instance)
                return
            }
            fail(CustomError(error: "JSON mapping failed", errorCode: .mappingHttp))
        }, fail: { (error: CustomError) in
            fail(error)
        })
    }
    
    static func requestList<T:Mappable>(
        url: String,
        params:Parameters? = nil,
        authHeaderValue: String? = nil,
        method: HTTPMethod,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (Array<T>) -> Void,
        fail: @escaping (CustomError) -> Void) {
        
        request(url: url, params: params, authHeaderValue: authHeaderValue, method: method, encoding: encoding, completion: { (result:String) in
            let result:Array<T> = Mapper<T>().mapArray(JSONString: result) ?? Array<T>()
            completion(result)
        }, fail: { (error: CustomError) in
            fail(error)
        })
    }
    
    static func request(
        url: String,
        params:Parameters? = nil,
        authHeaderValue: String? = nil,
        method: HTTPMethod,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (String) -> Void,
        fail: @escaping (CustomError) -> Void) {
        
        if let value = authHeaderValue {
            headers[ApiConnector.authHeaderKey] = value
        }
        
        ApiConnector.httpManager.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
            .responseString { (response:DataResponse<String>) in
                if response.result.isSuccess &&
                    response.response != nil &&
                    response.response?.statusCode == ErrorCodeEnum.successHttp.rawValue {
                    completion(response.result.value!)
                    return
                }
                
                fail(CustomError(response: response))
        }
    }
    
    static func requestData(url: String,
                            params: Parameters? = nil,
                            authHeaderValue: String? = nil,
                            method: HTTPMethod,
                            encoding: ParameterEncoding = JSONEncoding.default,
                            completion: @escaping (DataResponse<Data>) -> Void,
                            fail: @escaping (CustomError) -> Void) {
        
        if let value = authHeaderValue {
            headers[ApiConnector.authHeaderKey] = value
        }
        
        ApiConnector.httpManager.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
            .responseData { (response:DataResponse) in
                if response.result.isSuccess &&
                    response.response != nil &&
                    response.response?.statusCode == ErrorCodeEnum.successHttp.rawValue {
                    completion(response)
                    return
                }
                
                fail(CustomError(response: response))
        }
    }
    
    static func requestData(url: String,
                            params: Parameters? = nil,
                            authHeaderValue: String? = nil,
                            method: HTTPMethod,
                            encoding: ParameterEncoding = JSONEncoding.default,
                            completion: @escaping (Swift.Result<Data, Error>) -> Void) {
        
        if let value = authHeaderValue {
            headers[ApiConnector.authHeaderKey] = value
        }
        
        ApiConnector.httpManager.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
            .responseData { (response:DataResponse) in
                if response.result.isSuccess &&
                    response.response != nil &&
                    response.response?.statusCode == ErrorCodeEnum.successHttp.rawValue {
                    if let unwrappedData = response.data {
                        completion(.success(unwrappedData))
                    } else {
                        completion(.failure(CustomError(error: "Data is nil.", errorCode: .noValue)))
                    }
                    return
                }
                
                completion(.failure(CustomError(response: response)))
        }
    }
}
