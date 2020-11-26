import ObjectMapper

class Language: Mappable {
    
    static let availableLanguages: [Language] = [
        Language(languageType: .english, shortTitle: "Language.ShortTitleEn".localized(), title: "Language.TitleEn".localized(), languageCode: "Language.LanguageCodeEn".localized()),
        Language(languageType: .croatian, shortTitle: "Language.ShortTitleHr".localized(), title: "Language.TitleHr".localized(), languageCode: "Language.LanguageCodeHr".localized())
    ]
    
    var languageType: LanguageType = .english
    var shortTitle: String?
    var title: String?
    var languageCode: String?
    
    init(languageType: LanguageType, shortTitle: String?, title: String?, languageCode: String?){
        self.languageType = languageType
        self.shortTitle = shortTitle
        self.title = title
        self.languageCode = languageCode
    }
    
    func mapping(map: Map) {
        languageType <- map["languageType"]
        shortTitle <- map["ShortTitle"]
        title <- map["Title"]
        languageCode <- map["LanguageCode"]
    }
    
    public static func findLanguageByType(languageType: LanguageType) -> Language {
        let language = availableLanguages.first(where: {$0.languageType == languageType})
        return language ?? getDefaultLanguage()
    }
    
    private static let languageDefaultKey = "LanguageDefault"
    static func getDefaultLanguage() -> Language {
        let userDefaults = UserDefaults.standard
        if let languageDefault = userDefaults.object(forKey: languageDefaultKey) as? String{
            return Language(JSONString: languageDefault)!
        }
        
        return availableLanguages[1]
    }
    
    public static func setDefaultLanguage(language: Language) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(language.toJSONString(), forKey: languageDefaultKey)
        userDefaults.synchronize()
        Bundle.setLanguage(language.shortTitle?.lowercased() ?? "hr")
    }
    
    public static func changeLanguage(language: Language, didChangeLanguage: @escaping (_ isSuccess: Bool, _ error: CustomError?) -> Void) {
        Language.setDefaultLanguage(language: language)
        didChangeLanguage(true, nil)
    }
    
    var previewShortTitle: String {
        switch languageType {
        case .croatian:
            return "Language.ShortTitleEn".localized()
        case .english:
            return "Language.ShortTitleHr".localized()
        }
    }
    
    required init?(map: Map) { }
}

extension Language: Equatable {
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.languageType == rhs.languageType
    }
}


