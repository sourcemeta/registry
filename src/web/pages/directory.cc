#include <sourcemeta/registry/web.h>

#include "../helpers.h"
#include "../page.h"

#include <sourcemeta/registry/html.h>
#include <sourcemeta/registry/shared.h>

#include <chrono>     // std::chrono
#include <filesystem> // std::filesystem

namespace sourcemeta::registry {

auto GENERATE_WEB_DIRECTORY::handler(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const Context &configuration) -> void {
  const auto timestamp_start{std::chrono::steady_clock::now()};

  const auto directory{read_json(dependencies.front())};
  const auto &canonical{directory.at("url").to_string()};
  const auto &title{directory.defines("title")
                        ? directory.at("title").to_string()
                        : directory.at("path").to_string()};
  const auto description{
      directory.defines("description")
          ? directory.at("description").to_string()
          : ("Schemas located at " + directory.at("path").to_string())};
  std::ostringstream html_content;
  html_content << "<!DOCTYPE html>"
               << html::make_page(
                      configuration, canonical, title, description,
                      html::make_breadcrumb(directory.at("breadcrumb")),
                      html::make_directory_header(directory),
                      html::make_file_manager(directory));

  const auto timestamp_end{std::chrono::steady_clock::now()};
  std::filesystem::create_directories(destination.parent_path());
  write_text(destination, html_content.str(), "text/html", Encoding::GZIP,
             sourcemeta::core::JSON{nullptr},
             std::chrono::duration_cast<std::chrono::milliseconds>(
                 timestamp_end - timestamp_start));
}

} // namespace sourcemeta::registry
