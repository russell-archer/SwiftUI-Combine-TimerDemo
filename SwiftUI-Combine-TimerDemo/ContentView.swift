//
//  ContentView.swift
//  SwiftUI-Combine-TimerDemo
//
//  Created by Russell Archer on 24/08/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import SwiftUI
import Combine

//class CancellableTimer {
//    //public var timer: Timer.TimerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .main, mode: .common)
//    public var cancelTimer: Cancellable? = nil
//
//    deinit { cancelTimer?.cancel() }
//
//    func start(every: TimeInterval) {
//        cancelTimer?.cancel()
//
//        cancelTimer = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { timeStamp in
//
//            }
//
//        print("Timer started")
//    }
//
//    func stop() {
//        cancelTimer?.cancel()
//        cancelTimer = nil
//        print("Timer stopped")
//    }
//}

class CancellableTimer {
    public var timer: Timer.TimerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .main, mode: .common)
    public var cancellableTimer: Cancellable? = nil
    
    private var maxFireCount = 10
    public var timerFireCount = 0 {
        didSet {
            if timerFireCount == maxFireCount {
                stop()
            }
        }
    }
    
    deinit { cancellableTimer?.cancel() }

    func start(every: TimeInterval) {
        cancellableTimer?.cancel()

        timer = Timer.TimerPublisher(interval: 1, runLoop: .main, mode: .common)
        cancellableTimer = timer.connect()

        print("Timer started")
    }

    func stop() {
        cancellableTimer?.cancel()
        cancellableTimer = nil
        print("Timer stopped")
    }
}

struct ContentView: View {
    @State private var timerRunning = false
    @State private var sliderValue: Double = 0.0
    
    var cancellableTimer = CancellableTimer()
    var sliderValueFormatted: Int { return Int(sliderValue) }
    var timerFireCount = 0
    
    var body: some View {
        VStack {
            Text("Timer value: \(sliderValueFormatted) secs")
            Slider(value: $sliderValue, in: 10...60, step: 10).padding()
            Button(timerRunning ? "Stop Timer" : "Start Timer") {
                if self.timerRunning {
                    self.cancellableTimer.stop()
                } else {
                    self.cancellableTimer.start(every: self.sliderValue)
                }
                
                self.timerRunning.toggle()
            }
        }
        .onReceive(cancellableTimer.timer) { timeStamp in
            print("Timer fired at \(timeStamp)")
            self.cancellableTimer.timerFireCount += 1
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
