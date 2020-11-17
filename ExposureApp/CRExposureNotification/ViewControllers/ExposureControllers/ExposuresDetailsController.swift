import UIKit

class ExposuresDetailsController: UIViewController {
    
    @IBOutlet weak var ivInfo: LottieCustomView!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblInfoDuration: UILabel!
    @IBOutlet weak var lblNextstepInfo: UILabel!
    @IBOutlet weak var nextStepContainer: UIView!
    
    private var transmisionRisk: TransmissionRisk?
    
    static func instantiate(transmisionRisk: TransmissionRisk) -> ExposuresDetailsController {
        let controller = ExposuresDetailsController.instantiate(storyboardName: "Exposures") as ExposuresDetailsController
        controller.transmisionRisk = transmisionRisk
        return controller
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        guard let transmisionRisk = transmisionRisk else {
            return
        }
        
        lblInfo.text = transmisionRisk.riskTitle
        lblInfoDuration.text = transmisionRisk.information
        lblNextstepInfo.text = transmisionRisk.riskLongDescription
        if transmisionRisk.riskType == .highRisk {
            ivInfo.setAnimations(name: "icon-risk-high-details-anim")
            nextStepContainer.backgroundColor = .backgroundLightGray
        } else {
            ivInfo.setAnimations(name: "icon-risk-details-anim")
            nextStepContainer.backgroundColor = .white
            nextStepContainer.layer.borderWidth = 2
            nextStepContainer.layer.borderColor = UIColor.backgroundLightGray.cgColor
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
