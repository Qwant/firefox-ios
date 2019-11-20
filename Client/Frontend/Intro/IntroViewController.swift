/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Shared

enum FxALoginFlow {
    case emailFlow
    case signUpFlow
}

protocol IntroViewControllerDelegate: AnyObject {
    func introViewControllerDidFinish(_ introViewController: IntroViewController, showLoginFlow: FxALoginFlow?)
}

class IntroViewController: UIViewController {

    static let preferredSize = CGSize(width: 375, height: 667)

    weak var delegate: IntroViewControllerDelegate?

    let imagePage1 = UIImageView()
    let imagePage2 = UIImageView()
    let imagePage3 = UIImageView()
    let subtitlePage1 = UILabel()
    let subtitlePage2 = UILabel()
    let subtitlePage3 = UILabel()
    let heading1 = UILabel()
    let heading2 = UILabel()
    let heading3 = UILabel()
    let nextButton = UIButton()
    let startBrowsingButton = UIButton()

    var currentPage = 0

    /* The layout is a top level equal-split StackView, with the image on top
     and the bottom containing `bottomHolder` UIView. The bottom UIView
     has the text and buttons. The buttons are anchored to the bottom,
     the text is anchored to the middle of the screen, and the image will
     center in the top half of the screen. This should handle all screen sizes.

     |----------------|
     |                |
     |      image     |
     |                |
     |----------------|
     |                |
     |                |
     |                |
     |----------------|

     */

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let main2panel = UIStackView()
        main2panel.axis = .vertical
        main2panel.distribution = .fillEqually

