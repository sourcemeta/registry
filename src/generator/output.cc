#include <sourcemeta/registry/generator_output.h>

#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/md5.h>

#include <cassert> // assert
#include <sstream> // ostringstream

namespace sourcemeta::registry {

Output::Output(std::filesystem::path path)
    : path_{std::filesystem::weakly_canonical(path)} {
  // TODO: Index files in output first!
  std::filesystem::create_directories(this->path_);
}

auto Output::open(const std::filesystem::path &output) const -> std::ofstream {
  std::ofstream stream{output};
  assert(!stream.fail());
  return stream;
}

auto Output::internal_write_json(const std::filesystem::path &output,
                                 const sourcemeta::core::JSON &document) const
    -> std::filesystem::path {
  const auto destination{this->resolve(output)};
  std::filesystem::create_directories(destination.parent_path());
  auto stream{this->open(destination)};
  sourcemeta::core::stringify(document, stream);
  stream << "\n";
  return destination;
}

auto Output::internal_write_jsonschema(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &schema) const -> std::filesystem::path {
  const auto destination{this->resolve(output)};
  std::filesystem::create_directories(destination.parent_path());
  auto stream{this->open(destination)};
  sourcemeta::core::prettify(schema, stream,
                             sourcemeta::core::schema_format_compare);
  stream << "\n";
  return destination;
}

auto Output::resolve(const std::filesystem::path &path) const
    -> std::filesystem::path {
  assert(path.is_relative());
  // TODO: We need to have a "safe" path concat function that does not allow
  // the path to escape the parent. Make it part of Core
  return this->path_ / path;
}

auto Output::write_configuration(const Configuration &configuration) -> void {
  this->internal_write_json("configuration.json", configuration.summary());
}

auto Output::relative_path(const Category category) const
    -> std::filesystem::path {
  switch (category) {
    case Category::Schemas:
      return "schemas";
    case Category::Bundles:
      return "bundles";
    case Category::Explorer:
      return "";
    case Category::Navigation:
      return "explorer";
    case Category::Unidentified:
      return "unidentified";
    case Category::TemplateExhaustive:
      return "blaze/exhaustive";
    default:
      assert(false);
      return "";
  }
}

auto Output::absolute_path(const Category category) const
    -> std::filesystem::path {
  return this->resolve(this->relative_path(category));
}

auto Output::write_schema_single(const std::filesystem::path &output,
                                 const sourcemeta::core::JSON &schema) const
    -> std::filesystem::path {
  return this->internal_write_jsonschema("schemas" / output, schema);
}

auto Output::write_schema_bundle(const std::filesystem::path &output,
                                 const sourcemeta::core::JSON &schema) const
    -> std::filesystem::path {
  return this->internal_write_jsonschema("schemas" / output, schema);
}

auto Output::write_schema_bundle_unidentified(
    const std::filesystem::path &output,
    const sourcemeta::core::JSON &schema) const -> std::filesystem::path {
  return this->internal_write_jsonschema("schemas" / output, schema);
}

auto Output::write_schema_template_exhaustive(
    const std::filesystem::path &output,
    const sourcemeta::blaze::Template &compiled_schema) const
    -> std::filesystem::path {
  return this->internal_write_json(this->relative_path(Category::Explorer) /
                                       "schemas" / output,
                                   sourcemeta::blaze::to_json(compiled_schema));
}

auto Output::write_explorer_json(const std::filesystem::path &output,
                                 const sourcemeta::core::JSON &document) const
    -> void {
  this->internal_write_json(this->relative_path(Category::Navigation) / output,
                            document);
}

auto Output::write_metadata(const Category category,
                            const std::filesystem::path &output,
                            const sourcemeta::core::JSON &metadata) const
    -> std::filesystem::path {
  return this->internal_write_json(
      (this->relative_path(category) / output).string() + ".meta", metadata);
}

auto Output::read_metadata(const Category,
                           const std::filesystem::path &output) const
    -> sourcemeta::core::JSON {
  const std::filesystem::path absolute_path{this->resolve(output)};
  assert(std::filesystem::exists(absolute_path));
  return sourcemeta::core::read_json(absolute_path);
}

auto Output::md5(const Category category,
                 const std::filesystem::path &output) const -> std::string {
  const std::filesystem::path absolute_path{
      this->resolve(this->relative_path(category) / output)};
  std::ifstream stream{absolute_path};
  stream.exceptions(std::ifstream::failbit | std::ifstream::badbit);
  assert(!stream.fail());
  assert(stream.is_open());
  std::ostringstream contents;
  contents << stream.rdbuf();
  std::ostringstream md5;
  sourcemeta::core::md5(contents.str(), md5);
  return md5.str();
}

auto Output::last_modified(const Category category,
                           const std::filesystem::path &output) const
    -> std::chrono::system_clock::time_point {
  const std::filesystem::path absolute_path{
      this->resolve(this->relative_path(category) / output)};
  const auto last_write_time{std::filesystem::last_write_time(absolute_path)};
  return std::chrono::time_point_cast<std::chrono::system_clock::duration>(
      last_write_time - std::filesystem::file_time_type::clock::now() +
      std::chrono::system_clock::now());
}

} // namespace sourcemeta::registry
