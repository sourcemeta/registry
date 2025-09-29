#ifndef SOURCEMETA_REGISTRY_HTML_ESCAPE_H_
#define SOURCEMETA_REGISTRY_HTML_ESCAPE_H_

#include <string> // std::string

namespace sourcemeta::registry::html {

// HTML character escaping implementation per HTML Living Standard
// See: https://html.spec.whatwg.org/multipage/parsing.html#escapingString
auto escape(std::string &text) -> void;

} // namespace sourcemeta::registry::html

#endif
