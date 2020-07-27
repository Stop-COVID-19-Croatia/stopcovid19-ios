import ObjectMapper

class Update: Mappable {
    var version: String?
    
    init() { }
    
    func mapping(map: Map) {
        version <- map["version"]
    }
    
    required init?(map: Map) { }
}
