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
    var isXPositive = true
    var isYPositive = true
    var isZPositive = true
    
    //MARK: Outlets
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var meanLabel: UILabel!
    @IBOutlet weak var medianLabel: UILabel!
    @IBOutlet weak var deviationLabel: UILabel!
    @IBOutlet weak var zeroCrossingsLabel: UILabel!
    @IBOutlet weak var toggleSegmentedControl: UISegmentedControl!
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        updateLabels()
        switch sender.selectedSegmentIndex {
        case 0: //Last 5 seconds
            zeroCrossingsLabel.isHidden = false
        case 1: //Since App Launch
            zeroCrossingsLabel.isHidden = true
        default:
            break
        }
    }
    
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
            self.updateLabels()
        })
    }
    
    
    /// Fetches data from the database, gets the calculations done and displays result via UILabels
    func updateLabels() {
        var xArray = [Double]()
        var yArray = [Double]()
        var zArray = [Double]()
        switch toggleSegmentedControl.selectedSegmentIndex {
        case 0: // Last 5 seconds only
            let dataObjects = realmHelper.getObjects(Data.self, filterString: "5sec")
            if let array = dataObjects?.value(forKey: "xAcceleration") as? [Double] {
                xArray = array
            }
            if let array = dataObjects?.value(forKey: "yAcceleration") as? [Double] {
                yArray = array
            }
            if let array = dataObjects?.value(forKey: "zAcceleration") as? [Double] {
                zArray = array
            }
            
            var xZeroCrossings = [Int]()
            var yZeroCrossings = [Int]()
            var zZeroCrossings = [Int]()
            if let array = dataObjects?.value(forKey: "xZeroCrossings") as? [Int] {
                xZeroCrossings = array
            }
            if let array = dataObjects?.value(forKey: "yZeroCrossings") as? [Int] {
                yZeroCrossings = array
            }
            if let array = dataObjects?.value(forKey: "zZeroCrossings") as? [Int] {
                zZeroCrossings = array
            }
            self.zeroCrossingsLabel.text = String(format:"ZERO-CROSSINGS X:%i Y:%i Z:%i",xZeroCrossings.reduce(0,+), yZeroCrossings.reduce(0,+), zZeroCrossings.reduce(0,+))
        case 1: // Since app launch
            if let array = realmHelper.getObjects(Data.self, valueForKey: "xAcceleration") as? [Double] {
                xArray = array
            }
            if let array = realmHelper.getObjects(Data.self, valueForKey: "yAcceleration") as? [Double] {
                yArray = array
            }
            if let array = realmHelper.getObjects(Data.self, valueForKey: "zAcceleration") as? [Double] {
                zArray = array
            }
        default:
            break
        }
        
        let xMean = calculateMean(xArray)
        let yMean = calculateMean(yArray)
        let zMean = calculateMean(zArray)
        
        countLabel.text = String(format:"COUNT X:%i Y:%i Z:%i",xArray.count, yArray.count, zArray.count)
        maxLabel.text = String(format:"MAX X:%4.2f Y:%4.2f Z:%4.2f",calculateMax(xArray), calculateMax(yArray), calculateMax(zArray))
        minLabel.text = String(format:"MIN X:%4.2f Y:%4.2f Z:%4.2f",calculateMin(xArray), calculateMin(yArray), calculateMin(zArray))
        meanLabel.text = String(format:"MEAN X:%4.2f Y:%4.2f Z:%4.2f",xMean, yMean, zMean)
        medianLabel.text = String(format:"MEDIAN X:%4.2f Y:%4.2f Z:%4.2f",calculateMedian(xArray), calculateMedian(yArray), calculateMedian(zArray))
        deviationLabel.text = String(format:"STDEV X:%4.2f Y:%4.2f Z:%4.2f",calculateStdev(xArray, mean:xMean), calculateStdev(yArray, mean:yMean), calculateStdev(zArray, mean:zMean))
    }
    
    /// Calculates minimum value in an array
    ///
    /// - Parameter array: array for which minimum value is to be calculated
    /// - Returns: minimum value
    func calculateMin(_ array: [Double]) -> Double {
        let arrayPointer = UnsafeMutablePointer(mutating: array)
        let intCount = Int32(array.count)
        return cppWrapper.min_array_wrapped(arrayPointer, count: intCount)
    }
    
    /// Calculates maximum value in an array
    ///
    /// - Parameter array: array for which maximum value is to be calculated
    /// - Returns: maximum value
    func calculateMax(_ array: [Double]) -> Double {
        let arrayPointer = UnsafeMutablePointer(mutating: array)
        let intCount = Int32(array.count)
        return cppWrapper.max_array_wrapped(arrayPointer, count: intCount)
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
    
    /// Calculates median of the values passed in an array
    ///
    /// - Parameter array: array of value for which median is to be calculated
    /// - Returns: calculated median value
    func calculateMedian(_ array: [Double]) -> Double {
        let arrayPointer = UnsafeMutablePointer(mutating: array)
        let intCount = Int32(array.count)
        return cppWrapper.median_array_wrapped(arrayPointer, count: intCount)
    }
    
    /// Calculates Standard Deviation for the values passed in an array
    ///
    /// - Parameter array: array of value for which Standard Deviation is to be calculated
    /// - Returns: calculated Standard Deviation
    func calculateStdev(_ array: [Double], mean: Double) -> Double {
        let arrayPointer = UnsafeMutablePointer(mutating: array)
        let intCount = Int32(array.count)
        return cppWrapper.stdev_array_wrapped(arrayPointer, mean: mean, count: intCount)
    }
    
    
    /// Checks the number of times values have crossed zero
    ///
    /// - Parameter acceleration: The acceleration input for caculating the crossings
    func checkCrossing(_ acceleration: CMAcceleration) -> (x: Int, y: Int, z: Int) {
        var xZeroCrossings = 0
        var yZeroCrossings = 0
        var zZeroCrossings = 0
        
        if (acceleration.x > 0.0 && !isXPositive) || (acceleration.x < 0.0  && isXPositive) {
            xZeroCrossings += 1
            isXPositive = !isXPositive
        }
        if (acceleration.y > 0.0 && !isYPositive) || (acceleration.y < 0.0  && isYPositive) {
            yZeroCrossings += 1
            isYPositive = !isYPositive
        }
        if (acceleration.z > 0.0 && !isZPositive) || (acceleration.z < 0.0  && isZPositive) {
            zZeroCrossings += 1
            isZPositive = !isZPositive
        }
        return (xZeroCrossings, yZeroCrossings, zZeroCrossings)
    }
    
    /// Called by timer to detect the motion type based on device's acceleration
    func detectMotion() {
        let acceleration = motion.userAcceleration
        let crossings = checkCrossing(acceleration)
        let data = Data()
        data.xAcceleration = acceleration.x
        data.yAcceleration = acceleration.y
        data.zAcceleration = acceleration.z
        data.xZeroCrossings = crossings.x
        data.yZeroCrossings = crossings.y
        data.zZeroCrossings = crossings.z
        data.date = Date()
        data.dateString = String(data.date.timeIntervalSince1970)
        realmHelper.writeToRealm({
            realmHelper.realm().add(data)
        })
        
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
            if motionManager.isGyroAvailable {
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
        secondaryTimer.invalidate()
        motionManager.stopDeviceMotionUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

