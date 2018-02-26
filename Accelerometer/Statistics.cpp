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

using namespace std;
void CPP::hello_cpp(const std::string& name) {
    cout << "Hello " << name << " in C++" << endl;
}
double CPP::mean_array( double *array, size_t count )
{
    double sum = std::accumulate(array,array+count,0.0);
    return sum / count;
}
void CPP::test()
{
    double array[3] = {1.0,2.0,3.0};
    int count = sizeof(array)/sizeof(double);
    double result = mean_array(array, count);
    cout << "Mean result: " << result << "\n";
}


