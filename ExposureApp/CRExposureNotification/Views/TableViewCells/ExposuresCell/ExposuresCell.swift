import UIKit

class ExposuresCell: UITableViewCell {

    @IBOutlet weak var riskContainer: UIView!
    @IBOutlet weak var lblRiskStatus: UILabel!
    @IBOutlet weak var lblRiskInfo: UILabel!
    @IBOutlet weak var ivRisk: UIImageView!

    private var exposure: Exposure?
    private var didClickCell: ((Exposure) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    public func populateCell(exposure: Exposure, didClickCell: @escaping (Exposure) -> Void){
        self.exposure = exposure
        self.didClickCell = didClickCell
    }
    
    @IBAction func didClickItem(_ sender: UIButton){
        if let exposure = exposure {
            self.didClickCell?(exposure)
        }
    }
}
