//
//  LRHUD.swift
//  LRHUD
//
//  Created by 刘彦直 on 2021/12/10.
//

import UIKit

public class LRHUD: UIControl {
    static let didReceiveTouchEvent = Notification.Name(rawValue: "LRHUD.didReceiveTouchEvent")
    
    static let didTouchDownInside = Notification.Name(rawValue: "LRHUD.didTouchDownInside")
    
    static let willDisappear = Notification.Name(rawValue: "LRHUD.willDisappear")
    
    static let didDisappear = Notification.Name(rawValue: "LRHUD.didDisappear")
    
    static let willAppear = Notification.Name(rawValue: "LRHUD.willAppear")
    
    static let didAppear = Notification.Name(rawValue: "LRHUD.didAppear")
    
    public static var isVisible: Bool { sharedView.alpha > 0 }
    
    static let parallaxDepthPoints: CGFloat = 10
    
    static let undefinedProgress: Float = -1
    
    static let defaultAnimationDuration: CGFloat = 0.15
    
    static let verticalSpacing: CGFloat = 12
    
    static let horizontalSpacing: CGFloat = 12
    
    static let labelSpacing: CGFloat = 8
    
    private static let statusUserInfoKey = "LRHUD.statusUserInfoKey"
    
    var defaultStyle: Style = .light
    
    var defaultMaskType: MaskType = .clear

    var containerView: UIView?
    
    var minimumSize: CGSize = .init(width: 60, height: 60)
    
    var ringThickness: CGFloat = 2
    
    var ringRadius: CGFloat = 18
    
    var ringNoTextRadius: CGFloat = 24
    
    var cornerRadius: CGFloat = 14
    
    var font: UIFont = .preferredFont(forTextStyle: .subheadline)

    var hudForegroundColor: UIColor = .black
    
    var backgroundLayerColor: UIColor = .init(white: 0, alpha: 0.4)
    
    var hudBackgroundColor: UIColor = .init(white: 0, alpha: 0.4)
    
    var imageViewSize: CGSize = .init(width: 28, height: 28)
    
    var shouldTintImages = true

    var graceTimeInterval: TimeInterval = 0
    
    var minimumDismissTimeInterval: TimeInterval = 3
    
    var maximumDismissTimeInterval: TimeInterval = .greatestFiniteMagnitude
    
    var offsetFromCenter: UIOffset = .init(horizontal: 0, vertical: 0)
    
    var fadeInAnimationDuration: TimeInterval = 0.15
    
    var fadeOutAnimationDuration: TimeInterval = 0.15
    
    var maxSupportedWindowLevel: UIWindow.Level = .normal
    
    var hapticsEnabled = false

    private var indefiniteAnimatedViewClass: IndefiniteAnimated.Type = IndefiniteAnimatedView.self

    private var progressAnimatedViewClass: ProgressAnimated.Type = ProgressAnimatedView.self
    
    private var imageAnimatedViewClass: ImageAnimated.Type = ImageAnimatedView.self
    
    private var graceItem: DispatchWorkItem?
    
    private var fadeOutItem: DispatchWorkItem?

    private lazy var backgroundRadialGradientLayer = RadialGradientLayer()
    
