#ifndef SOURCEMETA_REGISTRY_INDEX_OUTPUT_H_
#define SOURCEMETA_REGISTRY_INDEX_OUTPUT_H_

#include <sourcemeta/core/json.h>

#include "configuration.h"

#include <filesystem> // std::filesystem
#include <fstream>    // std::ofstream

class RegistryOutput {
public:
  RegistryOutput(std::filesystem::path path);

  // Just to prevent mistakes
  RegistryOutput(const RegistryOutput &) = delete;
  RegistryOutput &operator=(const RegistryOutput &) = delete;
  RegistryOutput(RegistryOutput &&) = delete;
  RegistryOutput &operator=(RegistryOutput &&) = delete;

  auto write_configuration(const RegistryConfiguration &configuration) -> void;
  auto write_schema_single(const std::filesystem::path &output,
                           const sourcemeta::core::JSON &schema) const -> void;
  auto write_schema_bundle(const std::filesystem::path &output,
                           const sourcemeta::core::JSON &schema) const -> void;
  auto
  write_schema_bundle_unidentified(const std::filesystem::path &output,
                                   const sourcemeta::core::JSON &schema) const
      -> void;

  template <typename Iterator>
  auto write_generated_jsonl(const std::filesystem::path &output,
                             Iterator begin, Iterator end) const -> void {
    static constexpr auto GENERATED_PREFIX{"generated"};
    this->internal_write_jsonl(std::filesystem::path{GENERATED_PREFIX} / output,
                               begin, end);
  }

  auto write_generated_json(const std::filesystem::path &output,
                            const sourcemeta::core::JSON &document) const
      -> void;

private:
  auto internal_write_json(const std::filesystem::path &output,
                           const sourcemeta::core::JSON &document) const
      -> void;
  auto internal_write_jsonschema(const std::filesystem::path &output,
                                 const sourcemeta::core::JSON &schema) const
      -> void;

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

#endif
