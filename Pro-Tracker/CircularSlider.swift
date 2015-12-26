//
//  CircularSlider.swift
//  CircularSlider
//
//  Created by Chijioke Ndubisi on 08/12/2015.
//  Copyright © 2015 andela-cj. All rights reserved.
//

import Foundation
import UIKit

public class CircularSlider: UIControl, SliderInformation{

    private var startAngle:CGFloat = 0
    private var endAngle:CGFloat = CGFloat( 2*M_PI )
    private var currentValue:Double!

    var trackColor = UIColor.lightGrayColor() {
        didSet {
            setNeedsDisplay()
        }
    }

    
    var fillColor = UIColor.clearColor(){
        didSet{
            setNeedsDisplay()
        }
    }
    
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
        let angle = toRadians(valueToAngle(minimumValue))
        CGContextSetLineWidth(context, 4)
        CGContextSetStrokeColorWithColor(context,thumb.strokeColor.CGColor)
        CGContextAddArc(context, bounds.midX, bounds.midY, radius, CGFloat(angle), CGFloat(currentAngle), 1)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
        
        thumb.updatePosition()

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
        string.drawInRect(ellipse, withAttributes: attributes)
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

    
    // MARK: -
    // MARK: SliderInformation Protocol
    
    var thumb:Knob<CircularSlider>!
    var trackWidth:CGFloat = 10
    var radius:CGFloat!{ return max(bounds.midX, bounds.midY) - trackWidth/2 }
    var currentAngle:Double! { return toRadians(valueToAngle(value)) }
    var value:Double!{
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
        }
    }

    var maximumValue = 0.0 {
        didSet(value){
            if ( value != maximumValue ){
                if (minimumValue > maximumValue) { maximumValue = minimumValue }
            }
        }
    }
    
    var minimumValue = 1.0 {
        didSet (value) {
            if (value !=  minimumValue){
                if (value > maximumValue) { maximumValue = minimumValue }
                if (value < 0 ){ minimumValue = 0 }
            }
        }
    }

    
    func valueToAngle(value:Double) -> Double{
        let v = value / maximumValue
        return abs(v) * -360 + 90  // add 90 to make north
    }
    
    let toDegrees = { x in return x * 180 / M_PI }
    let toRadians = { x in return x * M_PI / 180 }
}

class Knob<T: SliderInformation>: CALayer {
    typealias Control = T
    
    var fillColor = UIColor.blueColor()
    var strokeColor = UIColor.redColor()
    var horizontalLength:CGFloat! { return slider.radius * 0.15 }
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
    
    override func drawInContext(ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        fillColor.setFill()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2 )
        path.closePath()
        path.fill()
        UIGraphicsPopContext()
    }
    
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


protocol SliderInformation{
    var value:Double! {get set}
    var maximumValue:Double {get set}
    var minimumValue:Double {get set}
    var currentAngle:Double! { get }
    var radius:CGFloat! {get}
    var trackWidth:CGFloat {get set}
    func valueToAngle(value:Double) -> Double
}