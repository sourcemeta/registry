#ifndef SOURCEMETA_REGISTRY_HTML_SAFE_H_
#define SOURCEMETA_REGISTRY_HTML_SAFE_H_

#include <initializer_list> // std::initializer_list
#include <string_view>      // std::string_view
#include <utility>          // std::pair

namespace sourcemeta::registry::html {
using Attribute = std::pair<std::string_view, std::string_view>;

template <typename T> class SafeOutput {
public:
  SafeOutput(T &output) : stream{output} {};

  auto doctype() -> SafeOutput & { return this->open("!DOCTYPE html"); }

  auto open(const std::string_view tag,
            std::initializer_list<Attribute> attributes = {}) -> SafeOutput & {
    this->stream << "<" << tag;
    for (const auto &attribute : attributes) {
      this->stream << " " << attribute.first;
      if (!attribute.second.empty()) {
        this->stream << "=\"" << attribute.second << "\"";
      }
    }
    this->stream << ">";
    return *this;
  }

  auto close(const std::string_view tag) -> SafeOutput & {
    this->stream << "</" << tag << ">";
    return *this;
  }

  auto text(const std::string_view content) -> SafeOutput & {
    // TODO: Perform escaping
    this->stream << content;
    return *this;
  }

private:
  T &stream;
};
} // namespace sourcemeta::registry::html

#endif
