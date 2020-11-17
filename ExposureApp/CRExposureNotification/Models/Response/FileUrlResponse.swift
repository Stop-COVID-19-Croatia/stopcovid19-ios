import ObjectMapper

class FileUrlResponse: Mappable {
    
    var urlList: [String] = []
    
    func mapping(map: Map) {
        urlList <- map["urlList"]
    }
    
    var uniqUrlList: [String] {
        get {
            var uniqUrlList:[String] = []
            for url in urlList {
                if !uniqUrlList.contains(url){
                    uniqUrlList.append(url)
                }
            }
            
            if LocalStorage.shared.consentToFederation {
                uniqUrlList.removeAll { $0.contains("HR") }
                uniqUrlList.removeAll(where: { LocalStorage.shared.urlUniqCheckedList.contains($0.replacingOccurrences(of: "-EU-", with: "-"))})
            } else {
                uniqUrlList.removeAll { $0.contains("EU") }
                uniqUrlList.removeAll(where: { LocalStorage.shared.urlUniqCheckedList.contains($0.replacingOccurrences(of: "-HR-", with: "-"))})
            }
            
            return uniqUrlList
        }
    }
    
    required init?(map: Map) { }
}
