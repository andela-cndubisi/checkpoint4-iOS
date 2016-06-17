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
    var trackColor:UIColor = .lightGray() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** Color of Slider's inner circle */
    var fillColor:UIColor = .clear(){
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

        backgroundColor = UIColor.clear()
        layer.addSublayer(thumb)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        context!.saveGState()
        // Flip Context Coordinate System to UIKit's
        var transform = CGAffineTransform.identity
        transform = transform.scaleBy(x: 1.0, y: -1.0)
        transform = transform.translateBy(x: 0, y: -bounds.height)
        context!.concatCTM(transform)
        
        // Draw Track
        context!.addArc(centerX: bounds.midX, y: bounds.midY, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: 1)
        context!.setStrokeColor(trackColor.cgColor)
        context!.setLineWidth(trackWidth)
        context!.setLineCap(.butt)
        context!.drawPath(using: .stroke)
        
        // Draw Progress Track
        let angle = valueToAngle(minimumValue)
        context!.setLineWidth(4)
        context!.setStrokeColor(thumb.strokeColor.cgColor)
        context!.addArc(centerX: bounds.midX, y: bounds.midY, radius: radius, startAngle: CGFloat(angle), endAngle: CGFloat(currentAngle), clockwise: 1)
        context!.strokePath()
        // Flip Context to Original Quartz Coordinate System
        context!.restoreGState()
        
        // Fill Center
        context!.saveGState()
        context!.setFillColor(fillColor.cgColor)
        let length = radius + trackWidth/1.5
        let ellipse = CGRect(x: bounds.width/2 - length/2, y: bounds.height/2  - length/2, width: length, height: length)
        context!.fillEllipse(in: ellipse)
        context!.restoreGState()
        
        // Print value at center of ellipse
        let string = NSString(string: String(format:"%02d", arguments: [Int(value)]) )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes = [ NSFontAttributeName :  UIFont.systemFont(ofSize: radius, weight: UIFontWeightThin), NSForegroundColorAttributeName: UIColor.white(), NSParagraphStyleAttributeName : paragraphStyle ]
        string.draw(at: CGPoint(x: ellipse.midX - ellipse.origin.x, y: ellipse.midY -  ellipse.origin.y), withAttributes: attributes)
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        let canMove = thumb.frame.contains(touchPoint)
        return canMove
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        var lastpoint = touch.location(in: self)
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
            sendActions(for: .valueChanged)
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

    public func valueToAngle(_ value:Double) -> Double{
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
    var fillColor = UIColor.blue()
    /// Color of the slider's progress
    var strokeColor = UIColor.red()
    /// diameter of
    var horizontalLength:CGFloat! { return slider.radius * 0.15 }
    ///  knob Delegate must implement SliderInformation Protocol
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
    
    public override func draw(in ctx: CGContext) {
        updatePosition()
        UIGraphicsPushContext(ctx)
        fillColor.setFill()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2 )
        path.close()
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
        var bounds = CGRect.zero
        if let slider = self.slider as! UIView?{
            bounds = slider.bounds
        }
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
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
    func valueToAngle(_ value:Double) -> Double
}
