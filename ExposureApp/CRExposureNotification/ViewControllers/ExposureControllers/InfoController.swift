import UIKit

class InfoController: UIViewController {
    
    @IBOutlet weak var lblTermsAndConditions: UILabel!
    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    @IBOutlet weak var lblAccesibilityPolicy: UILabel!
    @IBOutlet weak var lblPartyLicense: UILabel!
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var ivDevelopBy: UIImageView!
    @IBOutlet weak var ivDesign: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        lblTermsAndConditions.underline()
        lblPrivacyPolicy.underline()
        lblAccesibilityPolicy.underline()
        lblPartyLicense.underline()
        if Language.getDefaultLanguage().languageType == .english{
            ivLogo.image = UIImage(named: "Ministvarstvo-logo-EN")
            ivDevelopBy.image = UIImage(named: "develop-by-apis-EN")
            ivDesign.image = UIImage(named: "design-by-BF-info-EN")
        } else {
            ivLogo.image = UIImage(named: "Ministvarstvo-logo-HR")
            ivDevelopBy.image = UIImage(named: "develop-by-apis-HR")
            ivDesign.image = UIImage(named: "design-by-BF-info-HR")
        }
    }
    
    @IBAction func showTermsAndConditions(_ sender: UIButton){
        openUrl(urlString: "TermsUrl".localized())
    }
    
    @IBAction func showPrivacyPolicy(_ sender: UIButton){
        openUrl(urlString: "PrivacyUrl".localized())
    }
    
    @IBAction func showAccesibilityPolicy(_ sender: UIButton){
        openUrl(urlString: "AccessibilityUrl".localized())
    }
    
    @IBAction func showPartyLicense(_ sender: UIButton){
        openUrl(urlString: "LicenseUrl".localized())
    }
    
    private func openUrl(urlString: String?){
        if let urlString = urlString,
            let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func close(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
