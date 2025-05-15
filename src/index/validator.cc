#include "validator.h"

#include <functional> // std::ref
#include <sstream>    // std::ostringstream
#include <utility>    // std::move

RegistryValidatorError::RegistryValidatorError(
    const sourcemeta::blaze::SimpleOutput &output, std::string message)
    : message_{std::move(message)} {
  std::ostringstream stream;
  output.stacktrace(stream);
  this->stacktrace_ = stream.str();
}

auto RegistryValidatorError::what() const noexcept -> const char * {
  return this->message_.c_str();
}

auto RegistryValidatorError::stacktrace() const noexcept
    -> const std::string & {
  return stacktrace_;
}

RegistryValidator::RegistryValidator(
    const sourcemeta::core::SchemaResolver &resolver)
    : resolver_{resolver} {}

auto RegistryValidator::compile_once(const sourcemeta::core::JSON &schema) const
    -> sourcemeta::blaze::Template {
  return sourcemeta::blaze::compile(
      schema, this->walker_, this->resolver_, this->compiler_,
      // The point of this class is to show nice errors to the user
      sourcemeta::blaze::Mode::Exhaustive);
}

auto RegistryValidator::compile(const std::string &cache_key,
                                const sourcemeta::core::JSON &schema)
    -> const sourcemeta::blaze::Template & {
  const auto match{this->cache_.find(cache_key)};
  return match == this->cache_.cend()
             ? this->cache_.emplace(cache_key, this->compile_once(schema))
                   .first->second
             : match->second;
}

auto RegistryValidator::validate_or_throw(
    const sourcemeta::core::JSON &schema,
    const sourcemeta::core::JSON &instance, std::string &&error) -> void {
  const auto schema_template{this->compile_once(schema)};
  sourcemeta::blaze::SimpleOutput output{instance};
  const auto result{
      this->evaluator.validate(schema_template, instance, std::ref(output))};
  if (!result) {
    throw RegistryValidatorError(output, std::move(error));
  }
}

auto RegistryValidator::validate_or_throw(
    const std::string &cache_key, const sourcemeta::core::JSON &schema,
    const sourcemeta::core::JSON &instance, std::string &&error) -> void {
  sourcemeta::blaze::SimpleOutput output{instance};
  const auto result{this->evaluator.validate(this->compile(cache_key, schema),
                                             instance, std::ref(output))};
  if (!result) {
    throw RegistryValidatorError(output, std::move(error));
  }
}