    private lazy var _hudView: UIVisualEffectView = {
        let result = UIVisualEffectView()
        result.isUserInteractionEnabled = false
        result.layer.masksToBounds = true
        result.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin]
        return result
    }()
    
    private lazy var _statusLabel: UILabel = {
        let result = UILabel()
        result.backgroundColor = .clear
        result.adjustsFontSizeToFitWidth = true
        result.textAlignment = .center
        result.baselineAdjustment = .alignCenters
        result.numberOfLines = 0
        return result
    }()
    
    private var _imageAnimatedView: ImageAnimated?
    
    private var _indefiniteAnimatedView: IndefiniteAnimated?
    
    private var _progressAnimatedView: ProgressAnimated?

    private lazy var _hapticGenerator = UINotificationFeedbackGenerator()
    
    private var progress: Float = 0
    
    private var activityCount: UInt = 0
    
    static let sharedView: LRHUD = .init()
    
    //MARK: - Instance Methods
    private init() {
        super.init(frame: .zero)
        alpha = 0
        statusLabel.alpha = alpha
        imageAnimatedView.alpha = alpha
        indefiniteAnimatedView.alpha = alpha
        progressAnimatedView.alpha = alpha
        addTarget(self, action: #selector(didReceiveTouchEvent(sender:event:)), for: .touchDown)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        accessibilityIdentifier = "LRHUD"
        isAccessibilityElement = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(status: String) {
        statusLabel.text = status
        statusLabel.isHidden = status.count == 0
        updateHUDFrame()
    }
    
    func updateHUDFrame() {
        let progressUsed = imageAnimatedView.isHidden
        let imageUsed = !progressUsed && imageAnimatedView.image != nil
        
        var labelRect: CGRect = .zero
        var labelHeight: CGFloat = 0
        var labelWidth: CGFloat = 0
        if let _text = statusLabel.text {
            let constraintSize: CGSize = .init(width: 200, height: 300)
            labelRect = (_text as NSString).boundingRect(with: constraintSize, options: [.usesFontLeading, .truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [.font: statusLabel.font ?? .systemFont(ofSize: 13)], context: nil)
            labelHeight = ceil(labelRect.height)
            labelWidth = ceil(labelRect.width)
        }
        
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0
        if imageUsed || progressUsed {
            contentWidth = imageUsed ? imageAnimatedView.bounds.width : indefiniteAnimatedView.bounds.width
            contentHeight = imageUsed ? imageAnimatedView.bounds.height : indefiniteAnimatedView.bounds.height
        }
        
        let hudWidth = LRHUD.horizontalSpacing + max(labelWidth, contentWidth) + LRHUD.horizontalSpacing
        var hudHeight = LRHUD.verticalSpacing + labelHeight + contentHeight + LRHUD.verticalSpacing
        if statusLabel.text != nil && (imageUsed || progressUsed) {
            hudHeight += LRHUD.labelSpacing
        }
        hudView.bounds = .init(x: 0, y: 0, width: max(minimumSize.width, hudWidth), height: max(minimumSize.height, hudHeight))
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        var centerY: CGFloat
        if statusLabel.text != nil {
            let yOffset = max(LRHUD.verticalSpacing, (minimumSize.height - contentHeight - LRHUD.labelSpacing - labelHeight) / 2)
            centerY = yOffset + contentHeight / 2
        } else {
            centerY = hudView.bounds.midY
        }
        indefiniteAnimatedView.center = .init(x: hudView.bounds.midX, y: centerY)
        if progress != LRHUD.undefinedProgress {
            progressAnimatedView.center = .init(x: hudView.bounds.midX, y: centerY)
        }
        imageAnimatedView.center = .init(x: hudView.bounds.midX, y: centerY)
        if imageUsed || progressUsed {
            centerY = (imageUsed ? imageAnimatedView.frame.maxY : indefiniteAnimatedView.frame.maxY) + LRHUD.labelSpacing + labelHeight / 2
        } else {
            centerY = hudView.bounds.midY
        }
        statusLabel.frame = labelRect
        statusLabel.center = .init(x: hudView.bounds.midX, y: centerY)
        CATransaction.commit()
    }
    
    @objc func updatePosition(_ notification: Notification? = nil) {
        var keyboardHeight: CGFloat = 0
        var animationDuration: CGFloat = 0
        
        frame = superview?.bounds ?? UIScreen.main.bounds
        updateBackground()
        #if os(iOS)
        let orientation: UIInterfaceOrientation = frame.width > frame.height ? .landscapeLeft : .portrait
        #else
        let orientation: UIInterfaceOrientation = .portrait
        #endif
        
        #if os(iOS)
        let keyboardInfo = notification?.userInfo ?? [:]
        let keyboardFrame = (keyboardInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect) ?? .zero
        animationDuration = (keyboardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
        if notification?.name == UIApplication.keyboardWillShowNotification || notification?.name == UIApplication.keyboardDidShowNotification {
            if orientation.isPortrait {
                keyboardHeight = keyboardFrame.height
            } else {
                keyboardHeight = keyboardFrame.width
            }
        }
        #endif
        let orientationFrame = bounds
        
        #if os(iOS)
        let statusBarFrame: CGRect = LRHUD.statusBarFrame
        updateMotionEffect(forOrientation: orientation)
        #else
        let statusBarFrame: CGRect = .zero
        updateMotionEffect(xMotionEffectType: .tiltAlongHorizontalAxis, yMotionEffectType: .tiltAlongHorizontalAxis)
        #endif
        var activeHeight = orientationFrame.height
        if keyboardHeight > 0.001 {
            activeHeight += statusBarFrame.height * 2
        }
        activeHeight -= keyboardHeight
        
        let posX = orientationFrame.midX
        let posY = floor(activeHeight * 0.45)
        let rotateAngle: CGFloat = 0
        let newCenter: CGPoint = .init(x: posX, y: posY)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.moveTo(point: newCenter, rotateAngle: rotateAngle)
            self.hudView.setNeedsDisplay()
        }
    }
    
    func updateMotionEffect(forOrientation: UIInterfaceOrientation) {
        let xMotionEffectType: UIInterpolatingMotionEffect.EffectType = forOrientation.isPortrait ? .tiltAlongHorizontalAxis : .tiltAlongVerticalAxis
        let yMotionEffectType: UIInterpolatingMotionEffect.EffectType = forOrientation.isPortrait ? .tiltAlongVerticalAxis : .tiltAlongHorizontalAxis
        updateMotionEffect(xMotionEffectType: xMotionEffectType, yMotionEffectType: yMotionEffectType)
    }
    
    func updateMotionEffect(xMotionEffectType: UIInterpolatingMotionEffect.EffectType, yMotionEffectType: UIInterpolatingMotionEffect.EffectType) {
        let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: xMotionEffectType)
        effectX.minimumRelativeValue = -LRHUD.parallaxDepthPoints
        effectX.maximumRelativeValue = LRHUD.parallaxDepthPoints
        
        let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: yMotionEffectType)
        effectX.minimumRelativeValue = -LRHUD.parallaxDepthPoints
        effectX.maximumRelativeValue = LRHUD.parallaxDepthPoints
        
        let effectGroup = UIMotionEffectGroup()
        effectGroup.motionEffects = [effectX, effectY]
        hudView.motionEffects = []
        hudView.addMotionEffect(effectGroup)
    }
    
    func updateViewHierarchy() {
        if superview == nil {
            if let _containerView = containerView {
                _containerView.addSubview(self)
            } else {
                frontWindow?.addSubview(self)
            }
        } else {
            superview?.bringSubviewToFront(self)
        }
    }
    
    func updateBackground() {
        if defaultMaskType == .gradient {
            if backgroundRadialGradientLayer.superlayer == nil {
                layer.insertSublayer(backgroundRadialGradientLayer, at: 0)
            }
            backgroundRadialGradientLayer.backgroundColor = UIColor.clear.cgColor
            backgroundRadialGradientLayer.frame = bounds
            var gradientCenter = center
            gradientCenter.y = (bounds.height - visibleKeyboardHeight) / 2
            backgroundRadialGradientLayer.gradientCenter = gradientCenter
            backgroundRadialGradientLayer.setNeedsDisplay()
        } else {
            if backgroundRadialGradientLayer.superlayer != nil {
                backgroundRadialGradientLayer.removeFromSuperlayer()
            }
            if defaultMaskType == .black {
                backgroundColor = .init(white: 0, alpha: 0.4)
            } else if defaultMaskType == .custom {
                backgroundColor = backgroundLayerColor
            } else {
                backgroundColor = .clear
            }
        }
    }
}

