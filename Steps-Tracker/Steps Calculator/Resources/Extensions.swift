//
//  UIViewExtension.swift
//  Fatwa
//
//  Created by Shahryar Khan on 17/06/2020.
//

import Foundation
import UIKit
import AVFoundation


//MARK:- UILabel
extension UILabel {
    
    func strikeThrough(_ isStrikeThrough:Bool) {
        if isStrikeThrough {
            if let lblText = self.text {
                let attributeString =  NSMutableAttributedString(string: lblText)
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
                self.attributedText = attributeString
            }
        } else {
            if let attributedStringText = self.attributedText {
                let txt = attributedStringText.string
                self.attributedText = nil
                self.text = txt
                return
            }
        }
    }
}
//MARK:- UIView
extension UIView {
    
    func setBorder(color: UIColor, width: CGFloat, cornerRadius: CGFloat) {
        
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        self.layer.cornerRadius = cornerRadius
    }
    
    func setShadow(shadowColor: UIColor, radius: CGFloat) {
        
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = radius
    }
    
    func makeSnapshot() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: frame.size)
            return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
        } else {
            return layer.makeSnapshot()
        }
    }
    
    //Call it in view did layout subviews
    //
    func makeCornersRound(corners: UIRectCorner, radius: CGFloat) {
    
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

//MARK:- Date
extension Date {
    
    
    //convert into string using format
    func convertIntoStringUsingFormat(format: String) -> String? {
        
        var stringToReturn: String? = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        stringToReturn = dateFormatter.string(from: self)
        
        return stringToReturn
    }
    
    func convertStringToDate(withString string:String, withFormat format:String) -> Date? {
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: string)
        return date
        
    }
    //remove time from date
    func updateTime(hour: Int, minute: Int, second: Int) -> Date {
        
        let units: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        var components = Calendar.current.dateComponents(units, from: self)
        components.hour = hour
        components.minute = minute
        components.second = second
        
        let finalDate = Calendar.current.date(from: components)
        return finalDate!
    }
    
    //check if a date is between two dates
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.timeIntervalSince1970 < self.timeIntervalSince1970 && date2.timeIntervalSince1970 > self.timeIntervalSince1970
    }
    
    //Get date after interval
    func getDateAfterNumberOfDays(numberOfDays: Int) -> Date {
        return (Calendar.current as NSCalendar).date(byAdding: .day, value: numberOfDays, to: self, options: [])!
    }
    
    func getDateAfterNumberOfHours(numberOfHours: Int) -> Date {
        return (Calendar.current as NSCalendar).date(byAdding: .hour, value: numberOfHours, to: self, options: [])!
    }
    
    //Get Hours between dates
    func calculateHoursBetweenDates(targetDate: Date) -> Int {
        
        let unitFlags = Set<Calendar.Component>([.hour])
        let components = Calendar.current.dateComponents(unitFlags, from: self, to: targetDate)
        let numberofHours = components.hour ?? 0
        return numberofHours
    }
    
    func isDateInToday() -> Bool {
        
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
}

//MARK:- UIApplication
extension UIApplication {

    func getKeyWindow() -> UIWindow? {
        if #available(iOS 13, *) {
            return windows.first { $0.isKeyWindow }
        } else {
            return keyWindow
        }
    }

    func makeSnapshot() -> UIImage? { return getKeyWindow()?.layer.makeSnapshot() }
}


//MARK:- CALayer
extension CALayer {
    
    func makeSnapshot() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        return screenshot
    }
}

//MARK:- UIImage
extension UIImage {
    
