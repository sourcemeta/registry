#include <sourcemeta/registry/web.h>

#include "../helpers.h"
#include "../page.h"

#include <sourcemeta/registry/html.h>
#include <sourcemeta/registry/shared.h>

#include <chrono>     // std::chrono
#include <filesystem> // std::filesystem
#include <sstream>    // std::ostringstream

namespace sourcemeta::registry {

auto GENERATE_WEB_NOT_FOUND::handler(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path> &,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const Context &configuration) -> void {
  const auto timestamp_start{std::chrono::steady_clock::now()};

  const auto &canonical{configuration.url};
  const auto title{"Not Found"};
  const auto description{"What you are looking for is not here"};
  std::ostringstream html_content;
  html_content
      << "<!DOCTYPE html>"
      << html::make_page(
             configuration, canonical, title, description,
             html::div({{"class", "container-fluid p-4"}},
                       html::h2({{"class", "fw-bold"}},
                                "Oops! What you are looking for is not here"),
                       html::p({{"class", "lead"}},
                               "Are you sure the link you got is correct?"),
                       html::a({{"href", "/"}}, "Get back to the home page")));
  const auto timestamp_end{std::chrono::steady_clock::now()};

  std::filesystem::create_directories(destination.parent_path());
  write_text(destination, html_content.str(), "text/html", Encoding::GZIP,
             sourcemeta::core::JSON{nullptr},
             std::chrono::duration_cast<std::chrono::milliseconds>(
                 timestamp_end - timestamp_start));
}

} // namespace sourcemeta::registry
