import Foundation

extension Date {
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func stringDMYFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
    
    func stringDMYHMFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: self)
    }
    
    func stringHMFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    func stringYYMMDDTHHMMSSFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-ddTHH:mm:ss"
        return formatter.string(from: self)
    }
    
    func stringDMYHMSFormat() -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
           return formatter.string(from: self)
       }
}
