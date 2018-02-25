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

    let motionManager = CMMotionManager()
    let interval = 0.5
    var timer = Timer()
    let altimeter = CMAltimeter()
    var altitude: CMAltitudeData?
    var first = true
    var firstPressure = 0.0
    let motionActivityManager = CMMotionActivityManager()
    var isSafe = true
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var magneticLabel: UILabel!
    
    func startSafetyCheck() {
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main, withHandler: { (motionActivity) in
                if let activity = motionActivity {
                    switch activity.confidence {
                    case .high:
                        fallthrough
                    case .medium:
                        print("High Confidence")
                        self.isSafe = !activity.running
                    case .low:
                        break
                    }
                }
            })
        }
    }
    
    func safetyCheck() {
        if !isSafe {
            timer.invalidate()
            print("Running not allowed")
            let alert = UIAlertController(title: "DON'T RUN", message: "Running is not allowed", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default, handler: { (action) in
                self.isSafe = true
                self.startTimer()
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func isSensorAvailable() -> Bool {
        if !motionManager.isAccelerometerAvailable {
            let alert = UIAlertController(title: "Not Supported", message: "This device is not supported. Please try using another device with accelerometer", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            print("Sensor not detected")
        }
        return motionManager.isAccelerometerAvailable
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (timer) in
            self.safetyCheck()
            if let deviceMotion = self.motionManager.deviceMotion {
                self.detectMotion(deviceMotion)
            }
            if self.motionManager.isMagnetometerActive {
                if let field = self.motionManager.magnetometerData?.magneticField {
                    self.magneticLabel.text = String(format:"Raw X:%10.4f Y:%10.4f Z:%10.4f", field.x, field.y, field.z)
                }
            }
            self.updateAltitude()
            print("Raw Magnetometer not active")
        })
    }
    
    func detectMotion(_ deviceMotion: CMDeviceMotion) {
        let acceleration = deviceMotion.userAcceleration
        self.valueLabel.text = String(format:"X:%7.4f Y:%7.4f Z:%7.4f",acceleration.x, acceleration.y, acceleration.z)
        print(self.valueLabel.text!)
        
        let rotation = deviceMotion.attitude
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
                gyro = deviceMotion.rotationRate
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
    
    func monitorMagneticFields() {
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = interval
            motionManager.startMagnetometerUpdates()
        } else {
            print("Magnetometer not available")
        }
    }
    
    func monitorAltitude() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            let queue = OperationQueue()
            altimeter.startRelativeAltitudeUpdates(to: queue, withHandler: { (altitude, error) in
                if let altitude = altitude {
                    self.altitude = altitude
                }
            })
        } else {
            print("Altimeter not available")
        }
    }
    
    func updateAltitude() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            if let altitude = self.altitude {
                let pressure = Double(truncating: altitude.pressure)
                let relativeAlitude = Double(truncating: altitude.relativeAltitude)
                firstPressure = first ? pressure : firstPressure
                first = false
                let pressureChange = firstPressure - pressure
                self.altitudeLabel.text = "Pressure Change: \(pressureChange), Altitude Change: \(relativeAlitude)"
            }
        }
    }
    
    func monitorDeviceMotion() {
        motionManager.deviceMotionUpdateInterval = interval
        motionManager.startDeviceMotionUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSensorAvailable() {
            startTimer()
            monitorDeviceMotion()
            monitorAltitude()
            monitorMagneticFields()
            startSafetyCheck()
            print("Core Motion Launched")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        motionManager.stopDeviceMotionUpdates()
        altimeter.stopRelativeAltitudeUpdates()
        motionManager.stopMagnetometerUpdates()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

