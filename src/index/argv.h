#ifndef SOURCEMETA_REGISTRY_INDEX_ARGV_H_
#define SOURCEMETA_REGISTRY_INDEX_ARGV_H_

#ifdef _WIN32
#include <windows.h> // GetModuleFileNameA
#elif defined(__APPLE__)
#include <cstdlib>       // realpath, free
#include <limits.h>      // PATH_MAX
#include <mach-o/dyld.h> // _NSGetExecutablePath
#else
#include <limits.h> // PATH_MAX
#include <unistd.h> // readlink
#endif

#include <filesystem> // std::filesystem::path
#include <string>     // std::string
#include <vector>     // std::vector

namespace sourcemeta::registry {

// TODO: Move to Core
auto executable_path(const int argc, const char *const argv[])
    -> const std::filesystem::path & {
  static std::filesystem::path path;
  if (path.empty()) {
    // If program was invoked with an absolute path, trust argv[0]
    if (argc > 0) {
      std::filesystem::path candidate(argv[0]);
      if (candidate.is_absolute()) {
        path = std::move(candidate);
        return path;
      }
    }

    // Fallback: platform-specific resolution
    std::string native_string;

#ifdef _WIN32
    // Retrieve path on Windows
    char buffer[MAX_PATH];
    DWORD length = GetModuleFileNameA(nullptr, buffer, MAX_PATH);
    if (length > 0 && length < MAX_PATH) {
      native_string.assign(buffer, length);
    }

#elif defined(__APPLE__)
    // Retrieve path on macOS
    uint32_t buffer_size = 0;
    _NSGetExecutablePath(nullptr, &buffer_size);
    std::vector<char> buffer(buffer_size);
    if (_NSGetExecutablePath(buffer.data(), &buffer_size) == 0) {
      if (char *resolved = realpath(buffer.data(), nullptr)) {
        native_string.assign(resolved);
        free(resolved);
      }
    }

#else
    // Retrieve path on GNU/Linux
    char buffer[PATH_MAX];
    ssize_t length = readlink("/proc/self/exe", buffer, sizeof(buffer) - 1);
    if (length != -1) {
      buffer[length] = '\0';
      native_string.assign(buffer, static_cast<std::size_t>(length));
    }
#endif

    path = std::filesystem::path(native_string);
  }

  return path;
}

} // namespace sourcemeta::registry

#endif // SOURCEMETA_REGISTRY_INDEX_ARGV_H_
