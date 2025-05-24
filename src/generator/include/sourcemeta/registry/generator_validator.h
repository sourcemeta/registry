#ifndef SOURCEMETA_REGISTRY_GENERATOR_VALIDATOR_H_
#define SOURCEMETA_REGISTRY_GENERATOR_VALIDATOR_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>

#include <exception>     // std::exception
#include <string>        // std::string
#include <unordered_map> // std::unordered_map

namespace sourcemeta::registry {

class ValidatorError : public std::exception {
public:
  ValidatorError(const sourcemeta::blaze::SimpleOutput &output,
                 std::string message);

  [[nodiscard]] auto what() const noexcept -> const char * override;
  [[nodiscard]] auto stacktrace() const noexcept -> const std::string &;

private:
  const std::string message_;
  std::string stacktrace_;
};

class Validator {
public:
  Validator(const sourcemeta::core::SchemaResolver &resolver);

  // Just to prevent mistakes
  Validator(const Validator &) = delete;
  Validator &operator=(const Validator &) = delete;
  Validator(Validator &&) = delete;
  Validator &operator=(Validator &&) = delete;

  auto compile_once(const sourcemeta::core::JSON &schema) const
      -> sourcemeta::blaze::Template;
  auto compile(const std::string &cache_key,
               const sourcemeta::core::JSON &schema)
      -> const sourcemeta::blaze::Template &;

  auto validate_or_throw(const sourcemeta::core::JSON &schema,
                         const sourcemeta::core::JSON &instance,
                         std::string &&error) -> void;
  auto validate_or_throw(const std::string &cache_key,
                         const sourcemeta::core::JSON &schema,
                         const sourcemeta::core::JSON &instance,
                         std::string &&error) -> void;

private:
  const sourcemeta::core::SchemaResolver resolver_;
  const sourcemeta::core::SchemaWalker walker_{
      sourcemeta::core::schema_official_walker};
  const sourcemeta::blaze::Compiler compiler_{
      sourcemeta::blaze::default_schema_compiler};
  sourcemeta::blaze::Evaluator evaluator;
  std::unordered_map<std::string, sourcemeta::blaze::Template> cache_;
};

} // namespace sourcemeta::registry

#endif
