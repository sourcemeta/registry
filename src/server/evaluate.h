#ifndef SOURCEMETA_REGISTRY_SERVER_EVALUATE_H
#define SOURCEMETA_REGISTRY_SERVER_EVALUATE_H

#include <sourcemeta/core/json.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>

#include <cassert>    // assert
#include <filesystem> // std::filesystem::path

namespace sourcemeta::registry {

auto evaluate(const std::filesystem::path &template_path,
              const sourcemeta::core::JSON &instance)
    -> sourcemeta::core::JSON {
  assert(std::filesystem::exists(template_path));

  // TODO: Cache this conversion across runs, potentially using the schema file
  // "md5" as the cache key
  const auto template_json{sourcemeta::core::read_json(template_path)};
  const auto schema_template{sourcemeta::blaze::from_json(template_json)};

  sourcemeta::blaze::Evaluator evaluator;
  return sourcemeta::blaze::standard(evaluator, schema_template.value(),
                                     instance,
                                     sourcemeta::blaze::StandardOutput::Basic);
}

} // namespace sourcemeta::registry

#endif
