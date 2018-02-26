//
//  Statistics.cpp
//  Accelerometer
//
//  Created by Kushal Ashok on 2/25/18.
//  Copyright © 2018 Kushal Ashok. All rights reserved.
//
#include "Statistics.hpp"
#include <iostream>
#include <numeric>
#include <algorithm>
#include <math.h>

using namespace std;
void CPP::hello_cpp(const std::string &name)
{
    cout << "Hello " << name << " in C++" << endl;
}
double CPP::min_array(const double *array, size_t count)
{
    return *std::min_element(array,array+count);
}
double CPP::max_array(const double *array, size_t count)
{
    return *std::max_element(array,array+count);
}
double CPP::mean_array(const double *array, size_t count)
{
    double sum = std::accumulate(array,array+count,0.0);
    return sum / count;
}
double CPP::median_array(double *a, size_t size)
{
    std::sort(&a[0], &a[size]);
    double median = size % 2 ? a[size / 2] : (a[size / 2 - 1] + a[size / 2]) / 2;
    return median;
}
double CPP::stdev_array(const double *a, const double mean, size_t size)
{
    double var = 0;
    for(int n = 0; n < size; n++ )
    {
        var += (a[n] - mean) * (a[n] - mean);
    }
    var /= size;
    double stdev = sqrt(var);
    return stdev;
}