        view.addSubview(main2panel)
        main2panel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeArea.top)
            make.bottom.equalTo(view.safeArea.bottom)
        }

        let imageHolder = UIView()
        main2panel.addArrangedSubview(imageHolder)
        [imagePage1, imagePage2, imagePage3].forEach {
            imageHolder.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        let bottomHolder = UIView()
        main2panel.addArrangedSubview(bottomHolder)

        imagePage1.image = UIImage(named: "tour-Welcome2")
        imagePage1.contentMode = .center

        imagePage2.image = UIImage(named: "tour-Privacy")
        imagePage2.isHidden = true
        imagePage2.contentMode = .center
        
        imagePage3.image = UIImage(named: "tour-Efficiency")
        imagePage3.isHidden = true
        imagePage3.contentMode = .center

        [heading1, heading2, heading3, subtitlePage1, subtitlePage2, subtitlePage3, nextButton, startBrowsingButton].forEach {
            bottomHolder.addSubview($0)
        }

        heading1.text = Strings.CardTitleWelcome2
        heading2.text = Strings.CardTitlePrivacy
        heading2.isHidden = true
        heading2.numberOfLines = 2
        heading3.text = Strings.CardTitleEfficiency
        heading3.isHidden = true
        heading3.numberOfLines = 2
        let headingTab = [heading1, heading2, heading3]
        headingTab.forEach {
            $0.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            $0.textColor = .black
            $0.adjustsFontSizeToFitWidth = true
            $0.textAlignment = .center
            $0.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(10)
                make.top.equalToSuperview()
            }
        }

        subtitlePage1.text = Strings.CardTextWelcome2
        subtitlePage2.text = Strings.CardTextPrivacy
        subtitlePage2.isHidden = true
        subtitlePage3.text = Strings.CardTextEfficiency
        subtitlePage3.isHidden = true
        subtitlePage1.numberOfLines = 3
        subtitlePage2.numberOfLines = 3
        subtitlePage3.numberOfLines = 3
        var i = 0
        [subtitlePage1, subtitlePage2, subtitlePage3].forEach {
            $0.textAlignment = .center
            $0.textColor = .black
            $0.adjustsFontSizeToFitWidth = true
            // Shrink the font for the smallest screen size
            let fontSize: CGFloat = view.frame.size.width <= 320 ? 16 : 20
            $0.font = UIFont.systemFont(ofSize: fontSize)
            $0.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(35)
                make.top.equalTo(headingTab[i].snp.bottom)
                // make.topMargin.equalToSuperview().inset(10)
            }
            i += 1
        }

        let buttonEdgeInset = 15
        let buttonHeight = 46
        let buttonBlue = UIColor.Photon.Blue50

        [nextButton, startBrowsingButton].forEach {
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            $0.layer.cornerRadius = 10
        }

        nextButton.setTitle(Strings.IntroNextButtonTitle, for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        [nextButton, startBrowsingButton].forEach {
            $0.setTitleColor(buttonBlue, for: .normal)
            $0.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(buttonEdgeInset)
                let h = view.frame.height
                // On large iPhone screens, bump this up from the bottom
                let offset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 20 : (h > 800 ? 60 : 20)
                make.bottom.equalToSuperview().inset(offset)
                make.height.equalTo(buttonHeight)
            }
        }

        startBrowsingButton.setTitle(Strings.StartBrowsingButtonTitle, for: .normal)
        startBrowsingButton.isHidden = true
        startBrowsingButton.addTarget(self, action: #selector(startBrowsing), for: .touchUpInside)

        // Add 'X' to upper right
        let closeButton = UIButton()
        view.addSubview(closeButton)
        closeButton.setImage(UIImage(named: "close-large"), for: .normal)
        closeButton.addTarget(self, action: #selector(startBrowsing), for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(buttonEdgeInset)
            make.right.equalToSuperview().inset(buttonEdgeInset)
        }
        closeButton.tintColor = .black
    }

    @objc func nextTapped() {
        currentPage += 1

        if currentPage == 1 {
            [heading2, imagePage2, subtitlePage2].forEach {
                $0.alpha = 0
                $0.isHidden = false
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.imagePage1.alpha = 0
                self.imagePage2.alpha = 1
                self.heading1.alpha = 0
                self.heading2.alpha = 1
                self.subtitlePage1.alpha = 0
                self.subtitlePage2.alpha = 1
            })
        } else {
            [heading3, imagePage3, startBrowsingButton, subtitlePage3].forEach {
                $0.alpha = 0
                $0.isHidden = false
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.imagePage2.alpha = 0
                self.imagePage3.alpha = 1
                self.nextButton.alpha = 0
                self.startBrowsingButton.alpha = 1
                self.heading2.alpha = 0
                self.heading3.alpha = 1
                self.subtitlePage2.alpha = 0
                self.subtitlePage3.alpha = 1
            }) { _ in
                self.nextButton.isHidden = true
            }
        }
    }

    @objc func startBrowsing() {
        delegate?.introViewControllerDidFinish(self, showLoginFlow: nil)
        LeanPlumClient.shared.track(event: .dismissedOnboarding, withParameters: ["dismissedOnSlide": String(currentPage)])
        UnifiedTelemetry.recordEvent(category: .action, method: .press, object: .dismissedOnboarding, extras: ["slide-num": currentPage])
    }

    // TODO remove
    @objc func showEmailLoginFlow() {
        delegate?.introViewControllerDidFinish(self, showLoginFlow: .emailFlow)
        LeanPlumClient.shared.track(event: .dismissedOnboardingShowLogin, withParameters: ["dismissedOnSlide": String(currentPage)])
        UnifiedTelemetry.recordEvent(category: .action, method: .press, object: .dismissedOnboardingEmailLogin, extras: ["slide-num": currentPage])
        }

    // TODO remove
    @objc func showSignUpFlow() {
        delegate?.introViewControllerDidFinish(self, showLoginFlow: .signUpFlow)
        LeanPlumClient.shared.track(event: .dismissedOnboardingShowSignUp, withParameters: ["dismissedOnSlide": String(currentPage)])
        UnifiedTelemetry.recordEvent(category: .action, method: .press, object: .dismissedOnboardingSignUp, extras: ["slide-num": currentPage])
        }
}

// UIViewController setup
extension IntroViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // This actually does the right thing on iPad where the modally
        // presented version happily rotates with the iPad orientation.
        return .portrait
    }
}
