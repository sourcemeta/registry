#ifndef SOURCEMETA_REGISTRY_SERVER_LOGGER_H
#define SOURCEMETA_REGISTRY_SERVER_LOGGER_H

#include <sourcemeta/hydra/http.h>

#include <chrono>      // std::chrono::system_clock
#include <iostream>    // std::cerr
#include <mutex>       // std::mutex, std::lock_guard
#include <string>      // std::string, std::getline
#include <string_view> // std::string_view
#include <thread>      // std::this_thread

namespace sourcemeta::registry {

class Logger {
public:
  auto operator<<(std::string_view message) const -> void {
    // Otherwise we can get messed up output interleaved from multiple threads
    static std::mutex log_mutex;
    std::lock_guard<std::mutex> guard{log_mutex};
    std::cerr << "["
              << sourcemeta::hydra::http::to_gmt(
                     std::chrono::system_clock::now())
              << "] " << std::this_thread::get_id() << " (" << this->identifier
              << ") " << message << "\n";
  }

  const std::string identifier;
};

} // namespace sourcemeta::registry

#endif