//MARK: - Notifications and their handling
private extension LRHUD {
    func registerNotifications() {
        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition(_:)), name: UIScene.didActivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition(_:)), name: UIApplication.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition(_:)), name: UIApplication.keyboardDidShowNotification, object: nil)
        #else
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        #endif
    }
    
    func notificationUserInfo() -> [String: String] {
        guard let _text = statusLabel.text else {
            return [:]
        }
        return [LRHUD.statusUserInfoKey: _text]
    }
}

//MARK: - Event handling
private extension LRHUD {
    @objc func didReceiveTouchEvent(sender: NSObject, event: UIEvent) {
        NotificationCenter.default.post(name: LRHUD.didReceiveTouchEvent, object: self, userInfo: notificationUserInfo())
        guard let touch = event.allTouches?.first else {
            return
        }
        guard hudView.frame.contains(touch.location(in: self)) else {
            return
        }
        NotificationCenter.default.post(name: LRHUD.didTouchDownInside, object: self, userInfo: notificationUserInfo())
    }
}

//MARK: - Master show/dismiss methods
extension LRHUD {
    func show(progress: Float, status: String?, interaction: Bool = true) {
        OperationQueue.main.addOperation { [weak self] in
            self?.isUserInteractionEnabled = interaction
            self?._show(progress: progress, status: status)
        }
    }
    
