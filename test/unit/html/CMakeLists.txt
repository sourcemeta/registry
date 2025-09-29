sourcemeta_googletest(NAMESPACE sourcemeta PROJECT registry NAME html
  SOURCES html_test.cc html_escape_test.cc)

target_link_libraries(sourcemeta_registry_html_unit PRIVATE sourcemeta::registry::html)
