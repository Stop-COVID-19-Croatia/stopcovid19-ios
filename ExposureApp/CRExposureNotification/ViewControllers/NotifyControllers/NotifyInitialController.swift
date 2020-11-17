import UIKit
import ExposureNotification

class NotifyInitialController: UIViewController {
    
    @IBOutlet weak var ivLogoHeader: LottieCustomView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var shareDiagnosisButton: UIButton!
    @IBOutlet weak var lblListOfInfectionTitle: UILabel!
    
    @IBOutlet weak var testsTableView: UITableView!
    @IBOutlet weak var testsTableViewHeight: NSLayoutConstraint!
    
    private var sharedKeys: [Date]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        translateContent()
        if !(ivLogoHeader.animationView?.isAnimationPlaying ?? true) {
            ivLogoHeader.animationView?.play()
        }
    }
    
    private func translateContent() {
        titleLabel.text = "NotifyInitialController.Title".localized()
        descriptionLabel.text = "NotifyInitialController.Description".localized()
        shareDiagnosisButton.setTitle("NotifyInitialController.ShareDiagnosisButtonTitle".localized(), for: .normal)
        lblListOfInfectionTitle.text = "NotifyInitialController.ListOfInfection".localized()
        testsTableView.reloadData()
    }
    
    private func setupController() {
        let testCellNib = UINib(nibName: "PositiveTestCell", bundle: .main)
        testsTableView.register(testCellNib, forCellReuseIdentifier: "positiveTestCell")
        testsTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        reloadTableData()
    }
    
    private func reloadTableData() {
        sharedKeys = (Storage.readObject(key: StorageKeys.sharedKeys) as? [Date])
        if sharedKeys == nil || sharedKeys?.count == 0 {
            lblListOfInfectionTitle.isHidden = true
        } else {
            sharedKeys?.sort(by: {$0>$1})
            lblListOfInfectionTitle.isHidden = false
        }
        
        testsTableView.reloadData()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        testsTableViewHeight.constant = testsTableView.contentSize.height + 32
    }
    
    @IBAction func confirmResultController (_ sender: UIButton){
        let controller = ConfirmResultController.instantiate {
            self.reloadTableData()
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    deinit {
        if testsTableView?.observationInfo != nil {
            testsTableView.removeObserver(self, forKeyPath: "contentSize")
        }
        print("DEINIT NotifyInitialController")
    }
}

extension NotifyInitialController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedKeys?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let testCell = tableView.dequeueReusableCell(withIdentifier: "positiveTestCell") as! PositiveTestCell
        testCell.populate(dateOfTest: sharedKeys?[indexPath.row] ?? Date())
        return testCell
    }
}
