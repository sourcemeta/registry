#ifndef SOURCEMETA_REGISTRY_HTTPSERVER_LOGGER_H
#define SOURCEMETA_REGISTRY_HTTPSERVER_LOGGER_H

#include <sourcemeta/core/uuid.h>
#include <sourcemeta/hydra/http.h>

#include <chrono>      // std::chrono::system_clock
#include <iostream>    // std::cerr
#include <mutex>       // std::mutex, std::lock_guard
#include <string>      // std::string
#include <string_view> // std::string_view
#include <thread>      // std::this_thread
#include <utility>     // std::move

class ServerLogger {
public:
  ServerLogger() : identifier{sourcemeta::core::uuidv4()} {};
  ServerLogger(std::string &&id) : identifier{std::move(id)} {};

  auto id() const -> std::string_view { return this->identifier; }

  auto operator<<(std::string_view message) const -> void {
    // Otherwise we can get messed up output interleaved from multiple threads
    static std::mutex log_mutex;
    std::lock_guard<std::mutex> guard{log_mutex};
    std::cerr << "["
              << sourcemeta::hydra::http::to_gmt(
                     std::chrono::system_clock::now())
              << "] " << std::this_thread::get_id() << " (" << this->id()
              << ") " << message << "\n";
  }

private:
  const std::string identifier;
};

#endif
