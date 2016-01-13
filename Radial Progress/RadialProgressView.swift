//
//  RadialProgressView.swift
//  Radial Progress
//
/*

The MIT License (MIT)

Copyright (c) 2016 Kyle J Shaver

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import UIKit

@objc @IBDesignable public class RadialProgressView: UIView {
    
    private var emptyCircle: CAShapeLayer = CAShapeLayer()
    private var progressSlice: RadialProgressSliceLayer = RadialProgressSliceLayer()
    
    // The callback is called immediately after the slice fill becomes 1.0
    public var callback :(() -> Void)? = nil {
        didSet {
            progressSlice.callback = callback
        }
    }
    
    @IBInspectable public var emptyColor: UIColor! = UIColor(white: 199.0/255.0, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var sliceColor: UIColor! = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var sliceSize: CGFloat = 0.2 {
        didSet { setNeedsDisplay() }
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        setup()
        progressSlice.strokeEnd = sliceSize
    }
    
    // Configure the empty circle and the progress slice to be drawn
    // Ensures that the circle will always be a circle in the center of the given frame
    private func setup() {
        let circleDiameter = min(bounds.size.width, bounds.size.height)
        let circleFrame = CGRectMake((bounds.size.width-circleDiameter)/2.0, (bounds.size.height-circleDiameter)/2.0, circleDiameter, circleDiameter)
        emptyCircle.path = UIBezierPath(ovalInRect: circleFrame).CGPath
        emptyCircle.fillColor = emptyColor.CGColor
        self.layer.addSublayer(emptyCircle)
        progressSlice = RadialProgressSliceLayer(frame: circleFrame)
        progressSlice.callback = callback
        progressSlice.strokeColor = sliceColor.CGColor;
        progressSlice.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(progressSlice)
    }
    
    // Animates the slice to a specified size over a given length of time
    func setSliceFill(fillValue: Double, duration: CFTimeInterval) {
        progressSlice.setSliceFill(fillValue, duration: duration)
    }
    
    // Sets the slice to a specified size with a very slight animation
    func setInstantSliceFill(fillValue: Double) {
        progressSlice.setInstantSliceFill(fillValue)
    }
    
    // Pauses any animations for the slice
    func pause() {
        if !progressSlice.isPaused {
            progressSlice.pauseAnimation()
        }
    }
    
    // Resumes animations for the slice
    func resume() {
        if progressSlice.isPaused {
            progressSlice.resumeAnimation()
        }
    }
    
    // Cancels the animation and fades out the slice over a given length of time
    // Animations in progress will continue as the fade occurs
    // After, the slice will be reset to empty and ready to use again
    func cancel(fadeDuration: CFTimeInterval) {
        progressSlice.cancelAnimation(fadeDuration)
    }
    
    // Immediately cancels all animations and resets the slice to be empty
    func reset() {
        progressSlice.reset()
    }
}

class RadialProgressSliceLayer: CAShapeLayer {
    
    private var strokeEndStore: CGFloat = 0.0
    private var strokeColorStore: CGColor?
    
    // The callback is called immediately after the slice fill becomes 1.0
    internal var callback :(() -> Void)?
    
    var isPaused: Bool {
        return speed == 0
    }
    
    override init() {
        super.init()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // This is the init that should be called when creating a slice to be used as a status indicator
    init(frame: CGRect) {
        super.init()
        setup(frame)
    }
    
    // Configures the slice to fit within the given circle
    func setup(frame: CGRect) {
        self.frame = frame
        path = UIBezierPath(ovalInRect: CGRectMake(bounds.size.width/4.0, bounds.size.height/4.0, bounds.size.width/2.0, bounds.size.height/2.0)).CGPath
        anchorPoint = CGPointMake(0.5, 0.5)
        transform = CATransform3DRotate(transform, CGFloat(-M_PI_2), 0.0, 0.0, 1.0)
        lineWidth = bounds.size.width/2.0;
        strokeStart = 0.0
        strokeEnd = 0.0
    }
    
    // Animates the slice to a specified size over a given length of time
    func setSliceFill(fillValue: Double, duration: CFTimeInterval) {
        strokeEndStore = strokeEnd
        strokeEnd = CGFloat(fillValue)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = strokeEndStore
        animation.toValue = fillValue
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        addAnimation(animation, forKey: animation.keyPath)
    }
    
    // Handles the completion of animated slice filling
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        performCallback()
    }
    
    // Performs the callback function if the slice is full
    func performCallback() {
        if callback != nil && strokeEnd == 1.0 {
            callback!()
        }
    }
    
    // Sets the slice to a specified size with a very slight animation
    func setInstantSliceFill(fillValue: Double) {
        removeAllAnimations()
        strokeEnd = CGFloat(fillValue)
        performCallback()
    }
    
    // Pauses all animations. Current animation state will persist
    func pauseAnimation() {
        let pausedTime = convertTime(CACurrentMediaTime(), fromLayer: nil)
        speed = 0.0
        timeOffset = pausedTime
    }
    
    // Resumes any animations that were paused. Continues from paused animation state
    func resumeAnimation() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause = convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        beginTime = timeSincePause
    }
    
    // Cancels the animation and fades out the slice over a given length of time
    // Animations in progress will continue as the fade occurs
    // After, the slice will be reset to empty and ready to use again
    func cancelAnimation(fadeDuration: CFTimeInterval) {
        strokeColorStore = strokeColor
        strokeColor = UIColor.clearColor().CGColor
        let animation = CABasicAnimation(keyPath: "strokeColor")
        animation.duration = fadeDuration
        animation.fromValue = strokeColorStore
        animation.toValue = UIColor.clearColor().CGColor
        addAnimation(animation, forKey: animation.keyPath)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(fadeDuration * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.strokeStart = 0.0
            self.strokeEnd = 0.0
            self.strokeColor = self.strokeColorStore
            self.removeAllAnimations()
        }
    }
    
    // Currently a helper function for cancelling the animation instantly
    func reset() {
        cancelAnimation(0.0)
    }
    
}

