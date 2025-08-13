#ifndef SOURCEMETA_REGISTRY_INDEX_PARALLEL_H_
#define SOURCEMETA_REGISTRY_INDEX_PARALLEL_H_

#include <exception> // std::exception_ptr, std::current_exception, std::rethrow_exception
#include <functional> // std::function
#include <mutex>      // std::mutex, std::lock_guard
#include <queue>      // std::queue
#include <thread>     // std::thread
#include <utility>    // std::declval
#include <vector>     // std::vector

#include <pthread.h>

namespace sourcemeta::registry {

template <typename Iterator, typename WorkCallback>
auto parallel_for_each(Iterator first, Iterator last,
                       const WorkCallback &work_callback,
                       const std::size_t stack_size_bytes) -> void {
  std::queue<Iterator> tasks;
  for (auto iterator = first; iterator != last; ++iterator) {
    tasks.push(iterator);
  }

  std::mutex queue_mutex;
  std::mutex exception_mutex;

  std::exception_ptr exception = nullptr;
  auto handle_exception = [&exception_mutex,
                           &exception](std::exception_ptr pointer) {
    std::lock_guard<std::mutex> lock(exception_mutex);
    if (!exception) {
      exception = pointer;
    }
  };

  std::size_t parallelism{std::thread::hardware_concurrency()};
  if (parallelism == 0) {
    parallelism = 1;
  }

  std::vector<std::thread> workers;
  workers.reserve(parallelism);

  const auto total{tasks.size()};
  for (std::size_t index = 0; index < parallelism; ++index) {
    // We can't use std::thread, as it doesn't let
    // us tweak the thread stack size
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    assert(stack_size_bytes > 0);
    pthread_attr_setstacksize(&attr, stack_size_bytes);
    pthread_t handle;
    pthread_create(
        &handle, &attr,
        [](void *arg) -> void * {
          auto *fn = static_cast<std::function<void()> *>(arg);
          (*fn)();
          delete fn;
          return nullptr;
        },
        new std::function<void()>([&tasks, &queue_mutex, &work_callback,
                                   &handle_exception, parallelism, total] {
          const auto thread_id{std::this_thread::get_id()};
          try {
            while (true) {
              Iterator iterator;
              std::size_t cursor{0};
              {
                std::lock_guard<std::mutex> lock(queue_mutex);
                if (tasks.empty()) {
                  return;
                }
                iterator = tasks.front();
                cursor = total - tasks.size() + 1;
                tasks.pop();
              }
              const auto percentage{cursor * 100 / total};
              work_callback(*iterator, thread_id, parallelism, percentage);
            }
          } catch (...) {
            handle_exception(std::current_exception());
          }
        }));
    workers.emplace_back([handle] { pthread_join(handle, nullptr); });
    pthread_attr_destroy(&attr);
  }

  for (auto &thread : workers) {
    thread.join();
  }

  if (exception) {
    std::rethrow_exception(exception);
  }
}

} // namespace sourcemeta::registry

#endif
