//
//  Statistics.hpp
//  Accelerometer
//
//  Created by Kushal Ashok on 2/25/18.
//  Copyright © 2018 Kushal Ashok. All rights reserved.
//

#ifndef Statistics_hpp
#define Statistics_hpp

#pragma once
#include <string>
#include <stdio.h>
class CPP {
    public:
    void hello_cpp(const std::string& name);
    double min_array(const double *array, size_t count);
    double max_array(const double *array, size_t count);
    double mean_array(const double *array, size_t count);
    double median_array(double *array, size_t size);
    double stdev_array(const double *a, const double mean, size_t size);
};

#endif /* Statistics_hpp */




