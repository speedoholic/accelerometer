//
//  CPP-Wrapper.h
//  Accelerometer
//
//  Created by Kushal Ashok on 2/25/18.
//  Copyright © 2018 Kushal Ashok. All rights reserved.
//

// Declaration: CPP-Wrapper.h
#import <Foundation/Foundation.h>

@interface CPP_Wrapper : NSObject
- (void)hello_cpp_wrapped:(NSString *)name;
- (double)min_array_wrapped:(double[])array count:(int)count;
- (double)max_array_wrapped:(double[])array count:(int)count;
- (double)mean_array_wrapped:(double[])array count:(int)count;
- (double)median_array_wrapped:(double[])array count:(int)count;
- (double)stdev_array_wrapped:(double[])array mean:(double)mean count:(int)count;
@end
