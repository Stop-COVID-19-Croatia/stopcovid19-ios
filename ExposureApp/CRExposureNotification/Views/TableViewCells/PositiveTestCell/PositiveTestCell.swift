import UIKit

class PositiveTestCell: UITableViewCell {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var appreciationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        borderView.layer.borderWidth = 3
        borderView.layer.borderColor = UIColor.backgroundLightGray.cgColor
    }
    
    func populate(dateOfTest: Date) {
        dateLabel.text = String(format: "PositiveTestCell.DateFormat".localized(), dateOfTest.stringDMYFormat())
        titleLabel.text = "PositiveTestCell.Title".localized()
        appreciationLabel.text = "PositiveTestCell.Appreciation".localized()
    }
}
