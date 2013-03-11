#include <thrust/system_error.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/sort.h>
#include <thrust/copy.h>

#include <thrust/generate.h>
#include <thrust/reduce.h>
#include <thrust/functional.h>

#include <cuda.h>

// #include <algorithm>
#include <new>
#include <iostream>
#include <cstdlib>

#ifdef DEBUG
  size_t deviceFree()
  {
    const size_t MB = 1<<20;

    size_t reserved, total;
    cudaMemGetInfo( &reserved, &total );
    void* pool;
    while( cudaMalloc( (void**)&pool, reserved ) != cudaSuccess )
    {
        reserved -= MB;
        if( reserved < MB )
        {
            break;
        }
    }
    cudaFree(pool);
    return reserved;
  }

  size_t deviceFreeThrust()
  {
    const size_t MB = 1<<20;

    size_t reserved, total;
    cudaMemGetInfo( &reserved, &total );
    bool failed = true;
    thrust::device_vector<int> d_vec;
    while( failed )
    {
        try
        {
            d_vec.resize( reserved/sizeof(int) );
            //std::cout << reserved/sizeof(int) << std::endl;
            failed = false;
        }
        catch (...)
        {
        }
        reserved -= MB;
        if( reserved < MB )
        {
            break;
        }
    }
    d_vec.clear();
    return reserved;
  }
#endif


#ifdef  __cplusplus
extern "C" {
#endif

  //Sort for integer value, double key arrays
  void sort_int_by_key_wrapper( int& N, double* keys, int* values )
  {
#ifdef DEBUG
    size_t free, total;
    cudaMemGetInfo( &free , &total );
    free = deviceFreeThrust();

    // allocate and sort need two times the data memory
    const size_t memReq = N * sizeof( int ) * 2 +
                          N * sizeof( double ) * 2;
    if( free <= memReq )
    {
      std::cerr << "Not enough memory on your GPU!\n"
                << "You need at least      : " << memReq /1024/1024
                << "MiB\nof free global memory to sort this dataset.\n"
                << "Note: If you can, close your XSession to\n"
                << "      free some GPU memory.\n"
                << "      Run 'nvidia-smi' for further information."
                << std::endl;
      std::cerr << "Free Memory            : " << free/1024/1024  << "MiB" << std::endl; 
      std::cerr << "Total amount of memory : " << total/1024/1024 << "MiB" << std::endl;
      exit(-1);
    }
#endif

    thrust::device_vector<int> d_values;
    thrust::device_vector<double> d_keys;
    // transfer data to the device
    try
    {
      d_values.resize( N );
      d_keys.resize(   N );
      thrust::copy( values, values + N, d_values.begin() );
      thrust::copy( keys,   keys + N,   d_keys.begin()   );
    }
    catch(std::bad_alloc &e)
    {
      std::cerr << "Couldn't allocate device vectors" << std::endl;
      size_t free, total;
      cudaMemGetInfo (&free , &total);
      std::cerr << "Tried to allocate      : " << ( sizeof( int ) * N + sizeof( double ) * N )
                                                  /1024/1024 << "MiB" << std::endl;
      std::cerr << "Free Memory            : " << free/1024/1024  << "MiB" << std::endl;
      std::cerr << "Total amount of memory : " << total/1024/1024 << "MiB" << std::endl;
      exit(-1);
    }


    // sort data on the device
    //   note: the sort function we allocate at least
    //         the same amount of temporary data again
    //         than the device vector's size in memory
    try
    {
      thrust::sort_by_key( d_keys.begin(), d_keys.end(), d_values.begin() );
                   //, thrust::less<int>());
    }
    catch(std::bad_alloc &e)
    {
      std::cerr << "Ran out of memory while sorting" << std::endl;
      exit(-1);
    }
    catch(thrust::system_error &e)
    {
      std::cerr << "Some other error happened during sort: " << e.what() << std::endl;
      exit(-1);
    }

    // copy data back to host array
    thrust::copy(d_values.begin(), d_values.end(), values );
    thrust::copy(d_keys.begin(),   d_keys.end(),   keys   );

  }

  //Sort for integer arrays
  void sort_int_wrapper( int& N, int *data )
  {
#ifdef DEBUG
    size_t free, total;
    cudaMemGetInfo( &free , &total );
    free = deviceFreeThrust();

    // allocate and sort need two times the data memory
    if( free / sizeof( int ) / 2 <= N )
    {
      std::cerr << "Not enough memory on your GPU!\n"
                << "You need at least      : " << 2 * sizeof( int ) * N /1024/1024
                << "MiB\nof free global memory to sort this dataset.\n"
                << "Note: If you can, close your XSession to\n"
                << "      free some GPU memory.\n"
                << "      Run 'nvidia-smi' for further information."
                << std::endl;
      std::cerr << "Free Memory            : " << free/1024/1024  << "MiB" << std::endl; 
      std::cerr << "Total amount of memory : " << total/1024/1024 << "MiB" << std::endl;
      exit(-1);
    }
#endif

    thrust::device_vector<int> d_vec;
    // transfer data to the device
    try
    {
      d_vec.resize( N );
      thrust::copy( data, data + N, d_vec.begin());
    }
    catch(std::bad_alloc &e)
    {
      std::cerr << "Couldn't allocate device vector" << std::endl;
      size_t free, total;
      cudaMemGetInfo (&free , &total);
      std::cerr << "Tried to allocate      : " << sizeof( int ) * N /1024/1024 << "MiB" << std::endl;
      std::cerr << "Free Memory            : " << free/1024/1024  << "MiB" << std::endl;
      std::cerr << "Total amount of memory : " << total/1024/1024 << "MiB" << std::endl;
      exit(-1);
    }


    // sort data on the device
    //   note: the sort function we allocate at least
    //         the same amount of temporary data again
    //         than the device vector's size in memory
    try
    {
      thrust::sort(d_vec.begin(), d_vec.end() );
                   //, thrust::less<int>());
    }
    catch(std::bad_alloc &e)
    {
      std::cerr << "Ran out of memory while sorting" << std::endl;
      exit(-1);
    }
    catch(thrust::system_error &e)
    {
      std::cerr << "Some other error happened during sort: " << e.what() << std::endl;
      exit(-1);
    }

    // copy data back to host array
    thrust::copy(d_vec.begin(), d_vec.end(), data);

  }

#ifdef  __cplusplus
}
#endif

