//
//  TimeTracker.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 26/11/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import Foundation

protocol TimeTrackerDelegate {
    func handleTime(milliseconds:Double)
}

class TimeTracker : NSObject {
    private var startTime:NSTimeInterval?
    private var timer:NSTimer?
    private var elapsedTime = 0.0
    private var pausedTimeDifference = 0.0
    private var timeUserPaused = 0.0
    var delegate:TimeTrackerDelegate?
    
    func setTimer(timer:NSTimer){
        self.timer = timer
    }
    
    func isPaused() -> Bool {
        return !timer!.valid
    }
    
    func start(){
        if startTime == nil {
            startTime = NSDate.timeIntervalSinceReferenceDate()
            newTimer()
        }
    }
    
    func pause(){
        timer?.invalidate()
        timeUserPaused = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func resume(){
        pausedTimeDifference += NSDate.timeIntervalSinceReferenceDate() - timeUserPaused;
        newTimer()
    }
    
    func handleTimer(){
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        elapsedTime = currentTime - pausedTimeDifference - startTime!
        delegate!.handleTime(elapsedTime)
    }
    
    func reset(){
        pausedTimeDifference = 0.0
        timeUserPaused = 0.0
        startTime = NSDate.timeIntervalSinceReferenceDate()
        newTimer()
    }
    
    func hasReachedMax(max:NSInteger) -> Bool{
        return elapsedTime >= Double(max*60)
    }
    
    private func newTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self ,  selector: "handleTimer", userInfo: nil, repeats: true)
    }
}