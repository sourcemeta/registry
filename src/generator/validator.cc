#include <sourcemeta/registry/generator_validator.h>

#include <functional> // std::ref
#include <sstream>    // std::ostringstream
#include <utility>    // std::move

namespace sourcemeta::registry {

ValidatorError::ValidatorError(const sourcemeta::blaze::SimpleOutput &output,
                               std::string message)
    : message_{std::move(message)} {
  std::ostringstream stream;
  output.stacktrace(stream);
  this->stacktrace_ = stream.str();
}

auto ValidatorError::what() const noexcept -> const char * {
  return this->message_.c_str();
}

auto ValidatorError::stacktrace() const noexcept -> const std::string & {
  return stacktrace_;
}

Validator::Validator(const sourcemeta::core::SchemaResolver &resolver)
    : resolver_{resolver} {}

auto Validator::compile_once(const sourcemeta::core::JSON &schema) const
    -> sourcemeta::blaze::Template {
  return sourcemeta::blaze::compile(
      schema, this->walker_, this->resolver_, this->compiler_,
      // The point of this class is to show nice errors to the user
      sourcemeta::blaze::Mode::Exhaustive);
}

auto Validator::compile(const std::string &cache_key,
                        const sourcemeta::core::JSON &schema)
    -> const sourcemeta::blaze::Template & {
  const auto match{this->cache_.find(cache_key)};
  return match == this->cache_.cend()
             ? this->cache_.emplace(cache_key, this->compile_once(schema))
                   .first->second
             : match->second;
}

auto Validator::validate_or_throw(const sourcemeta::core::JSON &schema,
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

auto Validator::validate_or_throw(const std::string &cache_key,
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

} // namespace sourcemeta::registry
