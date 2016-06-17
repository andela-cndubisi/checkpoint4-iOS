//
//  TimeTracker.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 26/11/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import Foundation

protocol TimeTrackerDelegate {
    func handleTime(_ milliseconds:Double)
}

class TimeTracker : NSObject {
    private var startTime:TimeInterval!
    private var timer:Timer?
    private var elapsedTime = 0.0
    private var pausedTimeDifference = 0.0
    private var timeUserPaused = 0.0
    var delegate:TimeTrackerDelegate?
    
    func setTimer(_ timer:Timer){
        self.timer = timer
    }
    
    func isPaused() -> Bool {
        return !timer!.isValid
    }
    
    func start(){
        if startTime == nil {
            startTime = Date.timeIntervalSinceReferenceDate
            newTimer()
        }
    }
    
    func pause(){
        timer!.invalidate()
        timeUserPaused = Date.timeIntervalSinceReferenceDate
    }
    
    func resume(){
        pausedTimeDifference += Date.timeIntervalSinceReferenceDate - timeUserPaused;
        newTimer()
    }
    
    func handleTimer(){
        let currentTime = Date.timeIntervalSinceReferenceDate
        elapsedTime = currentTime - pausedTimeDifference - startTime
    }
    
    func reset(){
        pausedTimeDifference = 0.0
        timeUserPaused = 0.0
        startTime = Date.timeIntervalSinceReferenceDate
        newTimer()
    }
    
    func hasReachedMax(_ max:NSInteger) -> Bool{
        return elapsedTime >= Double(max*60)
    }
    
    private func newTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target:self ,  selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
}
