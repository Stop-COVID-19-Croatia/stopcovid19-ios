import UIKit

class BaseController: UIViewController {
    
    private var loader: Loader?
    private var isAppear = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAppear = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isAppear = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
    }
    
    private func setupLoader() {
        var view: UIView
        if let tabBarController = tabBarController {
            view = tabBarController.view
        } else {
            view = self.view
        }
        loader = Loader(frame: view.frame)
        view.addSubview(loader!)
    }
    
    func startLoader() {
        loader?.startAnimation()
    }
    
    func stopLoader() {
        loader?.stopAnimation()
    }
}