    convenience init?(snapshotOf view: UIView) {
        guard let image = view.makeSnapshot(), let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    func fixOrientation() -> UIImage {
        
        if (self.imageOrientation == .up) {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
}

//MARK:- String
extension String
{
    fileprivate var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }

    func trim() -> String
    {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    func stringMatchesRegex(withRegex regex: String) -> Bool {
        
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
    //for colour codes
    var hex: Int? {
        return Int(self, radix: 16)
    }
    
    //Create String From Date
    func convertIntoDateUsingFormat(format: String) -> Date? {
        
        var dateToReturn: Date? = nil

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateToReturn = dateFormatter.date(from: self)
        
        return dateToReturn
    }

    //AttributedStringForTitle
    func createAttributedString(fontName: String, fontSize: Float, kerning: Float) -> NSAttributedString {

        var attributedStringToReturn = NSAttributedString()
        if let font = UIFont.init(name: fontName, size: CGFloat(fontSize)) {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.red,
                .kern: kerning,
                ]
            attributedStringToReturn = NSAttributedString(string: self, attributes: attributes)
        } else {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
                .foregroundColor: UIColor.red,
                .kern: kerning,
                ]
            attributedStringToReturn = NSAttributedString(string: self, attributes: attributes)
        }
        return attributedStringToReturn
    }
    
    func convertToAttributedString() -> NSAttributedString? {
        
        let data = Data(self.utf8)
        if let attributedString = try? NSMutableAttributedString(data: data, options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil) {

            return attributedString
        } else {
            
            return nil
        }
    }
    
    //MARK:- QR Code
    func generateQRCode() -> UIImage? {
        
        let data = self.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func hashCode() -> Int32 {
        var h : Int32 = 0
        for i in self.asciiArray {
            h = 31 &* h &+ Int32(i) // Be aware of overflow operators,
        }
        return h
    }
    
    //MARK:- Checks on String
    func containsLetter() -> Bool {
    
         let characterRegex  = ".*[a-zA-Z]+.*"
         let testCase = NSPredicate(format:"SELF MATCHES %@", characterRegex)
         let containsCharacter = testCase.evaluate(with: self)

         return containsCharacter
         
     }
     func containsNumbers() -> Bool {
         
         let numbersRange = self.rangeOfCharacter(from: .decimalDigits)
         let hasNumbers = (numbersRange != nil)
         return hasNumbers
     }
     func containsSpecialCharacters() -> Bool {
         
         do {
             let regex = try NSRegularExpression(pattern: "[^a-z0-9]", options: .caseInsensitive)
             
             if let _ = regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) {
                 return true
             } else {
                 return false
             }
         } catch {
             debugPrint(error.localizedDescription)
             return true
         }
     }
     func containsWhiteSpace() -> Bool{
         
         let whitespace = NSCharacterSet.whitespaces

         let range = self.rangeOfCharacter(from: whitespace)

         // range will be nil if no whitespace is found
         if range != nil {
             
             return true
         } else {
             
             return false
         }
     }
    
    func getAcronyms(separator: String = "") -> String {
      
        let stringInputArr = self.components(separatedBy: " ")
        var stringNeed = ""

        for string in stringInputArr {
            
            stringNeed = stringNeed + String(string.first ?? Character("A"))
        }
        return stringNeed
    }
}

//MARK:- Character
extension Character {
    
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
}

//MARK:- CustomTabBar
class CustomTabBar : UITabBar {
    @IBInspectable var height: CGFloat = 0.0

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        
        var sizeThatFits = super.sizeThatFits(size)
        if height > 0.0 {
            
            sizeThatFits.height = height
        }
        
        for item in self.items! {

            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -24.0)
        }
        
        guard let window = UIApplication.shared.windows.first else {
            return super.sizeThatFits(size)
        }
        sizeThatFits.height = window.safeAreaInsets.bottom + 92
        return sizeThatFits
    }
    
}

//MARK:- SearchTextField
class SearchTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //Edge In Sets
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 48))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 48))
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 48))
    }
}

//MARK:- Int
extension Int {
    
    func convertToString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self)) ?? ""
    }
}

//MARK:- Float
extension Float {
    
    func convertToString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self)) ?? ""
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
}

