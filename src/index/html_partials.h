#ifndef SOURCEMETA_REGISTRY_INDEX_PARTIALS_H_
#define SOURCEMETA_REGISTRY_INDEX_PARTIALS_H_

#include <string_view> // std::string_view

namespace sourcemeta::registry::html::partials {
template <typename T> auto css(T &output, const std::string_view url) -> T & {
  output.open("link", {{"rel", "stylesheet"}, {"href", url}});
  return output;
}

template <typename T>
auto image(T &output, const std::string_view url, const std::uint64_t height,
           const std::uint64_t width, const std::string_view alt,
           const std::optional<std::string_view> classes) -> T & {
  if (classes.has_value()) {
    output.open("img", {{"src", url},
                        {"alt", alt},
                        {"height", std::to_string(height)},
                        {"width", std::to_string(width)},
                        {"class", classes.value()}});
  } else {
    output.open("img", {{"src", url},
                        {"alt", alt},
                        {"height", std::to_string(height)},
                        {"width", std::to_string(width)}});
  }

  return output;
}

template <typename T>
auto image(T &output, const std::string_view url, const std::uint64_t size,
           const std::string_view alt,
           const std::optional<std::string_view> classes) -> T & {
  return image(output, url, size, size, alt, classes);
}
} // namespace sourcemeta::registry::html::partials

#endif
