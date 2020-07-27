import UIKit
import NVActivityIndicatorView

class Loader: UIView {
    
    @IBOutlet weak var loader: NVActivityIndicatorView!
    
    var view: Loader!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        view = loadViewFromNib() as? Loader
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = true
        isHidden = true
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: Loader.self)
        let nib = UINib(nibName: className, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func startAnimation() {
        isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
        }
        view.loader.startAnimating()
    }
    
    func stopAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
        }) { finished in
            if finished {
                self.view.loader.stopAnimating()
                self.isHidden = true
            }
        }
    }
}
