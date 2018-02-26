//
//  CPP-Wrapper.mm
//  Accelerometer
//
//  Created by Kushal Ashok on 2/25/18.
//  Copyright © 2018 Kushal Ashok. All rights reserved.
//

// Definition: CPP-Wrapper.mm
#import "CPP-Wrapper.h"
#include "Statistics.hpp"

@implementation CPP_Wrapper

CPP cpp;

- (void)hello_cpp_wrapped:(NSString *)name {
    cpp.hello_cpp([name cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (double)min_array_wrapped:(double[])array count:(int)count {
    return cpp.min_array(array, count);
}

- (double)max_array_wrapped:(double[])array count:(int)count {
    return cpp.max_array(array, count);
}

- (double)mean_array_wrapped:(double[])array count:(int)count {
    return cpp.mean_array(array, count);
}

- (double)median_array_wrapped:(double[])array count:(int)count {
    return cpp.median_array(array, count);
}

- (double)stdev_array_wrapped:(double[])array mean:(double)mean count:(int)count {
    return cpp.stdev_array(array, mean, count);
}

@end
