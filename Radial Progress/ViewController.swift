//
//  ViewController.swift
//  Radial Progress
//
//  Created by Kyle Shaver on 1/6/16.
//  Copyright © 2016 Kyle Shaver. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var progress: RadialProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func demoFunctionality(sender: AnyObject?) {
        updateSlice()
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "instant", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(2.2, target: self, selector: "instant2", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "cancel", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(3.3, target: self, selector: "updateSlice", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "pause", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(6.0, target: self, selector: "resume", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(9.0, target: self, selector: "reset", userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "instant2", userInfo: nil, repeats: false)
    }
    
    func updateSlice() {
        progress.setSliceFill(1.0, duration: 5.0)
    }
    
    func pause() {
        progress.pause()
    }
    
    func resume() {
        progress.resume()
    }
    
    func instant() {
        progress.setInstantSliceFill(0.9)
    }
    
    func instant2() {
        progress.setInstantSliceFill(0.2)
    }
    
    func cancel() {
        progress.cancel(0.2)
    }
    
    func reset() {
        progress.reset()
    }


}