extension Dictionary where Value: Equatable {
    func keys(of element: Value) -> [Key] {
        return filter { $0.1 == element }.map { $0.0 }
    }
}
//MARK:- UIPresentationController

class BubbleTransition: NSObject, UIPresentationControllerProperties {
    
    var duration: TimeInterval = 0.3
    var springWithDamping: CGFloat = 0.8
    var isDisabledDismissAnimation: Bool = false
    
    private let reverse: Bool
    private var originView: UIView!
    
    var dismissCompletion: (()->Void)?
    
    init(originView: UIView, reverse: Bool = false) {
        self.reverse = reverse
        self.originView = originView
    }
}

extension BubbleTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let viewControllerKey: UITransitionContextViewControllerKey = reverse ? .from : .to
        let viewControllerToAnimate = transitionContext.viewController(forKey: viewControllerKey)!

        let viewToAnimate = viewControllerToAnimate.view!
        viewToAnimate.frame = transitionContext.finalFrame(for: viewControllerToAnimate)
        
        var initialFrame = CGRect.zero
        
        if let originImageView = originView as? UIImageView, originImageView.contentMode == .scaleAspectFit  {
            let imageSize = originImageView.image!.size
            let imageViewRect = originImageView.frame
            let frame = AVMakeRect(aspectRatio:imageSize , insideRect: imageViewRect)
            initialFrame = ((originView.superview) ?? originView).convert(frame, to: nil)
        } else {
            initialFrame = ((originView.superview) ?? originView).convert(originView.frame, to: nil)
        }
        
        let finalFrame = viewToAnimate.frame

        let xScaleFactor = initialFrame.width / finalFrame.width
        let yScaleFactor = initialFrame.height / finalFrame.height
    
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if !reverse {
            viewToAnimate.transform = scaleTransform
            viewToAnimate.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            viewToAnimate.clipsToBounds = true
            transitionContext.containerView.addSubview(viewToAnimate)
        }
        
        UIView.animate(withDuration: duration, delay:0.0, usingSpringWithDamping: reverse ? 1 : springWithDamping, initialSpringVelocity: 0.0, animations: { [weak self] in
            
            guard let self = self else { return }
            
            if self.reverse && self.isDisabledDismissAnimation {
                viewToAnimate.alpha = 0
                return
            }
            
            viewToAnimate.transform = self.reverse ? scaleTransform : .identity
            
            let frame = self.reverse ? initialFrame : finalFrame
            viewToAnimate.center = CGPoint(x: frame.midX, y: frame.midY)
            
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
        UIView.animate(withDuration: duration/2, delay: duration/2, options: .curveEaseOut, animations: {
            viewToAnimate.alpha = self.reverse ? 0.0 : 1
        })
    }
}

@objc
public enum Direction: UInt32 {
    
    case left, right, top, bottom
    
    public static func randomDirection() -> Direction {
        return Direction(rawValue: arc4random_uniform(4))!
    }
}

class SlideInTransition: NSObject, UIPresentationControllerProperties {
    
    var duration: TimeInterval = 0.3
    var springWithDamping: CGFloat = 0.8
    var isDisabledDismissAnimation: Bool = false
    
    private let reverse: Bool
    private let fromDirection: Direction
    
    init(fromDirection: Direction, reverse: Bool = false) {
        self.reverse = reverse
        self.fromDirection = fromDirection
    }
}

