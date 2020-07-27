import ObjectMapper

class UpdateWrapper: Mappable {
    var results: [Update]?
    
    var update: Update {
        get{
            if let results = results,
                let update = results.first {
                return update
            }
            return Update()
        }
    }
    
    func mapping(map: Map) {
        results <- map["results"]
    }
    
    required init?(map: Map) { }
}
