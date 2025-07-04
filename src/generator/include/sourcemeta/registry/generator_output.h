#ifndef SOURCEMETA_REGISTRY_GENERATOR_OUTPUT_H_
#define SOURCEMETA_REGISTRY_GENERATOR_OUTPUT_H_

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/core/json.h>

#include <sourcemeta/registry/generator_configuration.h>

#include <chrono>     // std::chrono::system_clock::time_point
#include <filesystem> // std::filesystem
#include <fstream>    // std::ofstream

namespace sourcemeta::registry {

class Output {
public:
  Output(std::filesystem::path path);

  // Just to prevent mistakes
  Output(const Output &) = delete;
  Output &operator=(const Output &) = delete;
  Output(Output &&) = delete;
  Output &operator=(Output &&) = delete;

  enum class Category {
    Schemas,
    Bundles,
    Explorer,
    Navigation,
    Unidentified,
    TemplateExhaustive
  };

  auto relative_path(const Category category) const -> std::filesystem::path;
  auto absolute_path(const Category category) const -> std::filesystem::path;

  auto write_configuration(const Configuration &configuration) -> void;
  auto write_schema_single(const std::filesystem::path &output,
                           const sourcemeta::core::JSON &schema) const
      -> std::filesystem::path;
  auto write_schema_bundle(const std::filesystem::path &output,
                           const sourcemeta::core::JSON &schema) const
      -> std::filesystem::path;
  auto
  write_schema_bundle_unidentified(const std::filesystem::path &output,
                                   const sourcemeta::core::JSON &schema) const
      -> std::filesystem::path;
  auto write_schema_template_exhaustive(
      const std::filesystem::path &output,
      const sourcemeta::blaze::Template &compiled_schema) const
      -> std::filesystem::path;

  template <typename Iterator>
  auto write_search(Iterator begin, Iterator end) const -> void {
    this->internal_write_jsonl(
        std::filesystem::path{"explorer"} / "search.jsonl", begin, end);
  }

  auto write_explorer_json(const std::filesystem::path &output,
                           const sourcemeta::core::JSON &document) const
      -> void;
  auto write_metadata(const Category category,
                      const std::filesystem::path &output,
                      const sourcemeta::core::JSON &metadata) const
      -> std::filesystem::path;
  auto read_metadata(const Category category,
                     const std::filesystem::path &output) const
      -> sourcemeta::core::JSON;

  auto md5(const Category category, const std::filesystem::path &output) const
      -> std::string;
  auto last_modified(const Category category,
                     const std::filesystem::path &output) const
      -> std::chrono::system_clock::time_point;

  auto internal_write_json(const std::filesystem::path &output,
                           const sourcemeta::core::JSON &document) const
      -> std::filesystem::path;
  auto internal_write_jsonschema(const std::filesystem::path &output,
                                 const sourcemeta::core::JSON &schema) const
      -> std::filesystem::path;

  // TODO: Move this up as a writing mechanism of sourcemeta::core::JSONL
  template <typename Iterator>
  auto internal_write_jsonl(const std::filesystem::path &output, Iterator begin,
                            Iterator end) const -> void {
    const auto destination{this->resolve(output)};
    std::filesystem::create_directories(destination.parent_path());
    auto stream{this->open(destination)};
    for (auto iterator = begin; iterator != end; iterator++) {
      sourcemeta::core::stringify(*iterator, stream);
      stream << "\n";
    }
  }

  auto resolve(const std::filesystem::path &path) const
      -> std::filesystem::path;
  auto open(const std::filesystem::path &output) const -> std::ofstream;

  const std::filesystem::path path_;
};

} // namespace sourcemeta::registry

#endif
