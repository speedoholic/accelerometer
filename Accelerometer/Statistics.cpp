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
template <int N>
double CPP::mean_array( double ( & array )[N] )
{
    return std::accumulate( array, array + N, 0.0) / (double)(N);
}


