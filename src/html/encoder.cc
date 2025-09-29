#include <sourcemeta/registry/html_encoder.h>

#include <iostream> // std::ostream
#include <sstream>  // std::ostringstream
#include <string>   // std::string

namespace sourcemeta::registry::html {

auto HTML::render() const -> std::string {
  std::ostringstream output_stream;
  output_stream << "<" << tag_name;

  // Render attributes
  for (const auto &[attribute_name, attribute_value] : attributes) {
    std::string escaped_value{attribute_value};
    escape(escaped_value);
    output_stream << " " << attribute_name << "=\"" << escaped_value << "\"";
  }

  if (self_closing) {
    output_stream << " />";
    return output_stream.str();
  }

  output_stream << ">";

  // Render children
  if (child_elements.empty()) {
    output_stream << "</" << tag_name << ">";
  } else if (child_elements.size() == 1 &&
             std::get_if<std::string>(&child_elements[0])) {
    // Inline single text node
    output_stream << render(child_elements[0]);
    output_stream << "</" << tag_name << ">";
  } else {
    // Block level children
    for (const auto &child_element : child_elements) {
      output_stream << render(child_element);
    }
    output_stream << "</" << tag_name << ">";
  }

  return output_stream.str();
}

auto HTML::render(const Node &child_element) const -> std::string {
  if (const auto *text = std::get_if<std::string>(&child_element)) {
    std::string escaped_text{*text};
    escape(escaped_text);
    return escaped_text;
  } else if (const auto *raw_html = std::get_if<RawHTML>(&child_element)) {
    return raw_html->content;
  } else if (const auto *html_element = std::get_if<HTML>(&child_element)) {
    return html_element->render();
  }
  return "";
}

auto operator<<(std::ostream &output_stream, const HTML &html_element)
    -> std::ostream & {
  return output_stream << html_element.render();
}

auto raw(std::string html_content) -> RawHTML {
  return RawHTML{std::move(html_content)};
}

} // namespace sourcemeta::registry::html
