#include <sourcemeta/registry/web.h>

#include "../helpers.h"
#include "../page.h"

#include <sourcemeta/registry/html.h>
#include <sourcemeta/registry/shared.h>

#include <cassert>    // assert
#include <chrono>     // std::chrono
#include <filesystem> // std::filesystem
#include <functional> // std::reference_wrapper
#include <sstream>    // std::ostringstream
#include <vector>     // std::vector

namespace sourcemeta::registry {

auto GENERATE_WEB_SCHEMA::handler(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const Context &configuration) -> void {
  const auto timestamp_start{std::chrono::steady_clock::now()};

  const auto meta{read_json(dependencies.front())};
  const auto &canonical{meta.at("identifier").to_string()};
  const auto &title{meta.defines("title") ? meta.at("title").to_string()
                                          : meta.at("path").to_string()};
  const auto description{
      meta.defines("description")
          ? meta.at("description").to_string()
          : ("Schemas located at " + meta.at("path").to_string())};

  using namespace sourcemeta::registry::html;

  std::vector<Node> container_children;
  std::vector<Node> content_children;
  std::vector<Node> header_children;

  // Title and description
  if (meta.defines("title")) {
    header_children.emplace_back(h2({{"class", "fw-bold h4"}}, title));
  }

  if (meta.defines("description")) {
    header_children.emplace_back(
        p({{"class", "text-secondary"}}, meta.at("description").to_string()));
  }

  // Action buttons
  if (meta.at("protected").to_boolean()) {
    header_children.emplace_back(
        a({{"href", meta.at("path").to_string() + ".json"},
           {"class", "btn btn-primary me-2 disabled"},
           {"aria-disabled", "true"},
           {"role", "button"}},
          "Get JSON Schema"));
    header_children.emplace_back(
        a({{"href", meta.at("path").to_string() + ".json?bundle=1"},
           {"class", "btn btn-secondary disabled"},
           {"aria-disabled", "true"},
           {"role", "button"}},
          "Bundle"));
  } else {
    header_children.emplace_back(
        a({{"href", meta.at("path").to_string() + ".json"},
           {"class", "btn btn-primary me-2"},
           {"role", "button"}},
          "Get JSON Schema"));
    header_children.emplace_back(
        a({{"href", meta.at("path").to_string() + ".json?bundle=1"},
           {"class", "btn btn-secondary"},
           {"role", "button"}},
          "Bundle"));
  }

  content_children.emplace_back(div(header_children));

  // Information table
  std::vector<Node> table_rows;

  // Identifier row
  if (meta.at("protected").to_boolean()) {
    table_rows.emplace_back(
        tr(th({{"scope", "row"}, {"class", "text-nowrap"}}, "Identifier"),
           td(code(meta.at("identifier").to_string()))));
  } else {
    table_rows.emplace_back(
        tr(th({{"scope", "row"}, {"class", "text-nowrap"}}, "Identifier"),
           td(code(a({{"href", meta.at("identifier").to_string()}},
                     meta.at("identifier").to_string())))));
  }

  // Base Dialect row
  std::ostringstream badge_stream;
  badge_stream << html::make_dialect_badge(meta.at("baseDialect").to_string());
  table_rows.emplace_back(
      tr(th({{"scope", "row"}, {"class", "text-nowrap"}}, "Base Dialect"),
         td(raw(badge_stream.str()))));

  // Dialect row
  table_rows.emplace_back(
      tr(th({{"scope", "row"}, {"class", "text-nowrap"}}, "Dialect"),
         td(code(meta.at("dialect").to_string()))));

  // Health row
  table_rows.emplace_back(
      tr(th({{"scope", "row"}, {"class", "text-nowrap"}}, "Health"),
         td({{"class", "align-middle"}},
            div({{"style", "max-width: 300px"}},
                html::make_schema_health_progress_bar(
                    meta.at("health").to_integer())))));

  // Size row
  table_rows.emplace_back(tr(
      th({{"scope", "row"}, {"class", "text-nowrap"}}, "Size"),
      td(std::to_string(meta.at("bytes").as_real() / (1024 * 1024)) + " MB")));

  content_children.emplace_back(
      table({{"class", "table table-bordered my-4"}}, table_rows));
  content_children.emplace_back(div({})); // Close div for content

  container_children.emplace_back(div(content_children));

  // Alert section
  if (meta.at("protected").to_boolean()) {
    std::string alert_text =
        meta.at("alert").is_string()
            ? meta.at("alert").to_string()
            : "This schema is marked as protected. It is listed, but it "
              "cannot be directly accessed";
    container_children.emplace_back(
        div({{"class", "alert alert-warning"}, {"role", "alert"}}, alert_text));
  } else {
    if (meta.at("alert").is_string()) {
      container_children.emplace_back(
          div({{"class", "alert alert-warning mb-3"}, {"role", "alert"}},
              meta.at("alert").to_string()));
    }

    container_children.emplace_back(
        div({{"id", "schema"},
             {"class", "border overflow-auto"},
             {"style", "max-height: 400px;"},
             {"data-sourcemeta-ui-editor", meta.at("path").to_string()},
             {"data-sourcemeta-ui-editor-mode", "readonly"},
             {"data-sourcemeta-ui-editor-language", "json"}},
            "Loading schema..."));
  }

  const auto dependencies_json{read_json(dependencies.at(1))};
  const auto health{read_json(dependencies.at(2))};
  assert(health.is_object());
  assert(health.defines("errors"));

  // Tab navigation
  std::vector<Node> nav_items;
  nav_items.emplace_back(li(
      {{"class", "nav-item"}},
      button(
          {{"class", "nav-link"},
           {"type", "button"},
           {"role", "tab"},
           {"data-sourcemeta-ui-tab-target", "examples"}},
          span("Examples"),
          span({{"class",
                 "ms-2 badge rounded-pill text-bg-secondary align-text-top"}},
               std::to_string(meta.at("examples").size())))));
  nav_items.emplace_back(li(
      {{"class", "nav-item"}},
      button(
          {{"class", "nav-link"},
           {"type", "button"},
           {"role", "tab"},
           {"data-sourcemeta-ui-tab-target", "dependencies"}},
          span("Dependencies"),
          span({{"class",
                 "ms-2 badge rounded-pill text-bg-secondary align-text-top"}},
               std::to_string(dependencies_json.size())))));
  nav_items.emplace_back(li(
      {{"class", "nav-item"}},
      button(
          {{"class", "nav-link"},
           {"type", "button"},
           {"role", "tab"},
           {"data-sourcemeta-ui-tab-target", "health"}},
          span("Health"),
          span({{"class",
                 "ms-2 badge rounded-pill text-bg-secondary align-text-top"}},
               std::to_string(health.at("errors").size())))));

  container_children.emplace_back(
      ul({{"class", "nav nav-tabs mt-4 mb-3"}}, nav_items));

  // Examples tab
  std::vector<Node> examples_content;
  if (meta.at("examples").empty()) {
    examples_content.emplace_back(p("This schema declares 0 examples."));
  } else {
    std::vector<Node> example_items;
    for (const auto &example : meta.at("examples").as_array()) {
      std::ostringstream pretty;
      sourcemeta::core::prettify(example, pretty);
      example_items.emplace_back(
          pre({{"class", "bg-light p-2 border"}},
              code({{"class", "d-block text-primary"}}, pretty.str())));
    }
    examples_content.emplace_back(
        div({{"class", "list-group"}}, example_items));
  }
  container_children.emplace_back(
      div({{"data-sourcemeta-ui-tab-id", "examples"}, {"class", "d-none"}},
          examples_content));

  // Dependencies tab
  std::vector<std::reference_wrapper<const sourcemeta::core::JSON>> direct;
  std::vector<std::reference_wrapper<const sourcemeta::core::JSON>> indirect;
  for (const auto &dependency : dependencies_json.as_array()) {
    if (dependency.at("from") == meta.at("identifier")) {
      direct.emplace_back(dependency);
    } else {
      indirect.emplace_back(dependency);
    }
  }
  std::ostringstream dependency_summary;
  dependency_summary << "This schema has " << direct.size() << " direct "
                     << (direct.size() == 1 ? "dependency" : "dependencies")
                     << " and " << indirect.size() << " indirect "
                     << (indirect.size() == 1 ? "dependency" : "dependencies")
                     << ".";

  std::vector<Node> dependencies_content;
  dependencies_content.emplace_back(p(dependency_summary.str()));

  if (direct.size() + indirect.size() > 0) {
    std::vector<Node> dep_table_rows;
    for (const auto &dependency : dependencies_json.as_array()) {
      std::vector<Node> row_cells;

      if (dependency.at("from") == meta.at("identifier")) {
        std::ostringstream dependency_attribute;
        sourcemeta::core::stringify(dependency.at("at"), dependency_attribute);
        row_cells.emplace_back(
            td(a({{"href", "#"},
                  {"data-sourcemeta-ui-editor-highlight",
                   meta.at("path").to_string()},
                  {"data-sourcemeta-ui-editor-highlight-pointers",
                   dependency_attribute.str()}},
                 code(dependency.at("at").to_string()))));
      } else {
        row_cells.emplace_back(
            td(span({{"class", "badge text-bg-dark"}}, "Indirect")));
      }

      if (dependency.at("to").to_string().starts_with(configuration.url)) {
        std::filesystem::path dependency_schema_url{
            dependency.at("to").to_string().substr(configuration.url.size())};
        row_cells.emplace_back(
            td(code(a({{"href", dependency_schema_url.string()}},
                      dependency_schema_url.string()))));
      } else {
        row_cells.emplace_back(td(code(dependency.at("to").to_string())));
      }

      dep_table_rows.emplace_back(tr(row_cells));
    }

    dependencies_content.emplace_back(
        table({{"class", "table table-bordered"}},
              thead(tr(th({{"scope", "col"}}, "Origin"),
                       th({{"scope", "col"}}, "Dependency"))),
              tbody(dep_table_rows)));
  }
  container_children.emplace_back(
      div({{"data-sourcemeta-ui-tab-id", "dependencies"}, {"class", "d-none"}},
          dependencies_content));

  // Health tab
  const auto errors_count{health.at("errors").size()};
  std::vector<Node> health_content;
  if (errors_count == 1) {
    health_content.emplace_back(p(
        "This schema has " + std::to_string(errors_count) + " quality error."));
  } else {
    health_content.emplace_back(p("This schema has " +
                                  std::to_string(errors_count) +
                                  " quality errors."));
  }

  if (errors_count > 0) {
    std::vector<Node> error_items;
    for (const auto &error : health.at("errors").as_array()) {
      assert(error.at("pointers").size() >= 1);
      std::ostringstream pointers;
      sourcemeta::core::stringify(error.at("pointers"), pointers);

      std::vector<Node> error_children;
      error_children.emplace_back(
          code({{"class", "d-block text-primary"}},
               error.at("pointers").front().to_string()));
      error_children.emplace_back(
          small({{"class", "d-block text-body-secondary"}},
                error.at("name").to_string()));
      error_children.emplace_back(
          p({{"class", "mb-0 mt-2"}}, error.at("message").to_string()));
      if (error.at("description").is_string()) {
        error_children.emplace_back(
            small({{"class", "mt-2"}}, error.at("description").to_string()));
      }

      error_items.emplace_back(a(
          {{"href", "#"},
           {"data-sourcemeta-ui-editor-highlight", meta.at("path").to_string()},
           {"data-sourcemeta-ui-editor-highlight-pointers", pointers.str()},
           {"class", "list-group-item list-group-item-action py-3"}},
          error_children));
    }
    health_content.emplace_back(div({{"class", "list-group"}}, error_items));
  }
  container_children.emplace_back(
      div({{"data-sourcemeta-ui-tab-id", "health"}, {"class", "d-none"}},
          health_content));

  std::ostringstream html_content;
  html_content << "<!DOCTYPE html>"
               << html::make_page(configuration, canonical, title, description,
                                  html::make_breadcrumb(meta.at("breadcrumb")),
                                  html::div({{"class", "container-fluid p-4"}},
                                            container_children));
  const auto timestamp_end{std::chrono::steady_clock::now()};

  std::filesystem::create_directories(destination.parent_path());
  write_text(destination, html_content.str(), "text/html", Encoding::GZIP,
             sourcemeta::core::JSON{nullptr},
             std::chrono::duration_cast<std::chrono::milliseconds>(
                 timestamp_end - timestamp_start));
}

} // namespace sourcemeta::registry
