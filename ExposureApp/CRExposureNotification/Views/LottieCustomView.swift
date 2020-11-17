import Lottie

class LottieCustomView: UIView {
    
    public var animationView: AnimationView?
    private var lottieAnimation: String = Constants.emptyString
    
    @IBInspectable var lottieName: String? {
        didSet {
            setAnimations(name: lottieName ?? Constants.emptyString)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        animationView = .init(name: "")
        animationView!.frame = self.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        self.addSubview(animationView!)
        animationView!.play()
    }
    
    public func setAnimations(name: String) {
        if let anim = animationView {
            anim.animation = Animation.named(name)
            anim.play()
        }
    }
}
