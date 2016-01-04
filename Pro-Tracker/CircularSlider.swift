//
//  CircularSlider.swift
//  CircularSlider
//
//  Created by Chijioke Ndubisi on 08/12/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import Foundation
import UIKit

public class CircularSlider: UIControl, SliderInformation{

    /// Slider's thumb
    var thumb:Knob<CircularSlider>!{
        didSet{
            oldValue.removeFromSuperlayer()
            layer.addSublayer(thumb)
        }
    }
    

    /**
     Start angle of Sliders, angle is in radians
     detault is 0
     */
    var startAngle:CGFloat = 0
    
    /**
     Ending angle of Sliders, angle is in radians
     detault is 2π
     */
    var endAngle:CGFloat = CGFloat( 2*M_PI )
    
    /// Value of Slider
    var currentValue:Double!
    
    /// Color of Slider's track
    var trackColor = UIColor.lightGrayColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** Color of Slider's inner circle */
    var fillColor = UIColor.clearColor(){
        didSet{
            setNeedsDisplay()
        }
    }

    /**
     Create a new Circular Slider with a new SliderInformation and
     assigns it's delegate to this
     
     - parameter frame: the bounding frame of the Slider
     - parameter currentValue: initial value to the Slider
     - parameter minimumValue: minimum value of the Slider
     - parameter maximumValue: maximumValue of the Slider
     */
    init(frame:CGRect, currentValue:Double, minimumValue:Double, maximumValue:Double ){
        super.init(frame: frame)
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.value = currentValue
        thumb = Knob()
        thumb.slider = self

        backgroundColor = UIColor.clearColor()
        layer.addSublayer(thumb)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        CGContextSaveGState(context)
        // Flip Context Coordinate System to UIKit's
        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformScale(transform, 1.0, -1.0)
        transform = CGAffineTransformTranslate(transform, 0, -bounds.height)
        CGContextConcatCTM(context, transform)
        
        // Draw Track
        CGContextAddArc(context, bounds.midX, bounds.midY, radius, startAngle, endAngle, 1)
        CGContextSetStrokeColorWithColor(context, trackColor.CGColor)
        CGContextSetLineWidth(context, trackWidth)
        CGContextSetLineCap(context, .Butt)
        CGContextDrawPath(context, .Stroke)
        
        // Draw Progress Track
        let angle = valueToAngle(minimumValue)
        CGContextSetLineWidth(context, 4)
        CGContextSetStrokeColorWithColor(context,thumb.strokeColor.CGColor)
        CGContextAddArc(context, bounds.midX, bounds.midY, radius, CGFloat(angle), CGFloat(currentAngle), 1)
        CGContextStrokePath(context)
        // Flip Context to Original Quartz Coordinate System
        CGContextRestoreGState(context)
        
        // Fill Center
        CGContextSaveGState(context)
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        let length = radius + trackWidth/1.5
        let ellipse = CGRectMake(bounds.width/2 - length/2, bounds.height/2  - length/2, length, length)
        CGContextFillEllipseInRect(context, ellipse)
        CGContextRestoreGState(context)
        
        // Print value at center of ellipse
        let string = NSString(string: String(format:"%02d", arguments: [Int(value)]) )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Left
        let attributes = [ NSFontAttributeName :  UIFont.systemFontOfSize(radius, weight: UIFontWeightThin), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName : paragraphStyle ]
        string.drawAtPoint(CGPointMake(ellipse.midX - ellipse.origin.x, ellipse.midY -  ellipse.origin.y), withAttributes: attributes)
    }
    
    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let touchPoint = touch.locationInView(self)
        let canMove = thumb.frame.contains(touchPoint)
        return canMove
    }
    
    public override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        var lastpoint = touch.locationInView(self)
        lastpoint.x -= radius
        lastpoint.y -= radius
        let rad =  atan2(lastpoint.y,lastpoint.x);
        var angle =  toDegrees(Double(rad)) + 90 // north
        if angle < 0 {
            angle += 360
        }
        let value = angle / (360) * maximumValue
        self.value = round(value)
        return true
    }

    // MARK: Slider Information Protocol Implementation
    
    public var trackWidth:CGFloat = 10
    public var radius:CGFloat!{ return max(bounds.midX, bounds.midY) - trackWidth/2 }
    public var currentAngle:Double! { return valueToAngle(value) }
    public var value:Double!{
        get{
            return currentValue
        }
        set{
            currentValue = newValue
            if currentValue > maximumValue {
                currentValue = maximumValue
            }
            if currentValue < minimumValue {
                currentValue = minimumValue
            }
            sendActionsForControlEvents(.ValueChanged)
            setNeedsDisplay()
            if let thumb = thumb {
                thumb.setNeedsDisplay()
            }

        }
        
    }

    public var maximumValue = 0.0 {
        didSet(value){
            if ( value != maximumValue ){
                if (minimumValue > maximumValue) { maximumValue = minimumValue }
            }
        }
    }
    
    public var minimumValue = 1.0 {
        didSet (value) {
            if (value !=  minimumValue){
                if (value > maximumValue) { maximumValue = minimumValue }
                if (value < 0 ){ minimumValue = 0 }
            }
        }
    }

    public func valueToAngle(value:Double) -> Double{
        let v = value / maximumValue
        let valueInDegrees = v * -360 + 90
        return  toRadians(valueInDegrees) // add 90 to make north
    }
    
    private let toDegrees = { x in return x * 180 / M_PI }
    private let toRadians = { x in return x * M_PI / 180 }
}

public class Knob<T: SliderInformation>: CALayer {
    typealias Control = T
    /// Color of the knob
    var fillColor = UIColor.blueColor()
    /// Color of the slider's progress
    var strokeColor = UIColor.redColor()
    /// diameter of
    var horizontalLength:CGFloat! { return slider.radius * 0.15 }
    /// knob Delegate must implement SliderInformation Protocol
    var slider:Control! {
        didSet{
            let location = positionInRect()
            self.frame = CGRect(x: location.x, y: location.y, width:horizontalLength,  height: horizontalLength)
            setNeedsDisplay()
        }
    }
    
    override init() {
        super.init()
    }
    
    public override func drawInContext(ctx: CGContext) {
        updatePosition()
        UIGraphicsPushContext(ctx)
        fillColor.setFill()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2 )
        path.closePath()
        path.fill()
        UIGraphicsPopContext()
    }
    
    /// Updates position within the bound of Delegate
    func updatePosition(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.position = positionInRect()
        CATransaction.commit()
        setNeedsDisplay()
    }
    
    private func positionInRect() -> (CGPoint) {
        var bounds = CGRectZero
        if let slider = self.slider as! UIView?{
            bounds = slider.bounds
        }
        let centerPoint = CGPointMake(bounds.midX, bounds.midY)
        let radi = -slider.currentAngle
        let x = round(centerPoint.x + slider.radius * CGFloat(cos(radi)) )
        let y = round(centerPoint.y + slider.radius * CGFloat(sin(radi)))
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: -
// MARK: Slider Information Protocol

public protocol SliderInformation {
    /// Current value of slider
    var value:Double! {get set}
    /// maximumValue of Slider
    var maximumValue:Double {get set}
    /// minimum value of Slider
    var minimumValue:Double {get set}
    /// Current angle in radians
    var currentAngle:Double! { get }
    /// radius of the Slider
    var radius:CGFloat! {get}
    /// widht of the Slider's track not the progress
    var trackWidth:CGFloat {get set}
    /// converts current value to and angle in radians
    func valueToAngle(value:Double) -> Double
}