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

- (double)mean_array_wrapped:(double[])array {
    return 0.0;
}


@end
