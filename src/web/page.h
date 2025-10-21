#ifndef SOURCEMETA_REGISTRY_WEB_PAGE_H_
#define SOURCEMETA_REGISTRY_WEB_PAGE_H_

#include <sourcemeta/registry/configuration.h>
#include <sourcemeta/registry/html.h>
#include <sourcemeta/registry/shared.h>

#include <optional>    // std::optional
#include <sstream>     // std::ostringstream
#include <string>      // std::string
#include <string_view> // std::string_view
#include <vector>      // std::vector

namespace sourcemeta::registry::html {

inline auto make_navigation(const Configuration &configuration) -> HTML {
  auto container =
      div({{"class", "container-fluid px-4 py-1 align-items-center "
                     "flex-column flex-md-row"}},
          a({{"class", "navbar-brand me-0 me-md-3 d-flex align-items-center "
                       "w-100 w-md-auto"},
             {"href", configuration.url}},
            span({{"class", "fw-bold me-1"}}, configuration.html->name),
            span({{"class", "fw-lighter"}}, " Schemas")),
          div({{"class",
                "mt-2 mt-md-0 flex-grow-1 position-relative w-100 w-md-auto"}},
              div({{"class", "input-group"}},
                  span({{"class", "input-group-text"}},
                       i({{"class", "bi bi-search"}})),
                  input({{"class", "form-control"},
                         {"type", "search"},
                         {"id", "search"},
                         {"placeholder", "Search"},
                         {"aria-label", "Search"},
                         {"autocomplete", "off"}})),
              ul({{"class",
                   "d-none list-group position-absolute w-100 mt-2 shadow-sm"},
                  {"id", "search-result"}})));

  if (configuration.html->action.has_value()) {
    container.push_back(a(
        {{"class", "ms-md-3 btn btn-dark mt-2 mt-md-0 w-100 w-md-auto"},
         {"role", "button"},
         {"href", configuration.html->action.value().url}},
        i({{"class", "me-2 bi bi-" + configuration.html->action.value().icon}}),
        configuration.html->action.value().title));
  }

  return nav({{"class", "navbar navbar-expand border-bottom bg-body"}},
             std::move(container));
}

inline auto make_footer() -> HTML {
  std::ostringstream information;
  information << " v" << version() << " © 2025 ";

  return div(
      {{"class", "container-fluid px-4 mb-2"}},
      footer(
          {{"class", "border-top text-secondary py-3 d-flex align-items-center "
                     "justify-content-between flex-column flex-md-row"}},
          small({{"class", "mb-2 mb-md-0"}},
                img({{"src", "/self/static/icon.svg"},
                     {"alt", "Sourcemeta"},
                     {"height", "25"},
                     {"width", "25"},
                     {"class", "me-2"}}),
                a({{"href", "https://github.com/sourcemeta/registry"},
                   {"class", "text-secondary"},
                   {"target", "_blank"}},
                  "Registry"),
                information.str(),
                a({{"href", "https://www.sourcemeta.com"},
                   {"class", "text-secondary"},
                   {"target", "_blank"}},
                  "Sourcemeta")),
          small(
              a({{"href", "https://github.com/sourcemeta/registry/discussions"},
                 {"class", "text-secondary"},
                 {"target", "_blank"}},
                i({{"class", "bi bi-question-square me-2"}}), "Need Help?"))));
}

inline auto make_head(const Configuration &configuration,
                      const std::string &canonical,
                      const std::string &page_title,
                      const std::string &description) -> HTML {
  return head(meta({{"charset", "utf-8"}}),
              meta({{"name", "referrer"}, {"content", "no-referrer"}}),
              meta({{"name", "viewport"},
                    {"content", "width=device-width, initial-scale=1.0"}}),
              meta({{"http-equiv", "x-ua-compatible"}, {"content", "ie=edge"}}),
              title(page_title),
              meta({{"name", "description"}, {"content", description}}),
              link({{"rel", "canonical"}, {"href", canonical}}),
              link({{"rel", "stylesheet"},
                    {"href",
                     // For cache busting, to force browsers to refresh styles
                     // on any update
                     "/self/static/style.min.css?v=" + std::string{stamp()}}}),
              link({{"rel", "icon"},
                    {"href", "/self/static/favicon.ico"},
                    {"sizes", "any"}}),
              link({{"rel", "icon"},
                    {"href", "/self/static/icon.svg"},
                    {"type", "image/svg+xml"}}),
              link({{"rel", "shortcut icon"},
                    {"href", "/self/static/apple-touch-icon.png"},
                    {"type", "image/png"}}),
              link({{"rel", "apple-touch-icon"},
                    {"href", "/self/static/apple-touch-icon.png"},
                    {"sizes", "180x180"}}),
              link({{"rel", "manifest"},
                    {"href", "/self/static/manifest.webmanifest"}}),
              raw(configuration.html->head.value_or("")));
}

template <typename... Children>
inline auto make_page(const Configuration &configuration,
                      const std::string &canonical, const std::string &title,
                      const std::string &description, Children &&...children)
    -> HTML {
  std::vector<Node> nodes;
  nodes.push_back(make_navigation(configuration));
  (nodes.push_back(std::forward<Children>(children)), ...);
  nodes.push_back(make_footer());
  nodes.push_back(script(
      {{"async", ""},
       {"defer", ""},
       {"src",
        // For cache busting, to force browsers to refresh styles on any update
        "/self/static/main.min.js?v=" + std::string{stamp()}}}));
  return html({{"class", "h-100"}, {"lang", "en"}},
              make_head(configuration, canonical, title, description),
              body({{"class", "h-100 d-flex flex-column"}}, nodes));
}

} // namespace sourcemeta::registry::html

#endif