    func show(image: UIImage, status: String?, duration: TimeInterval, interaction: Bool = true) {
        OperationQueue.main.addOperation { [weak self] in
            self?.isUserInteractionEnabled = interaction
            self?._show(image: image, status: status, duration: duration)
        }
    }
    
    func dismiss(delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        OperationQueue.main.addOperation { [weak self] in
            self?._dismiss(delay: delay, completion: completion)
        }
    }
    
    private func _show(progress: Float, status: String?) {
        if fadeOutItem != nil {
            activityCount = 0
        }
        fadeOutItem?.cancel()
        fadeOutItem = nil
        graceItem?.cancel()
        graceItem = nil
        
        updateViewHierarchy()
        imageAnimatedView.isHidden = true
        imageAnimatedView.image = nil
        
        statusLabel.isHidden = status?.count == 0
        statusLabel.text = status
        self.progress = progress
        
        if progress >= 0 {
            cancelIndefiniteAnimation()
            if progressAnimatedView.superview == nil {
                hudView.contentView.addSubview(progressAnimatedView)
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressAnimatedView.set(progress: .init(progress))
            CATransaction.commit()
            if progress == 0 {
                activityCount += 1
            }
        } else {
            cancelProgressAnimation()
            hudView.contentView.addSubview(indefiniteAnimatedView)
            indefiniteAnimatedView.startAnimating()
            activityCount += 1
        }

        if graceTimeInterval > 0 && alpha == 0 {
            graceItem = .after(timeInterval: graceTimeInterval, block: { [weak self] in
                self?.fadeIn()
            })
        } else {
            fadeIn()
        }
        
        hapticGenerator?.prepare()
    }
    
    func _show(image: UIImage, status: String?, duration: TimeInterval) {
        fadeOutItem?.cancel()
        fadeOutItem = nil
        graceItem?.cancel()
        graceItem = nil
        
        updateViewHierarchy()
        
        progress = LRHUD.undefinedProgress
        cancelProgressAnimation()
        cancelIndefiniteAnimation()
        if shouldTintImages {
            if image.renderingMode != .alwaysTemplate {
                imageAnimatedView.image = image.withRenderingMode(.alwaysTemplate)
            }
            imageAnimatedView.tintColor = foregroundColorForStyle
        } else {
            imageAnimatedView.image = image
        }
        imageAnimatedView.isHidden = false
        imageAnimatedView.startAnimating()
        statusLabel.isHidden = status?.count == 0
        statusLabel.text = status
        
        if graceTimeInterval > 0 && alpha == 0 {
            graceItem = .after(timeInterval: graceTimeInterval, block: { [weak self] in
                self?.fadeIn(duration: duration)
            })
        } else {
            fadeIn(duration: duration)
        }
    }
    
    private func _dismiss(delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        graceItem?.cancel()
        graceItem = nil
        NotificationCenter.default.post(name: LRHUD.willDisappear, object: nil, userInfo: notificationUserInfo())
        activityCount = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000))) {
            UIView.animate(withDuration: self.fadeOutAnimationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState]) {
                self.hudView.transform = self.hudView.transform.scaledBy(x: 1 / 1.3, y: 1 / 1.3)
                self.fadeOutEffects()
            } completion: { isFinished in
                guard self.alpha == 0 else {
                    return
                }
                self.removeFromSuperview()
                self.hudView.removeFromSuperview()
                self.removeFromSuperview()
                
                self.progress = LRHUD.undefinedProgress
                self.cancelProgressAnimation()
                self.cancelIndefiniteAnimation()
                self.cancelImageAnimation()
                NotificationCenter.default.removeObserver(self)
                NotificationCenter.default.post(name: LRHUD.didDisappear, object: self, userInfo: self.notificationUserInfo())
                completion?()
            }
        }
        setNeedsDisplay()
    }
    
    func fadeIn(duration: TimeInterval = 0) {
        updateHUDFrame()
        updatePosition()
        if defaultMaskType == .none {
            accessibilityLabel = statusLabel.text ?? NSLocalizedString("Loading", comment: "")
            isAccessibilityElement = true
        } else {
            hudView.accessibilityLabel = statusLabel.text ?? NSLocalizedString("Loading", comment: "")
            hudView.isAccessibilityElement = true
        }
        if alpha != 1 {
            NotificationCenter.default.post(name: LRHUD.willAppear, object: self, userInfo: notificationUserInfo())
            hudView.transform = hudView.transform.scaledBy(x: 1 / 1.5, y: 1 / 1.5)
            UIView.animate(withDuration: fadeInAnimationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseIn, .beginFromCurrentState]) {
                self.hudView.transform = .identity
                self.fadeInEffects()
            } completion: { isFinished in
                guard self.alpha == 1 else {
                    return
                }
                self.registerNotifications()
                NotificationCenter.default.post(name: LRHUD.didAppear, object: self, userInfo: self.notificationUserInfo())
                UIAccessibility.post(notification: .screenChanged, argument: nil)
                UIAccessibility.post(notification: .announcement, argument: self.statusLabel.text)
                if duration > 0.001 {
                    self.fadeOutItem = .after(timeInterval: duration, block: { [weak self] in
                        self?.dismiss()
                    })
                }
            }
            setNeedsDisplay()
        } else {
            UIAccessibility.post(notification: .screenChanged, argument: nil)
            UIAccessibility.post(notification: .announcement, argument: self.statusLabel.text)
            if duration > 0.001 {
                self.fadeOutItem = .after(timeInterval: duration, block: { [weak self] in
                    self?.dismiss()
                })
            }
        }
    }
}

