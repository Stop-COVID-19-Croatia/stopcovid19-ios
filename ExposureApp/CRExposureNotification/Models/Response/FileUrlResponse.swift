import ObjectMapper

class FileUrlResponse: Mappable {
    
    var urlList: [String] = []
    
    func mapping(map: Map) {
        urlList <- map["urlList"]
    }
    
    required init?(map: Map) { }
    
    var uniqUrlList: [String] {
        get {
            var uniqUrlList:[String] = []
            for url in urlList {
                if !uniqUrlList.contains(url){
                    uniqUrlList.append(url)
                }
            }
            
            if Configuration.isProduction {
                uniqUrlList.removeAll(where: {LocalStorage.shared.urlCheckedList.contains($0)})
            }
            
            print(("Response.urlList = \(urlList.count)"))
            print(("UniqUrlList = \(uniqUrlList.count)"))
            return uniqUrlList
        }
    }
}
