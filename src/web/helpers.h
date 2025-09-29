#ifndef SOURCEMETA_REGISTRY_WEB_HELPERS_H_
#define SOURCEMETA_REGISTRY_WEB_HELPERS_H_

#include <sourcemeta/registry/configuration.h>
#include <sourcemeta/registry/html.h>
#include <sourcemeta/registry/shared.h>

#include <cassert>     // assert
#include <optional>    // std::optional
#include <sstream>     // std::ostringstream
#include <string>      // std::string
#include <string_view> // std::string_view
#include <vector>      // std::vector

namespace sourcemeta::registry::html {

inline auto make_breadcrumb(const sourcemeta::core::JSON &breadcrumb) -> HTML {
  assert(breadcrumb.is_array());
  assert(!breadcrumb.empty());
  auto entries = ol({{"class", "breadcrumb mb-0"}},
                    li({{"class", "breadcrumb-item"}},
                       a({{"href", "/"}}, i({{"class", "bi bi-arrow-left"}}))));

  for (auto iterator = breadcrumb.as_array().cbegin();
       iterator != breadcrumb.as_array().cend(); ++iterator) {
    if (std::next(iterator) == breadcrumb.as_array().cend()) {
      entries.push_back(
          li({{"class", "breadcrumb-item active"}, {"aria-current", "page"}},
             iterator->at("name").to_string()));
    } else {
      entries.push_back(li({{"class", "breadcrumb-item"}},
                           a({{"href", iterator->at("path").to_string()}},
                             iterator->at("name").to_string())));
    }
  }

  return nav({{"class", "container-fluid px-4 py-2 bg-light bg-gradient "
                        "border-bottom font-monospace"},
              {"aria-label", "breadcrumb"}},
             std::move(entries));
}

inline auto
make_schema_health_progress_bar(const sourcemeta::core::JSON::Integer health)
    -> HTML {
  const auto [progress_class, progress_style] =
      [health]() -> std::pair<std::string, std::string> {
    if (health > 90) {
      return {"progress-bar text-bg-success",
              "width:" + std::to_string(health) + "%"};
    } else if (health > 60) {
      return {"progress-bar text-bg-warning",
              "width:" + std::to_string(health) + "%"};
    } else if (health == 0) {
      // Otherwise if we set width: 0px, then the label is not shown
      return {"progress-bar text-bg-danger", ""};
    } else {
      return {"progress-bar text-bg-danger",
              "width:" + std::to_string(health) + "%"};
    }
  }();

  Attributes attributes{{"class", progress_class}};
  if (!progress_style.empty()) {
    attributes["style"] = progress_style;
  }

  return div({{"class", "progress"},
              {"role", "progressbar"},
              {"aria-label", "Schema health score"},
              {"aria-valuenow", std::to_string(health)},
              {"aria-valuemin", "0"},
              {"aria-valuemax", "100"}},
             div(std::move(attributes), std::to_string(health) + "%"));
}

inline auto
make_dialect_badge(const sourcemeta::core::JSON::String &base_dialect_uri)
    -> HTML {
  const auto [short_name, is_current] =
      [&base_dialect_uri]() -> std::pair<std::string, bool> {
    if (base_dialect_uri == "https://json-schema.org/draft/2020-12/schema") {
      return {"2020-12", true};
    } else if (base_dialect_uri ==
               "https://json-schema.org/draft/2019-09/schema") {
      return {"2019-09", false};
    } else if (base_dialect_uri == "http://json-schema.org/draft-07/schema#") {
      return {"draft7", false};
    } else if (base_dialect_uri == "http://json-schema.org/draft-06/schema#") {
      return {"draft6", false};
    } else if (base_dialect_uri == "http://json-schema.org/draft-04/schema#") {
      return {"draft4", false};
    } else {
      return {"unknown", false};
    }
  }();

  // Capitalize first character
  std::string display_name = short_name;
  if (!display_name.empty()) {
    display_name[0] = static_cast<char>(std::toupper(display_name[0]));
  }

  return a({{"href", "https://www.learnjsonschema.com/" + short_name},
            {"target", "_blank"}},
           span({{"class", "align-middle badge " +
                               std::string(is_current ? "text-bg-primary"
                                                      : "text-bg-danger")}},
                display_name));
}

inline auto make_directory_header(const sourcemeta::core::JSON &directory)
    -> HTML {
  if (!directory.defines("title")) {
    return div();
  }

  std::vector<Node> children;

  if (directory.defines("github") && !directory.at("github").contains('/')) {
    children.push_back(
        img({{"src", "https://github.com/" +
                         directory.at("github").to_string() + ".png?size=200"},
             {"width", "100"},
             {"height", "100"},
             {"class", "img-thumbnail me-4"}}));
  }

  std::vector<Node> title_section_children;
  title_section_children.push_back(
      h2({{"class", "fw-bold h4"}}, directory.at("title").to_string()));

  if (directory.defines("description")) {
    title_section_children.push_back(
        p({{"class", "text-secondary"}},
          directory.at("description").to_string()));
  }

  if (directory.defines("email") || directory.defines("github") ||
      directory.defines("website")) {
    std::vector<Node> contact_children;

    if (directory.defines("github")) {
      contact_children.push_back(
          small({{"class", "me-3 d-block mb-2 mb-md-0 d-md-inline-block"}},
                i({{"class", "bi bi-github text-secondary me-1"}}),
                a({{"href",
                    "https://github.com/" + directory.at("github").to_string()},
                   {"class", "text-secondary"},
                   {"target", "_blank"}},
                  directory.at("github").to_string())));
    }

    if (directory.defines("website")) {
      contact_children.push_back(
          small({{"class", "me-3 d-block mb-2 mb-md-0 d-md-inline-block"}},
                i({{"class", "bi bi-link-45deg text-secondary me-1"}}),
                a({{"href", directory.at("website").to_string()},
                   {"class", "text-secondary"},
                   {"target", "_blank"}},
                  directory.at("website").to_string())));
    }

    if (directory.defines("email")) {
      contact_children.push_back(
          small({{"class", "me-3 d-block mb-2 mb-md-0 d-md-inline-block"}},
                i({{"class", "bi bi-envelope text-secondary me-1"}}),
                a({{"href", "mailto:" + directory.at("email").to_string()},
                   {"class", "text-secondary"}},
                  directory.at("email").to_string())));
    }

    title_section_children.push_back(div(contact_children));
  }

  children.push_back(div(title_section_children));
  return div({{"class", "container-fluid px-4 pt-4 d-flex"}},
             std::move(children));
}

inline auto make_file_manager(const sourcemeta::core::JSON &directory) -> HTML {
  if (directory.at("entries").empty()) {
    return div(
        {{"class", "container-fluid p-4 flex-grow-1"}},
        p("Things look a bit empty over here. Try ingesting some schemas using "
          "the configuration file!"));
  }

  auto tbody_content = tbody();
  for (const auto &entry : directory.at("entries").as_array()) {
    // Type column content
    auto type_content = [&entry]() -> HTML {
      if (entry.at("type").to_string() == "directory") {
        if (entry.defines("github") && !entry.at("github").contains('/')) {
          return img(
              {{"src", "https://github.com/" + entry.at("github").to_string() +
                           ".png?size=80"},
               {"width", "40"},
               {"height", "40"}});
        } else {
          return i({{"class", "bi bi-folder-fill"}});
        }
      } else {
        return make_dialect_badge(entry.at("baseDialect").to_string());
      }
    }();

    tbody_content.push_back(tr(
        td({{"class", "text-nowrap"}}, type_content),
        td({{"class", "font-monospace text-nowrap"}},
           a({{"href", entry.at("path").to_string()}},
             entry.at("name").to_string())),
        td(small(entry.defines("title") ? entry.at("title").to_string() : "-")),
        td(small(entry.defines("description")
                     ? entry.at("description").to_string()
                     : "-")),
        td({{"class", "align-middle"}},
           make_schema_health_progress_bar(entry.at("health").to_integer()))));
  }

  return div(
      {{"class", "container-fluid p-4 flex-grow-1"}},
      table({{"class", "table table-bordered border-light-subtle table-light"}},
            thead(tr(
                th({{"scope", "col"}, {"style", "width: 50px"}}),
                th({{"scope", "col"}}, "Name"), th({{"scope", "col"}}, "Title"),
                th({{"scope", "col"}}, "Description"),
                th({{"scope", "col"}, {"style", "width: 150px"}}, "Health"))),
            std::move(tbody_content)));
}

} // namespace sourcemeta::registry::html

#endif
