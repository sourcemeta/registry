#ifndef SOURCEMETA_REGISTRY_HTML_ENCODER_H_
#define SOURCEMETA_REGISTRY_HTML_ENCODER_H_

#include <sourcemeta/registry/html_escape.h>

#include <iostream> // std::ostream
#include <map>      // std::map
#include <string>   // std::string
#include <variant>  // std::variant, std::holds_alternative, std::get
#include <vector>   // std::vector

namespace sourcemeta::registry::html {

using Attributes = std::map<std::string, std::string>;

// Forward declaration
class HTML;

// Raw HTML content wrapper for unescaped content
struct RawHTML {
  std::string content;
  explicit RawHTML(std::string html_content)
      : content{std::move(html_content)} {}
};

// A node can be either a string (text node), raw HTML content, or another HTML
// element
using Node = std::variant<std::string, RawHTML, HTML>;

class HTML {
public:
  HTML(std::string tag, bool self_closing_tag = false)
      : tag_name(std::move(tag)), self_closing(self_closing_tag) {}

  HTML(std::string tag, Attributes tag_attributes,
       bool self_closing_tag = false)
      : tag_name(std::move(tag)), attributes(std::move(tag_attributes)),
        self_closing(self_closing_tag) {}

  HTML(std::string tag, Attributes tag_attributes, std::vector<Node> children)
      : tag_name(std::move(tag)), attributes(std::move(tag_attributes)),
        child_elements(std::move(children)), self_closing(false) {}

  HTML(std::string tag, Attributes tag_attributes, std::vector<HTML> children)
      : tag_name(std::move(tag)), attributes(std::move(tag_attributes)),
        self_closing(false) {
    child_elements.reserve(children.size());
    for (auto &child_element : children) {
      child_elements.emplace_back(std::move(child_element));
    }
  }

  HTML(std::string tag, std::vector<Node> children)
      : tag_name(std::move(tag)), child_elements(std::move(children)),
        self_closing(false) {}

  HTML(std::string tag, std::vector<HTML> children)
      : tag_name(std::move(tag)), self_closing(false) {
    child_elements.reserve(children.size());
    for (auto &child_element : children) {
      child_elements.emplace_back(std::move(child_element));
    }
  }

  template <typename... Children>
  HTML(std::string tag, Attributes tag_attributes, Children &&...children)
      : tag_name(std::move(tag)), attributes(std::move(tag_attributes)),
        self_closing(false) {
    (child_elements.push_back(std::forward<Children>(children)), ...);
  }

  template <typename... Children>
  HTML(std::string tag, Children &&...children)
      : tag_name(std::move(tag)), self_closing(false) {
    (child_elements.push_back(std::forward<Children>(children)), ...);
  }

  auto render() const -> std::string;

  // Stream operator declaration
  friend auto operator<<(std::ostream &output_stream, const HTML &html_element)
      -> std::ostream &;

private:
  std::string tag_name;
  Attributes attributes;
  std::vector<Node> child_elements;
  bool self_closing;

  auto render(const Node &child_element) const -> std::string;
};

// Raw HTML content wrapper - DANGER: Content is NOT escaped!
// Use with extreme caution and only with trusted content
auto raw(std::string html_content) -> RawHTML;

} // namespace sourcemeta::registry::html

#endif
