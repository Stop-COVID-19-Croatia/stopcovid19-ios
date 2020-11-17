import ExposureNotification
import Zip
import Alamofire

class ExposuresProvider {
    
    private static let basePath = "/submission"
    static func getUrls(success: @escaping (FileUrlResponse)-> Void, failure: @escaping (CustomError) -> Void) {
        let finalUrl = Configuration.URLCreator(path: ("\(basePath)/diagnosis-key-file-urls"), URLQueryItem(name: "all", value: LocalStorage.shared.consentToFederation.description))
        ApiConnector.request(url: finalUrl, method: .get, completion: { (response: FileUrlResponse) in
            success(response)
        }) { (error) in
            failure(error)
        }
    }
    
    static func postDiagnosisKeys(_ input: DiagnosisKeyInput, authValue: String?, success: @escaping (Bool)-> Void, failure: @escaping (CustomError) -> Void) {
        ApiConnector.request(url: Configuration.URLCreator(path: basePath, component: "diagnosis-keys"), params: input.toJSON(), authHeaderValue: authValue, method: .post, completion: { (response: String) in
            success(Bool(response) ?? false)
        }) { error in
            failure(error)
        }
    }
    
    static func downloadDiagnosisKeyFile(zipName: String, at remoteURL: String, completion: @escaping (Swift.Result<[URL], Error>) -> Void, downloadedUrl: @escaping (String) -> Void) {
        ApiConnector.requestData(url: remoteURL, method: .get, completion: { (response) in
            guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return
            }
            
            let localZipURL = cachesDirectory.appendingPathComponent("\(zipName).zip")
            var originalLocalUnZipBinURL = cachesDirectory.appendingPathComponent(zipName)
            var originalLocalUnZipSigURL = cachesDirectory.appendingPathComponent(zipName)
            var destinationLocalUnZipBinURL = cachesDirectory.appendingPathComponent(zipName)
            var destinationLocalUnZipSigURL = cachesDirectory.appendingPathComponent(zipName)
            do {
                guard let data = response.data else {
                        return
                }
                
                try data.write(to: localZipURL)
                try Zip.unzipFile(localZipURL, destination: originalLocalUnZipBinURL, overwrite: true, password: nil)
                originalLocalUnZipBinURL = originalLocalUnZipBinURL.appendingPathComponent("export.bin")
                originalLocalUnZipSigURL = originalLocalUnZipSigURL.appendingPathComponent("export.sig")
                destinationLocalUnZipBinURL = destinationLocalUnZipBinURL.appendingPathComponent("export\(zipName).bin")
                destinationLocalUnZipSigURL = destinationLocalUnZipSigURL.appendingPathComponent("export\(zipName).sig")
                
                try? FileManager.default.removeItem(at: destinationLocalUnZipBinURL)
                try FileManager.default.moveItem(at: originalLocalUnZipBinURL, to: destinationLocalUnZipBinURL)
                try? FileManager.default.removeItem(at: destinationLocalUnZipSigURL)
                try FileManager.default.moveItem(at: originalLocalUnZipSigURL, to: destinationLocalUnZipSigURL)
         
                completion(.success([destinationLocalUnZipBinURL,destinationLocalUnZipSigURL]))
                downloadedUrl(remoteURL)
            } catch {
                do {
                    try ExposuresProvider.deleteDiagnosisKeyFile(at: [destinationLocalUnZipBinURL,destinationLocalUnZipSigURL])
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            
        }) { error in
            completion(.failure(error))
        }
    }
    
    private static func deleteDiagnosisKeyFile(at localURLs: [URL]) throws {
        for localURL in localURLs {
            try FileManager.default.removeItem(at: localURL)
        }
    }
}