//MARK: - Custom UI
private extension LRHUD {
    var indefiniteAnimatedView: IndefiniteAnimated {
        if _indefiniteAnimatedView == nil || !(_indefiniteAnimatedView?.isKind(of: indefiniteAnimatedViewClass) ?? false) {
            _indefiniteAnimatedView?.removeFromSuperview()
            _indefiniteAnimatedView = indefiniteAnimatedViewClass.init()
            _indefiniteAnimatedView!.setup()
        }
        _indefiniteAnimatedView!.set(color: foregroundColorForStyle)
        _indefiniteAnimatedView!.set(radius: statusLabel.text != nil ? ringRadius : ringNoTextRadius)
        _indefiniteAnimatedView!.set(thickness: ringThickness)
        _indefiniteAnimatedView!.sizeToFit()
        return _indefiniteAnimatedView!
    }
    
    var progressAnimatedView: ProgressAnimated {
        if _progressAnimatedView == nil || !(_progressAnimatedView?.isKind(of: progressAnimatedViewClass) ?? false) {
            _progressAnimatedView?.removeFromSuperview()
            _progressAnimatedView = progressAnimatedViewClass.init()
            _progressAnimatedView!.setup()
        }
        _progressAnimatedView!.set(color: foregroundColorForStyle)
        _progressAnimatedView!.set(thickness: ringThickness)
        _progressAnimatedView!.set(radius: statusLabel.text != nil ? ringRadius : ringNoTextRadius)
        return _progressAnimatedView!
    }

    var imageAnimatedView: ImageAnimated {
        if _imageAnimatedView == nil || !(_imageAnimatedView?.isKind(of: imageAnimatedViewClass) ?? false) {
            _imageAnimatedView?.removeFromSuperview()
            _imageAnimatedView = imageAnimatedViewClass.init()
            _imageAnimatedView!.frame = .init(origin: .zero, size: imageViewSize)
            _imageAnimatedView!.setup()
            hudView.contentView.addSubview(_imageAnimatedView!)
        }
        return _imageAnimatedView!
    }
    
    func cancelProgressAnimation() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        hudView.layer.removeAllAnimations()
        progressAnimatedView.set(progress: 0)
        CATransaction.commit()
        progressAnimatedView.removeFromSuperview()
    }
    
    func cancelIndefiniteAnimation() {
        indefiniteAnimatedView.stopAnimating()
        indefiniteAnimatedView.removeFromSuperview()
    }
    
    func cancelImageAnimation() {
        imageAnimatedView.stopAnimating()
    }
}

//MARK: - Getters
private extension LRHUD {
    static func displayDuration(for string: String) -> TimeInterval {
        return min(max(TimeInterval(string.count) * 0.06 + 0.5, sharedView.minimumDismissTimeInterval), sharedView.maximumDismissTimeInterval)
    }

