import UIKit

class DatePickerController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    static let shared: DatePickerController = {
        return DatePickerController.instantiate(storyboardName: "Helpers")
    }()
    
    private var dateTitle: String?
    private var minDate: Date?
    private var selectedDate: Date?
    private var maxDate: Date?
    private var didPickDate: ((Date) -> Void)?
    private var datePickerMode: UIDatePicker.Mode = .date
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
        setupDatePicker()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        titleLabel.text = dateTitle
    }
    
    func animateView() {
        containerView.alpha = 0
        containerView.frame.origin.y = containerView.frame.origin.y + 50
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 1.0
            self.containerView.frame.origin.y = self.containerView.frame.origin.y - 50
        })
    }
    
    func present(in viewController: UIViewController, mode: UIDatePicker.Mode = .date, title: String? = nil, preselectedDate: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, didPickDate: @escaping (Date) -> Void) {
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        self.didPickDate = didPickDate
        datePickerMode = mode
        minDate = minimumDate
        selectedDate = preselectedDate
        maxDate = maximumDate
        dateTitle = title
        viewController.present(self, animated: true)
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = datePickerMode
        datePicker.minuteInterval = 30
        datePicker.calendar = Calendar.current
        datePicker.locale = Locale.current
        datePicker.minimumDate = minDate
        setDateForDatePicker()
        datePicker.maximumDate = maxDate
    }
    
    private func reset() {
        minDate = nil
        selectedDate = nil
        maxDate = nil
        datePicker.minimumDate = minDate
        setDateForDatePicker()
        datePicker.maximumDate = maxDate
    }
    
    private func setDateForDatePicker() {
        if datePicker.datePickerMode == .time {
            let now = Calendar.current.dateComponents(in: .current, from: Date())
            let minute = ((now.minute ?? 00) >= 30) ? 30 : 00
            let dateComponents = DateComponents(year: now.year, month: now.month, day: now.day, hour: now.hour, minute: minute)
            if let date = Calendar.current.date(from: dateComponents) {
                datePicker.date = date
            }
        } else if let date = selectedDate {
            datePicker.date = date
        }
    }
    
    @IBAction func done() {
        didPickDate!(datePicker.date)
        reset()
        dismiss(animated: true)
    }
    
    @IBAction func close() {
        reset()
        dismiss(animated: true)
    }
    
    deinit {
        print("DEINIT DatePickerController")
    }
}