extension SlideInTransition: UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let viewControllerKey: UITransitionContextViewControllerKey = reverse ? .from : .to
        let viewControllerToAnimate = transitionContext.viewController(forKey: viewControllerKey)!
        
        let viewToAnimate = viewControllerToAnimate.view!
        viewToAnimate.frame = transitionContext.finalFrame(for: viewControllerToAnimate)
        
        let offsetFrame = fromDirection.offsetFrameForView(view: viewToAnimate, containerView: transitionContext.containerView)
        
        if !reverse {
            transitionContext.containerView.addSubview(viewToAnimate)
            viewToAnimate.frame = offsetFrame
        }
        
        let options: UIView.AnimationOptions = [.curveEaseOut]
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: springWithDamping, initialSpringVelocity: 0.0, options: options, animations: { [weak self] in
            
            guard let self = self else { return }
            
            if self.reverse && self.isDisabledDismissAnimation {
                viewToAnimate.alpha = 0
                return
            }
            
            if self.reverse == true {
                viewToAnimate.frame = offsetFrame
            } else {
                viewToAnimate.frame = transitionContext.finalFrame(for: viewControllerToAnimate)
            }
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}

private extension Direction {
    
    func offsetFrameForView(view: UIView, containerView: UIView) -> CGRect {
        
        var frame = view.frame
        
        switch self {
        case .left:
            frame.origin.x = -frame.width
        case .right:
            frame.origin.x = containerView.bounds.width
        case .top:
            frame.origin.y = -frame.height
        case .bottom:
            frame.origin.y = containerView.bounds.height
        }
        
        return frame
    }
}

enum TransitionType {
    case none
    case bubble
    case slide(fromDirection: Direction)
    case menu(fromDirection: Direction)
}

@objc
public protocol UIPresentationControllerDelegate: UIViewControllerTransitioningDelegate {
    
    /// Returns a frame for presented viewController on containerView
    ///
    /// - Parameter: containerViewFrame
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect
    
    //@objc(presentationControllerForPresentedViewController:presentingViewController:sourceViewController:)
    //func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    @objc optional func didDismiss()
}

@objc
public protocol UIPresentationControllerProperties {
    
    var duration: TimeInterval {get set}
    var springWithDamping: CGFloat {get set}
    var isDisabledDismissAnimation: Bool {get set}
}

@objc
public class UIPresentationControllerExtension: UIPresentationController, UIPresentationControllerProperties {
    
    public var duration: TimeInterval = 0.4
    public var springWithDamping: CGFloat = 0.8
    public var isDisabledDismissAnimation: Bool = false
    @objc public var isDisabledTapOutside: Bool = false
    
    /// Availabel only for slide in transition in swift
    @nonobjc public var dismissDirection: Direction? = nil
    
    weak public var sizeDelegate: UIPresentationControllerDelegate?
    
    private var originView: UIView?   // For Bubble transition
    private var fromDirection: Direction! // For slide Transition
    private var blurEffectView: UIVisualEffectView!
    private var blurEffectStyle: UIBlurEffect.Style?
    
    @objc
    convenience public init(fromDirection: Direction, blurEffectStyle: UIBlurEffect.Style, presentedViewController: UIViewController, delegate: UIPresentationControllerDelegate?) {
        self.init(presentedViewController: presentedViewController, presenting: nil)
        
        self.fromDirection = fromDirection
        self.sizeDelegate = delegate
        self.blurEffectStyle = nil
        setup(presentedViewController: presentedViewController)
    }
    
    @objc
    convenience public init(fromDirection: Direction, presentedViewController: UIViewController, delegate: UIPresentationControllerDelegate?) {
        self.init(presentedViewController: presentedViewController, presenting: nil)
        
        self.fromDirection = fromDirection
        self.sizeDelegate = delegate
        setup(presentedViewController: presentedViewController)
    }
    
    @objc
    convenience public init(fromView: UIView, blurEffectStyle: UIBlurEffect.Style, presentedViewController: UIViewController, delegate: UIPresentationControllerDelegate?) {
        self.init(presentedViewController: presentedViewController, presenting: nil)
        
        self.originView = fromView
        self.sizeDelegate = delegate
        self.blurEffectStyle = blurEffectStyle
        setup(presentedViewController: presentedViewController)
    }
    
