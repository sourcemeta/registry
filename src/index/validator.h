#ifndef SOURCEMETA_REGISTRY_GENERATOR_VALIDATOR_H_
#define SOURCEMETA_REGISTRY_GENERATOR_VALIDATOR_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>

#include <exception>     // std::exception
#include <functional>    // std::ref
#include <sstream>       // std::ostringstream
#include <string>        // std::string
#include <unordered_map> // std::unordered_map
#include <utility>       // std::move

namespace sourcemeta::registry {

class ValidatorError : public std::exception {
public:
  ValidatorError(const sourcemeta::blaze::SimpleOutput &output,
                 std::string message)
      : message_{std::move(message)} {
    std::ostringstream stream;
    output.stacktrace(stream);
    this->stacktrace_ = stream.str();
  }

  [[nodiscard]] auto what() const noexcept -> const char * {
    return this->message_.c_str();
  }

  [[nodiscard]] auto stacktrace() const noexcept -> const std::string & {
    return stacktrace_;
  }

private:
  const std::string message_;
  std::string stacktrace_;
};

class Validator {
public:
  Validator(const sourcemeta::core::SchemaResolver &resolver)
      : resolver_{resolver} {}

  // Just to prevent mistakes
  Validator(const Validator &) = delete;
  Validator &operator=(const Validator &) = delete;
  Validator(Validator &&) = delete;
  Validator &operator=(Validator &&) = delete;

  auto compile_once(const sourcemeta::core::JSON &schema) const
      -> sourcemeta::blaze::Template {
    return sourcemeta::blaze::compile(
        schema, this->walker_, this->resolver_, this->compiler_,
        // The point of this class is to show nice errors to the user
        sourcemeta::blaze::Mode::Exhaustive);
  }

  auto compile(const std::string &cache_key,
               const sourcemeta::core::JSON &schema)
      -> const sourcemeta::blaze::Template & {
    const auto match{this->cache_.find(cache_key)};
    return match == this->cache_.cend()
               ? this->cache_.emplace(cache_key, this->compile_once(schema))
                     .first->second
               : match->second;
  }

  auto validate_or_throw(const sourcemeta::core::JSON &schema,
                         const sourcemeta::core::JSON &instance,
                         std::string &&error) -> void {
    const auto schema_template{this->compile_once(schema)};
    sourcemeta::blaze::SimpleOutput output{instance};
    const auto result{
        this->evaluator.validate(schema_template, instance, std::ref(output))};
    if (!result) {
      throw ValidatorError(output, std::move(error));
    }
  }

  auto validate_or_throw(const std::string &cache_key,
                         const sourcemeta::core::JSON &schema,
                         const sourcemeta::core::JSON &instance,
                         std::string &&error) -> void {
    sourcemeta::blaze::SimpleOutput output{instance};
    const auto result{this->evaluator.validate(this->compile(cache_key, schema),
                                               instance, std::ref(output))};
    if (!result) {
      throw ValidatorError(output, std::move(error));
    }
  }

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
