// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension BrowserViewController {
    func presentZapConfirmationAlert(_ sender: Any) {
        qwantTracking.track(.zap_toolbar(isIntention: true))
        let alert = UIAlertController(title: .QwantZap.ZapAlertTitle, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: .QwantZap.ZapAlertOK, style: .destructive, handler: { [weak self] _ in
            self?.doZap()
        }))
        alert.addAction(UIAlertAction(title: .QwantZap.ZapAlertCancel, style: .cancel))
        alert.modalPresentationStyle = .popover
        alert.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        alert.popoverPresentationController?.sourceRect = (sender as? UIButton)?.bounds ?? .zero
        alert.popoverPresentationController?.sourceView = sender as? UIButton
        present(alert, animated: true)
    }

    func doZap() {
        qwantTracking.track(.zap_toolbar(isIntention: false))
        let viewController = ZapAnimationController(zap: self.zap)
        viewController.onFinish = { [weak viewController] in
            viewController?.willMove(toParent: nil)
            viewController?.view.removeFromSuperview()
            viewController?.removeFromParent()

            SimpleToast().showAlertWithText(.QwantZap.ZapToast,
                                            bottomContainer: self.bottomContentStackView,
                                            theme: self.currentTheme())
        }

        self.addChild(viewController)
        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}

class ZapAnimationController: UIViewController {
    private struct UX {
        static let duration = 0.2
        static let thunderboltWidth = 141.0
        static let thunderboltHeight = 171.0
        static let yellow = UIColor(rgb: 0xFFF35B)
        static let black = UIColor.black
        static let minWaitCount = 15
    }

    private lazy var longestEdge: CGFloat = {
        return max(self.view.bounds.width, self.view.bounds.height)
    }()

    private lazy var yellowView: UIView = .build { view in
        view.backgroundColor = UX.yellow
        view.alpha = 0.0
    }

    private lazy var blackView: UIView = .build { view in
        view.backgroundColor = UX.black
        view.alpha = 0.0
    }

    private lazy var topZap: UIImageView = .build { imageView in
        imageView.image = UIImage(named: "qwant_zap_top")
        imageView.alpha = 0.0
    }

    private lazy var bottomZap: UIImageView = .build { imageView in
        imageView.image = UIImage(named: "qwant_zap_bottom")
        imageView.alpha = 0.0
    }

    private lazy var displayLink: CADisplayLink = {
        return CADisplayLink(target: self, selector: #selector(trackAnimationProgress))
    }()

    var zap: QwantZap?
    var onFinish: (() -> Void)?

    // Internal
    private var zapIsFinished = false
    private var waitCount = 0

    init(zap: QwantZap?) {
        self.zap = zap
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.alpha = 1

        view.addSubview(yellowView)
        view.addSubview(topZap)
        view.addSubview(bottomZap)
        view.addSubview(blackView)

        NSLayoutConstraint.activate([
            yellowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            yellowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            yellowView.widthAnchor.constraint(equalToConstant: self.longestEdge),
            yellowView.heightAnchor.constraint(equalToConstant: self.longestEdge),

            topZap.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topZap.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            topZap.widthAnchor.constraint(equalToConstant: UX.thunderboltWidth),
            topZap.heightAnchor.constraint(equalToConstant: UX.thunderboltHeight),

            bottomZap.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomZap.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bottomZap.widthAnchor.constraint(equalToConstant: UX.thunderboltWidth),
            bottomZap.heightAnchor.constraint(equalToConstant: UX.thunderboltHeight),

            blackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blackView.widthAnchor.constraint(equalToConstant: self.longestEdge),
            blackView.heightAnchor.constraint(equalToConstant: self.longestEdge),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.performZap()
        self.startAnimation()
    }

    func startAnimation() {
        self.in1_fadeInZoomInYellowView {
            self.in2_fadeInTranslateZap {
                self.in3_fadeInZoomInBlackView {
                    self.in4_fadeOutBlackView {
                        if self.zapIsFinished {
                            self.stopAnimation()
                        } else {
                            self.loop_spinZap()
                        }
                    }
                }
            }
        }
    }

    func stopAnimation() {
        self.topZap.layer.removeAnimation(forKey: "topZap.rotationAnimation")
        self.bottomZap.layer.removeAnimation(forKey: "bottomZap.rotationAnimation")
        self.displayLink.invalidate()

        self.out1_fadeOutTranslateZap {
            self.out2_fadeOutZoomOutYellowView {
                self.onFinish?()
            }
        }
    }

    func performZap() {
        self.zap?.zap {
            self.zapIsFinished = true
        }
    }

    private func in1_fadeInZoomInYellowView(completion: @escaping () -> Void) {
        self.yellowView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.yellowView.alpha = 0.0
        self.yellowView.layer.cornerRadius = self.longestEdge / 2

        UIView.animate(
            withDuration: UX.duration,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.yellowView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.yellowView.alpha = 1.0
            }, completion: { _ in
                completion()
            }
        )
    }

    private func in2_fadeInTranslateZap(completion: @escaping () -> Void) {
        self.topZap.transform = CGAffineTransform(translationX: 50, y: -100)
        self.bottomZap.transform = CGAffineTransform(translationX: -50, y: 100)

        UIView.animate(
            withDuration: UX.duration,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.topZap.transform = CGAffineTransform(translationX: 0, y: 0)
                self.topZap.alpha = 1.0
                self.bottomZap.transform = CGAffineTransform(translationX: 0, y: 0)
                self.bottomZap.alpha = 1.0
            }, completion: { _ in
                completion()
            }
        )
    }

    private func in3_fadeInZoomInBlackView(completion: @escaping () -> Void) {
        self.blackView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.blackView.alpha = 0.0
        self.blackView.layer.cornerRadius = self.longestEdge / 2

        UIView.animate(
            withDuration: UX.duration,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.blackView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.blackView.alpha = 1.0
            }, completion: { _ in
                completion()
            }
        )
    }

    private func in4_fadeOutBlackView(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: UX.duration,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.blackView.alpha = 0.0
            }, completion: { _ in
                completion()
            }
        )
    }

    private func loop_spinZap() {
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.values = [0, NSNumber(value: Double.pi * 2), NSNumber(value: Double.pi * 2)]
        rotationAnimation.keyTimes = [0, 0.2, 0.6]
        rotationAnimation.duration = 0.8
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.infinity
        self.topZap.layer.add(rotationAnimation, forKey: "topZap.rotationAnimation")
        self.bottomZap.layer.add(rotationAnimation, forKey: "bottomZap.rotationAnimation")
        self.displayLink.add(to: .main, forMode: .common)
    }

    private func out1_fadeOutTranslateZap(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: UX.duration,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.topZap.transform = CGAffineTransform(translationX: 50, y: -100)
                self.topZap.alpha = 0.0
                self.bottomZap.transform = CGAffineTransform(translationX: -50, y: 100)
                self.bottomZap.alpha = 0.0
            }, completion: { _ in
                completion()
            }
        )
    }

    private func out2_fadeOutZoomOutYellowView(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: UX.duration,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.yellowView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self.yellowView.alpha = 0.0
            }, completion: { _ in
                completion()
            }
        )
    }

    @objc
    private func trackAnimationProgress() {
        guard let presentationLayer = self.topZap.layer.presentation() else { return }

        let currentRotation = presentationLayer.value(forKeyPath: "transform.rotation.z") as? NSNumber ?? 0
        self.waitCount = currentRotation == 0 ? self.waitCount + 1 : 0
        if self.zapIsFinished && self.waitCount >= UX.minWaitCount {
            self.stopAnimation()
        }
    }
}
