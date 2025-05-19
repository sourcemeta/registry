#include "output.h"

#include <sourcemeta/core/jsonschema.h>

#include <cassert> // assert

RegistryOutput::RegistryOutput(std::filesystem::path path)
    : path_{std::filesystem::weakly_canonical(path)} {
  // TODO: Index files in output first!
  std::filesystem::create_directories(this->path_);
}

auto RegistryOutput::open(const std::filesystem::path &output) const
    -> std::ofstream {
  std::ofstream stream{output};
  assert(!stream.fail());
  return stream;
}

auto RegistryOutput::internal_write_json(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &document) const -> void {
  const auto destination{this->resolve(output)};
  std::filesystem::create_directories(destination.parent_path());
  auto stream{this->open(destination)};
  sourcemeta::core::stringify(document, stream);
  stream << "\n";
}

auto RegistryOutput::internal_write_jsonschema(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &schema) const -> void {
  const auto destination{this->resolve(output)};
  std::filesystem::create_directories(destination.parent_path());
  auto stream{this->open(destination)};
  sourcemeta::core::prettify(schema, stream,
                             sourcemeta::core::schema_format_compare);
  stream << "\n";
}

auto RegistryOutput::resolve(const std::filesystem::path &path) const
    -> std::filesystem::path {
  assert(path.is_relative());
  return this->path_ / path;
}

auto RegistryOutput::write_configuration(
    const RegistryConfiguration &configuration) -> void {
  this->internal_write_json("configuration.json", configuration.summary());
}

auto RegistryOutput::write_schema_single(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &schema) const -> void {
  static constexpr auto SCHEMAS_PREFIX{"schemas"};
  this->internal_write_jsonschema(
      std::filesystem::path{SCHEMAS_PREFIX} / output, schema);
}

auto RegistryOutput::write_schema_bundle(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &schema) const -> void {
  static constexpr auto BUNDLES_PREFIX{"bundles"};
  this->internal_write_jsonschema(
      std::filesystem::path{BUNDLES_PREFIX} / output, schema);
}

auto RegistryOutput::write_schema_bundle_unidentified(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &schema) const -> void {
  static constexpr auto UNIDENTIFIED_PREFIX{"unidentified"};
  this->internal_write_jsonschema(
      std::filesystem::path{UNIDENTIFIED_PREFIX} / output, schema);
}

auto RegistryOutput::write_generated_json(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &document) const -> void {
  static constexpr auto GENERATED_PREFIX{"generated"};
  this->internal_write_json(std::filesystem::path{GENERATED_PREFIX} / output,
                            document);
}
