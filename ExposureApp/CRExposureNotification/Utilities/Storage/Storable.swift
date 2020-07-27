import Foundation

@propertyWrapper
class Storable<Value: Codable> {
    
    let userDefaultsKey: String
    
    var wrappedValue: Value {
        didSet {
            UserDefaults.standard.set(try! JSONEncoder().encode(wrappedValue), forKey: userDefaultsKey)
        }
    }
    
    init(userDefaultsKey key: String, defaultValue: Value) {
        userDefaultsKey = key
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                wrappedValue = try JSONDecoder().decode(Value.self, from: data)
            } catch {
                wrappedValue = defaultValue
            }
        } else {
            wrappedValue = defaultValue
        }
    }
}
