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
  // TODO: We need to have a "safe" path concat function that does not allow
  // the path to escape the parent. Make it part of Core
  return this->path_ / path;
}

auto RegistryOutput::write_configuration(
    const RegistryConfiguration &configuration) -> void {
  this->internal_write_json("configuration.json", configuration.summary());
}

auto RegistryOutput::relative_path(const Category category) const
    -> std::filesystem::path {
  switch (category) {
    case Category::Schemas:
      return "schemas";
    case Category::Bundles:
      return "bundles";
    case Category::Generated:
      return "generated";
    case Category::Unidentified:
      return "unidentified";
    default:
      assert(false);
      return "";
  }
}

auto RegistryOutput::absolute_path(const Category category) const
    -> std::filesystem::path {
  return this->resolve(this->relative_path(category));
}

auto RegistryOutput::write_schema_single(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &schema) const -> void {
  this->internal_write_jsonschema(
      this->relative_path(Category::Schemas) / output, schema);
}

auto RegistryOutput::write_schema_bundle(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &schema) const -> void {
  this->internal_write_jsonschema(
      this->relative_path(Category::Bundles) / output, schema);
}

auto RegistryOutput::write_schema_bundle_unidentified(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &schema) const -> void {
  this->internal_write_jsonschema(
      this->relative_path(Category::Unidentified) / output, schema);
}

auto RegistryOutput::write_generated_json(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &document) const -> void {
  this->internal_write_json(this->relative_path(Category::Generated) / output,
                            document);
}