    var hudView: UIVisualEffectView {
        if _hudView.superview == nil {
            addSubview(_hudView)
        }
        _hudView.layer.cornerRadius = cornerRadius
        return _hudView
    }
    
    var statusLabel: UILabel {
        if _statusLabel.superview == nil {
            hudView.contentView.addSubview(_statusLabel)
        }
        _statusLabel.textColor = foregroundColorForStyle
        _statusLabel.font = font
        return _statusLabel
    }
    
}

//MARK: - Helper
private extension LRHUD {
    private static var currentWindow: UIWindow? {
        return allWindows.first { $0.isKeyWindow } ?? allWindows.first
    }
    
    private static var allWindows: [UIWindow] {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        } else {
            return UIApplication.shared.windows
        }
    }
 
    private static var statusBarFrame: CGRect {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive }
            return (scene as? UIWindowScene)?.statusBarManager?.statusBarFrame ?? .zero
        } else {
            return UIApplication.shared.statusBarFrame
        }
    }
    
    var hapticGenerator: UINotificationFeedbackGenerator? { hapticsEnabled ? _hapticGenerator : nil }
    
    var visibleKeyboardHeight: CGFloat {
        guard let keyboardWindow = LRHUD.allWindows.first else {
            return 0
        }
        for possibleKeyboard in keyboardWindow.subviews {
            
            let viewName = NSStringFromClass(possibleKeyboard.classForCoder)
            if viewName.hasPrefix("UI") {
                if viewName.hasSuffix("PeripheralHostView") || viewName.hasSuffix("Keyboard") {
                    return possibleKeyboard.bounds.height
                } else if viewName.hasSuffix("InputSetContainerView") {
                    for _possibleKeyboard in possibleKeyboard.subviews {
                        let viewName = NSStringFromClass(_possibleKeyboard.classForCoder)
                        if viewName.hasPrefix("UI") && viewName.hasSuffix("InputSetHostView") {
                            let convertedRect = possibleKeyboard.convert(_possibleKeyboard.frame, to: self)
                            let intersectedRect = convertedRect.intersection(bounds)
                            if !intersectedRect.isNull {
                                return intersectedRect.height
                            }
                        }
                    }
                }
            }
        }
        
        return 0
    }
    
    var frontWindow: UIWindow? {
        let frontToBackWindows = LRHUD.allWindows.reversed()
        for window in frontToBackWindows {
            let windowOnMainScreen = window.screen == UIScreen.main
            let windowIsVisible = !window.isHidden && window.alpha > 0
            let windowLevelSupported = window.windowLevel.rawValue >= UIWindow.Level.normal.rawValue && window.windowLevel <= maxSupportedWindowLevel
            let windowIsKeyWindow = window.isKeyWindow
            if windowOnMainScreen && windowIsVisible && windowLevelSupported && windowIsKeyWindow {
                return window
            }
        }
        return nil
    }
    
    var foregroundColorForStyle: UIColor {
        if defaultStyle == .light {
            return .black
        } else if defaultStyle == .dark {
            return .white
        } else if defaultStyle == .auto {
            if overrideUserInterfaceStyle == .light {
                return .black
            } else if overrideUserInterfaceStyle == .dark {
                return .white
            }
        }
        return hudForegroundColor
    }
    
    var backgroundColorForStyle: UIColor {
        if defaultStyle == .light {
            return .white
        } else if defaultStyle == .dark {
            return .black
        } else if defaultStyle == .auto {
            if overrideUserInterfaceStyle == .light {
                return .white
            } else if overrideUserInterfaceStyle == .dark {
                return .black
            }
        }
        return hudBackgroundColor
    }
    
    func fadeInEffects() {
        if defaultStyle != .custom {
            hudView.effect = UIBlurEffect(style: defaultStyle == .dark ? .dark : .light)
            hudView.backgroundColor = backgroundColorForStyle.withAlphaComponent(0.6)
        } else {
            hudView.backgroundColor = backgroundColorForStyle
        }
        alpha = 1
        statusLabel.alpha = alpha
        imageAnimatedView.alpha = alpha
        indefiniteAnimatedView.alpha = alpha
        progressAnimatedView.alpha = alpha
    }

    func fadeOutEffects() {
        if defaultStyle != .custom {
            hudView.effect = nil
        }
        hudView.backgroundColor = .clear
        alpha = 0
        statusLabel.alpha = alpha
        imageAnimatedView.alpha = alpha
        indefiniteAnimatedView.alpha = alpha
        progressAnimatedView.alpha = alpha
    }
    
    func moveTo(point: CGPoint, rotateAngle: CGFloat) {
        hudView.transform = .init(rotationAngle: rotateAngle)
        if let _containerView = containerView {
            hudView.center = .init(x: _containerView.center.x + offsetFromCenter.horizontal, y: _containerView.center.y + offsetFromCenter.vertical)
        } else {
            hudView.center = .init(x: point.x + offsetFromCenter.horizontal, y: point.y + offsetFromCenter.vertical)
        }
    }
}

