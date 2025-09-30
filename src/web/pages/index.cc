#include <sourcemeta/registry/web.h>

#include "../helpers.h"
#include "../page.h"

#include <sourcemeta/registry/html.h>
#include <sourcemeta/registry/shared.h>

#include <chrono>     // std::chrono
#include <filesystem> // std::filesystem
#include <sstream>    // std::ostringstream

namespace {

auto make_hero(const sourcemeta::registry::Configuration &configuration)
    -> sourcemeta::registry::html::HTML {
  using namespace sourcemeta::registry::html;
  if (configuration.html->hero.has_value()) {
    return div({{"class", "container-fluid px-4"}},
               div({{"class", "bg-light border border-light-subtle mt-4 "
                              "px-3 py-3"}},
                   raw(configuration.html->hero.value())));
  }
  return div();
}

} // anonymous namespace

namespace sourcemeta::registry {

auto GENERATE_WEB_INDEX::handler(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const Context &configuration) -> void {
  const auto timestamp_start{std::chrono::steady_clock::now()};

  const auto directory{read_json(dependencies.front())};
  const auto &canonical{directory.at("url").to_string()};
  const auto title{configuration.html->name + " Schemas"};
  const auto &description{configuration.html->description};
  std::ostringstream html_content;
  html_content << "<!DOCTYPE html>"
               << html::make_page(configuration, canonical, title, description,
                                  make_hero(configuration),
                                  html::make_file_manager(directory));

  const auto timestamp_end{std::chrono::steady_clock::now()};
  std::filesystem::create_directories(destination.parent_path());
  write_text(destination, html_content.str(), "text/html", Encoding::GZIP,
             sourcemeta::core::JSON{nullptr},
             std::chrono::duration_cast<std::chrono::milliseconds>(
                 timestamp_end - timestamp_start));
}

} // namespace sourcemeta::registry
