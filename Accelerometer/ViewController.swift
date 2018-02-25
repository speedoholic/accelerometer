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
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var magneticLabel: UILabel!
    
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
            if let deviceMotion = self.motionManager.deviceMotion {
                self.detectMotion(deviceMotion)
            }
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
            motionManager.startMagnetometerUpdates(to: OperationQueue.main, withHandler: { (magnetometer, error) in
                if self.motionManager.isMagnetometerActive {
                    if let field = magnetometer?.magneticField {
                        self.magneticLabel.text = String(format:"Raw X:%10.4f Y:%10.4f Z:%10.4f", field.x, field.y, field.z)
                        return
                    }
                }
                print("Raw Magnetometer not active")
            })
        } else {
            print("Magnetometer not available")
        }
    }
    
    func monitorAltitude() {
        var first = true
        var firstPressure = 0.0
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { (altitude, error) in
                if let altitude = altitude {
                    let pressure = Double(truncating: altitude.pressure)
                    let relativeAlitude = Double(truncating: altitude.relativeAltitude)
                    firstPressure = first ? pressure : firstPressure
                    first = false
                    let pressureChange = firstPressure - pressure
                    self.altitudeLabel.text = "Pressure Change: \(pressureChange), Altitude Change: \(relativeAlitude)"
                }
            })
        } else {
            print("Altimeter not available")
        }
    }
    
    func monitorDeviceMotion() {
        motionManager.deviceMotionUpdateInterval = interval
        motionManager.startDeviceMotionUpdates()
        startTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSensorAvailable() {
            monitorDeviceMotion()
            monitorAltitude()
            monitorMagneticFields()
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