//MARK: - Static setters
public extension LRHUD {
    static func set(status: String) {
        sharedView.set(status: status)
    }
    
    static func set(defaultStyle: Style) {
        sharedView.defaultStyle = defaultStyle
    }
    
    static func set(defaultMaskType: MaskType) {
        sharedView.defaultMaskType = defaultMaskType
    }
    
    static func register(indefiniteAnimatedViewClass: IndefiniteAnimated.Type) {
        sharedView.indefiniteAnimatedViewClass = indefiniteAnimatedViewClass
    }
    
    static func register(progressAnimatedView: ProgressAnimated.Type) {
        sharedView.progressAnimatedViewClass = progressAnimatedView
    }
    
    static func register(imageAnimatedView: ImageAnimated.Type) {
        sharedView.imageAnimatedViewClass = imageAnimatedView
    }

    static func set(containerView: UIView?) {
        sharedView.containerView = containerView
    }
    
    static func set(minimumSize: CGSize) {
        sharedView.minimumSize = minimumSize
    }
    
    static func set(ringThickness: CGFloat) {
        sharedView.ringThickness = ringThickness
    }
    
    static func set(ringRadius: CGFloat) {
        sharedView.ringRadius = ringRadius
    }
    
    static func set(ringNoTextRadius: CGFloat) {
        sharedView.ringNoTextRadius = ringNoTextRadius
    }
    
    static func set(cornerRadius: CGFloat) {
        sharedView.cornerRadius = cornerRadius
    }
    
    static func set(borderColor: UIColor?) {
        sharedView.hudView.layer.borderColor = borderColor?.cgColor
    }
    
    static func set(borderWidth: CGFloat) {
        sharedView.hudView.layer.borderWidth = borderWidth
    }
    
    static func set(font: UIFont) {
        sharedView.font = font
    }
    
    static func set(hudForegroundColor: UIColor) {
        sharedView.hudForegroundColor = hudForegroundColor
        set(defaultStyle: .custom)
    }
    
    static func set(hudBackgroundColor: UIColor) {
        sharedView.hudBackgroundColor = hudBackgroundColor
        set(defaultStyle: .custom)
    }
    
    static func set(backgroundColor: UIColor) {
        sharedView.backgroundLayerColor = backgroundColor
    }
    
    static func set(imageViewSize: CGSize) {
        sharedView.imageViewSize = imageViewSize
    }
    
    static func set(shouldTintImages: Bool) {
        sharedView.shouldTintImages = shouldTintImages
    }

    static func set(graceTimeInterval: TimeInterval) {
        sharedView.graceTimeInterval = graceTimeInterval
    }
    
    static func set(minimumDismissTimeInterval: TimeInterval) {
        sharedView.minimumDismissTimeInterval = minimumDismissTimeInterval
    }
    
    static func set(maximumDismissTimeInterval: TimeInterval) {
        sharedView.maximumDismissTimeInterval = maximumDismissTimeInterval
    }
    
    static func set(fadeInAnimationDuration: TimeInterval) {
        sharedView.fadeInAnimationDuration = fadeInAnimationDuration
    }
    
    static func set(fadeOutAnimationDuration: TimeInterval) {
        sharedView.fadeOutAnimationDuration = fadeOutAnimationDuration
    }
    
    static func set(maxSupportedWindowLevel: UIWindow.Level) {
        sharedView.maxSupportedWindowLevel = maxSupportedWindowLevel
    }
    
    static func set(hapticsEnabled: Bool) {
        sharedView.hapticsEnabled = hapticsEnabled
    }
    
