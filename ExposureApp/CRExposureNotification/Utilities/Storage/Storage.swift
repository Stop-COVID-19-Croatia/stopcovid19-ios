import Foundation

class Storage {
    
    private static var keys: [String] {
        get {
            return UserDefaults.standard.value(forKey: "keys") as? [String] ?? []
        }
        set {
            if var currentKeys = UserDefaults.standard.value(forKey: "keys") as? [String] {
                currentKeys.append(contentsOf: newValue)
            } else {
                print("keys not found, creating keys")
                UserDefaults.standard.set(newValue, forKey: "keys")
            }
        }
    }
    
    static func save(_ object: Any, key: String, override: Bool = false) {
        let objectSaved = keys.contains(key)
        if objectSaved && !override {
            print("Object already saved for that key, provide override value(Bool) if you want to override.")
        } else {
            UserDefaults.standard.set(object, forKey: key)
            keys.append(key)
            if override {
                print("Overrided object for \(key).")
            } else {
                print("Saved object for \(key).")
            }
        }
    }

    static func readObject(key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    static func removeObject(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        keys.removeAll(where: { $0 == key })
        print("Removed object for \(key).")
    }
}
