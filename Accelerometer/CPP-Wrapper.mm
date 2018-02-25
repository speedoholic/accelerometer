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

- (void)hello_cpp_wrapped:(NSString *)name {
    CPP cpp;
    cpp.hello_cpp([name cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
