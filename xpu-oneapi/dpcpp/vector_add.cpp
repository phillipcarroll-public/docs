#include <iostream>
#include <vector>
#include <sycl/sycl.hpp>

int main() {
    const size_t N = 1024;
    std::vector<int> a(N), b(N), sum(N);

    for (size_t i = 0; i < N; ++i) {
        a[i] = i;
        b[i] = i * 2;
    }

    sycl::queue q;

    std::cout << "Running on device: " << q.get_device().get_info<sycl::info::device::name>() << "\n";

    q.parallel_for(sycl::range<1>(N), [=](sycl::id<1> i) {
        sum[i] = a[i] + b[i];
    }).wait();

    for (size_t i = 0; i < N; ++i) {
        if (sum[i] != a[i] + b[i]) {
            std::cout << "Verification failed!\n";
            return 1;
        }
    }

    std::cout << "Verification successful!\n";
    return 0;
}
