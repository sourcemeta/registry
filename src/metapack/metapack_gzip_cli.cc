#include <sourcemeta/core/io.h>
#include <sourcemeta/registry/metapack.h>

#include <cstdlib>    // EXIT_FAILURE, EXIT_SUCCESS
#include <exception>  // std::exception
#include <filesystem> // std::filesystem
#include <iostream>   // std::cout, std::cerr
#include <span>       // std::span

static auto write_main(const std::span<const std::string> &arguments) -> int {
  const std::filesystem::path output{arguments[2]};
  std::filesystem::create_directories(output.parent_path());
  auto stream{sourcemeta::core::read_file(arguments[0])};
  sourcemeta::registry::write_stream(
      output, arguments[1], sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{nullptr},
      [&stream](auto &target) { target << stream.rdbuf(); });
  return EXIT_SUCCESS;
}

auto main(int argc, char *argv[]) noexcept -> int {
  try {
    const std::vector<std::string> arguments{argv + std::min(1, argc),
                                             argv + argc};
    if (arguments.size() < 3) {
      std::cout << "Usage: " << argv[0] << " <input> <mime> <output>\n";
      return EXIT_FAILURE;
    }

    return write_main(arguments);
  } catch (const std::exception &error) {
    std::cerr << "unexpected error: " << error.what() << "\n";
    return EXIT_FAILURE;
  }
}