    static func setOffsetFromCenter(offset: UIOffset) {
        sharedView.offsetFromCenter = offset
    }
    
    static func resetOffsetFromCenter() {
        setOffsetFromCenter(offset: .zero)
    }
}

//MARK: - Show/Dismiss
public extension LRHUD {
    static func show(status: String? = nil, interaction: Bool = true, maskType: MaskType? = nil) {
        show(progress: LRHUD.undefinedProgress, status: status, interaction: interaction, maskType: maskType)
    }

    static func show(progress: Float, status: String? = nil, interaction: Bool = true, maskType: MaskType? = nil) {
        let existingMaskType = sharedView.defaultMaskType
        set(defaultMaskType: maskType ?? existingMaskType)
        sharedView.show(progress: progress, status: status, interaction: interaction)
        set(defaultMaskType: existingMaskType)
    }

    static func show(info: String, interaction: Bool = true, maskType: MaskType? = nil) {
        show(image: sharedView.imageAnimatedView.image(forType: .info), status: info, interaction: interaction, maskType: maskType)
        sharedView.hapticGenerator?.notificationOccurred(.warning)
    }

    static func show(success: String, interaction: Bool = true, maskType: MaskType? = nil) {
        show(image: sharedView.imageAnimatedView.image(forType: .success), status: success, interaction: interaction, maskType: maskType)
        sharedView.hapticGenerator?.notificationOccurred(.success)
    }

    static func show(error: String, interaction: Bool = true, maskType: MaskType? = nil) {
        show(image: sharedView.imageAnimatedView.image(forType: .error), status: error, interaction: interaction, maskType: maskType)
        sharedView.hapticGenerator?.notificationOccurred(.error)
    }

    static func show(image: UIImage, status: String, interaction: Bool = true, maskType: MaskType? = nil) {
        let existingMaskType = sharedView.defaultMaskType
        set(defaultMaskType: maskType ?? existingMaskType)
        sharedView.show(image: image, status: status, duration: displayDuration(for: status), interaction: interaction)
        set(defaultMaskType: existingMaskType)
    }

    static func dismiss(delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        sharedView.dismiss(delay: delay, completion: completion)
    }
}

//MARK: - Custom UI Protocol
public protocol IndefiniteAnimated where Self: UIView {
    func setup()
    
    func startAnimating()

    func stopAnimating()
    
    func set(color: UIColor)
    
    func set(radius: CGFloat)
    
    func set(thickness: CGFloat)
}

public protocol ProgressAnimated where Self: UIView {
    func setup()
    
    func set(progress: CGFloat)
    
    func set(color: UIColor)
    
    func set(radius: CGFloat)
    
    func set(thickness: CGFloat)
}

public protocol ImageAnimated where Self: UIView {
    var image: UIImage? {set get}
    
    func image(forType: LRHUD.ImageType) -> UIImage
    
    func setup()
    
    func startAnimating()

    func stopAnimating()
}

//MARK: -
public extension LRHUD {
    enum Style {
        case light
        case dark
        case auto
        case custom
    }
    
    enum MaskType {
        case clear
        case black
        case gradient
        case custom
    }
    
    enum ImageType {
        case info
        case error
        case success
        case named(String)
    }
}

private extension DispatchWorkItem {
    static func after(timeInterval: TimeInterval, block: @escaping () -> Void) -> DispatchWorkItem {
        let result = DispatchWorkItem(block: block)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(timeInterval * 1000)), execute: result)
        return result
    }
}

extension UIActivityIndicatorView: IndefiniteAnimated {
    public func setup() {
        style = .large
    }
    
    public func set(color: UIColor) {
        self.color = color
    }
    
    public func set(radius: CGFloat) {}
    
    public func set(thickness: CGFloat) {}
}

private class RadialGradientLayer: CALayer {
    var gradientCenter: CGPoint = .zero
    
    override func draw(in ctx: CGContext) {
        let locations: [CGFloat] = [0, 1]
        let colors: [CGFloat] = [0, 0, 0, 0, 0, 0, 0, 0.75]
        guard let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: colors, locations: locations, count: 2) else {
            return
        }
        ctx.drawRadialGradient(gradient, startCenter: gradientCenter, startRadius: 0, endCenter: gradientCenter, endRadius: min(bounds.size.width, bounds.size.height), options: .drawsAfterEndLocation)
    }
}
