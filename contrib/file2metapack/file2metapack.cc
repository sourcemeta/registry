#include <sourcemeta/core/options.h>
#include <sourcemeta/registry/shared.h>

#include <cstdlib>    // EXIT_FAILURE, EXIT_SUCCESS
#include <exception>  // std::exception
#include <filesystem> // std::filesystem
#include <iostream>   // std::cout, std::cerr

auto main(int argc, char *argv[]) noexcept -> int {
  try {
    sourcemeta::core::Options app;
    app.flag("gzip", {"g"});
    app.parse(argc, argv);
    if (app.positional().size() != 3) {
      std::cout << "Usage: " << argv[0] << " <input> <mime> <output>\n";
      return EXIT_FAILURE;
    }

    const std::filesystem::path output{app.positional().at(2)};
    std::filesystem::create_directories(output.parent_path());
    sourcemeta::registry::write_file(
        output, app.positional().at(0), std::string{app.positional().at(1)},
        app.contains("gzip") ? sourcemeta::registry::Encoding::GZIP
                             : sourcemeta::registry::Encoding::Identity,
        sourcemeta::core::JSON{nullptr}, std::chrono::milliseconds::zero());
    return EXIT_SUCCESS;
  } catch (const std::exception &error) {
    std::cerr << "unexpected error: " << error.what() << "\n";
    return EXIT_FAILURE;
  }
}