    @objc
    convenience public init(fromView: UIView, presentedViewController: UIViewController, delegate: UIPresentationControllerDelegate?) {
        self.init(presentedViewController: presentedViewController, presenting: nil)
        
        self.originView = fromView
        self.sizeDelegate = delegate
        setup(presentedViewController: presentedViewController)
    }
    
    override private init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    @objc public func dismiss() {
        self.sizeDelegate?.didDismiss?()
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    private func setup(presentedViewController: UIViewController) {
        
        var blurEffect: UIBlurEffect?
        if let blurEffectStyle = blurEffectStyle {
            blurEffect = UIBlurEffect(style: blurEffectStyle)
        }
        
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        blurEffectView.addGestureRecognizer(tapGestureRecognizer)
        
        presentedView?.layer.masksToBounds = true
        presentedView?.layer.cornerRadius = 10
        
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.transitioningDelegate = self
    }
    
    @objc private func handleTap() {
        
        if !isDisabledTapOutside {
            dismiss()
        }
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        return (sizeDelegate ?? self).frameOfPresentedView(in: containerView!.frame)
    }
    
    override public func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (UIViewControllerTransitionCoordinatorContext) in
            self?.blurEffectView.alpha = 0
        }, completion: { [weak self] (UIViewControllerTransitionCoordinatorContext) in
            self?.blurEffectView.removeFromSuperview()
            self?.sizeDelegate?.didDismiss?()
        })
    }
    
    override public func presentationTransitionWillBegin() {
        
        blurEffectView.alpha = 0
        blurEffectView.frame = containerView!.bounds
        containerView?.addSubview(blurEffectView)
        
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (UIViewControllerTransitionCoordinatorContext) in
            self?.blurEffectView.alpha = 1
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            
        })
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] (contx) in
            guard let self = self else { return }
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
            self.presentedView?.layoutIfNeeded()
        })
    }
}

extension UIPresentationControllerExtension: UIPresentationControllerDelegate {
    
    public func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: 0, y: containerViewFrame.height/2), size: CGSize(width: containerViewFrame.width, height: containerViewFrame.height/2))
    }

    @objc(presentationControllerForPresentedViewController:presentingViewController:sourceViewController:) public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
    }
}

extension UIPresentationControllerExtension: UIViewControllerTransitioningDelegate {
    
    private func setupTransitioningProperties(transitioning: UIPresentationControllerProperties?) -> UIViewControllerAnimatedTransitioning? {
        transitioning?.duration = duration
        transitioning?.springWithDamping = springWithDamping
        transitioning?.isDisabledDismissAnimation = isDisabledDismissAnimation
        return transitioning as? UIViewControllerAnimatedTransitioning
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let sizeDelegate = sizeDelegate,  sizeDelegate.responds(to:#selector(animationController(forPresented:presenting:source:))) {
            return sizeDelegate.animationController?(forPresented: presented, presenting: presenting, source: source)
        }
        
        var transitioning: UIPresentationControllerProperties?
        
        if let originView = originView {
            transitioning = BubbleTransition(originView: originView)
        } else {
            transitioning = SlideInTransition(fromDirection: fromDirection)
        }
        
        return setupTransitioningProperties(transitioning: transitioning)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let sizeDelegate = sizeDelegate,  sizeDelegate.responds(to:#selector(animationController(forDismissed:))) {
            return sizeDelegate.animationController?(forDismissed:dismissed)
        }
        
        var transitioning: UIPresentationControllerProperties?
        
        if let originView = originView {
            transitioning = BubbleTransition(originView: originView, reverse: true)
        } else {
            transitioning = SlideInTransition(fromDirection: dismissDirection ?? fromDirection, reverse: true)
        }
        
        return setupTransitioningProperties(transitioning: transitioning)
    }
}

extension UITextField {
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc fileprivate func doneButtonAction() {
        
        self.resignFirstResponder()
    }
}

extension UITextView {
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc fileprivate func doneButtonAction() {
        
        self.resignFirstResponder()
    }
}
