//
//  ViewController.swift
//  Accelerometer
//
//  Created by Kushal Ashok on 2/25/18.
//  Copyright © 2018 Kushal Ashok. All rights reserved.
//

import UIKit
import CoreMotion

public enum Attitude {
    case Pitch //around x-axis
    case Roll //around y-axis
    case Yaw //around z-axis
}

public enum Motion {
    case Thrust
    case Parry
    case Slash
}

class ViewController: UIViewController {

    //MARK: Class Properties
    
    let motionManager = CMMotionManager()
    var motion = CMDeviceMotion()
    let interval = 1.0 / 20.0  // 20 Hz
    var timer = Timer()
    var secondaryTimer = Timer()
    let cppWrapper = CPP_Wrapper()
    var accDictionary = [String:Double]()
    var xArray = [Double]()
    var yArray = [Double]()
    var zArray = [Double]()
    
    //MARK: Outlets
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var meanLabel: UILabel!
    @IBOutlet weak var medianLabel: UILabel!
    @IBOutlet weak var deviationLabel: UILabel!
    
    
    /// Checks if the user's device has the required sensors or not
    ///
    /// - Returns: Boolean indicating if sensor is available of not
    func isSensorAvailable() -> Bool {
        if !motionManager.isAccelerometerAvailable {
            let alert = UIAlertController(title: "Not Supported", message: "This device is not supported. Please try using another device with accelerometer", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            print("Sensor not detected")
        }
        return motionManager.isAccelerometerAvailable
    }

    
    /// Start the timer which repeats as per the mentioned interval
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (timer) in
            if let deviceMotion = self.motionManager.deviceMotion {
                self.motion = deviceMotion
                self.detectMotion()
            }
        })
        secondaryTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
            self.countLabel.text = String(format:"COUNT X:%i Y:%i Z:%i",self.xArray.count, self.yArray.count, self.zArray.count)
            self.maxLabel.text = String(format:"MAX X:%4.2f Y:%4.2f Z:%4.2f",self.xArray.max()!, self.yArray.max()!, self.zArray.max()!)
            self.minLabel.text = String(format:"MIN X:%4.2f Y:%4.2f Z:%4.2f",self.xArray.min()!, self.yArray.min()!, self.zArray.min()!)
            self.meanLabel.text = String(format:"MEAN X:%4.2f Y:%4.2f Z:%4.2f",self.calculateMean(self.xArray), self.calculateMean(self.yArray), self.calculateMean(self.zArray))
            
            //Reset arrays
            self.xArray = [Double]()
            self.yArray = [Double]()
            self.zArray = [Double]()
        })
    }
    
    
    /// Calculates mean of the values passed in an array
    ///
    /// - Parameter array: array of value for which mean is to be calculated
    /// - Returns: calculated mean value
    func calculateMean(_ array: [Double]) -> Double {
        let arrayPointer = UnsafeMutablePointer(mutating: array)
        let intCount = Int32(array.count)
        return cppWrapper.mean_array_wrapped(arrayPointer, count: intCount)
    }
    
    
    /// Called by timer to detect the motion type based on device's acceleration
    func detectMotion() {
        let acceleration = self.motion.userAcceleration
        accDictionary = ["date":Date().timeIntervalSince1970, "x":acceleration.x, "y":acceleration.y, "z":acceleration.z]
        xArray.append(acceleration.x)
        yArray.append(acceleration.y)
        zArray.append(acceleration.z)
        
        let rotation = motion.attitude
        if rotation.pitch > 1.4 && rotation.pitch < 1.57 {
            print("Phone lifted off the table")
        }
        var parryAxis = acceleration.x
        //If we hit roll which is greater than 0.79, switch up the axis to Z axis
        if abs(rotation.roll) > 0.79 {
            parryAxis = acceleration.z
        }
        if parryAxis <= -1.0 || parryAxis >= 1.0 {
            print("=======PARRY=======")
        }
        else if acceleration.y >= 1.0 {
            var gyro = CMRotationRate()
            if self.motionManager.isGyroAvailable {
                gyro = motion.rotationRate
                print(String(format:"Rotation Rate Z: %7.4f",gyro.z))
            } else {
                print("Gyro not available")
            }
            var slashAxis = gyro.z
            //If we hit roll which is greater than 0.79, switch up the axis to X axis
            if abs(rotation.roll) > 0.79 {
                slashAxis = gyro.x
            }
            if slashAxis < -4.0 || slashAxis > 4.0 {
                print("///////SLASH///////")
            } else {
                print("*******THRUST*******")
            }
        }
    }
    
    
    /// Configures motion manager to start monitoring for updates
    func monitorDeviceMotion() {
        motionManager.deviceMotionUpdateInterval = interval
        motionManager.startDeviceMotionUpdates()
    }

    //MARK: View Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSensorAvailable() {
            startTimer()
            monitorDeviceMotion()
            print("Core Motion Launched")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cppWrapper.hello_cpp_wrapped("World")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        motionManager.stopDeviceMotionUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

