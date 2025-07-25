#ifndef SOURCEMETA_BLAZE_EVALUATOR_VALUE_H
#define SOURCEMETA_BLAZE_EVALUATOR_VALUE_H

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>
#include <sourcemeta/core/regex.h>

#include <sourcemeta/blaze/evaluator_string_set.h>

#include <cstdint>       // std::uint8_t
#include <optional>      // std::optional
#include <string>        // std::string
#include <tuple>         // std::tuple
#include <unordered_set> // std::unordered_set
#include <utility>       // std::pair
#include <vector>        // std::vector

namespace sourcemeta::blaze {

/// @ingroup evaluator
/// @brief Represents a compiler step empty value
struct ValueNone {
  auto to_json() const -> sourcemeta::core::JSON {
    return sourcemeta::core::JSON{nullptr};
  }

  static auto from_json(const sourcemeta::core::JSON &)
      -> std::optional<ValueNone> {
    return ValueNone{};
  }
};

/// @ingroup evaluator
/// Represents a compiler step JSON value
using ValueJSON = sourcemeta::core::JSON;

/// @ingroup evaluator
/// Represents a set of JSON values
using ValueSet =
    std::unordered_set<sourcemeta::core::JSON,
                       sourcemeta::core::HashJSON<sourcemeta::core::JSON>>;

/// @ingroup evaluator
/// Represents a compiler step string value
using ValueString = sourcemeta::core::JSON::String;

/// @ingroup evaluator
/// Represents a compiler step object property value
using ValueProperty =
    std::pair<ValueString, sourcemeta::core::JSON::Object::hash_type>;

/// @ingroup evaluator
/// Represents a compiler step string values
using ValueStrings = std::vector<ValueString>;

/// @ingroup evaluator
/// Represents a compiler step string set of values
using ValueStringSet = StringSet;

/// @ingroup evaluator
/// Represents a compiler step JSON types value
using ValueTypes = std::vector<sourcemeta::core::JSON::Type>;

/// @ingroup evaluator
/// Represents a compiler step JSON type value
using ValueType = sourcemeta::core::JSON::Type;

/// @ingroup evaluator
/// Represents a compiler step ECMA regular expression value. We store both the
/// original string and the regular expression as standard regular expressions
/// do not keep a copy of their original value (which we need for serialization
/// purposes)
struct ValueRegex {
  using second_type = ValueString;
  using first_type = sourcemeta::core::Regex<second_type>;
  const first_type first;
  const second_type second;

  auto to_json() const -> sourcemeta::core::JSON {
    return sourcemeta::core::to_json(this->second);
  }

  static auto from_json(const sourcemeta::core::JSON &value)
      -> std::optional<ValueRegex> {
    if (!value.is_string()) {
      return std::nullopt;
    }

    auto string{value.to_string()};
    auto regex{sourcemeta::core::to_regex(string)};
    if (!regex.has_value()) {
      return std::nullopt;
    }

    return ValueRegex{std::move(regex).value(), std::move(string)};
  }
};

/// @ingroup evaluator
/// Represents a compiler step JSON unsigned integer value
using ValueUnsignedInteger = std::size_t;

/// @ingroup evaluator
/// Represents a compiler step range value. The boolean option
/// modifies whether the range is considered exhaustively or
/// if the evaluator is allowed to break early
using ValueRange = std::tuple<std::size_t, std::optional<std::size_t>, bool>;

/// @ingroup evaluator
/// Represents a compiler step boolean value
using ValueBoolean = bool;

/// @ingroup evaluator
/// Represents a compiler step string to index map
using ValueNamedIndexes = sourcemeta::core::JSONObject<
    ValueString, ValueUnsignedInteger,
    sourcemeta::core::PropertyHashJSON<ValueString>>;

/// @ingroup evaluator
/// Represents a compiler step string logical type
enum class ValueStringType : std::uint8_t { URI };

/// @ingroup evaluator
/// Represents an compiler step that maps strings to strings
using ValueStringMap = sourcemeta::core::JSONObject<
    ValueString, ValueStrings, sourcemeta::core::PropertyHashJSON<ValueString>>;

/// @ingroup evaluator
/// Represents a compiler step value that consist of object property filters
/// (strings, prefixes, regexes)
using ValuePropertyFilter =
    std::tuple<ValueStringSet, ValueStrings, std::vector<ValueRegex>>;

/// @ingroup evaluator
/// Represents a compiler step value that consists of two indexes
using ValueIndexPair = std::pair<std::size_t, std::size_t>;

/// @ingroup evaluator
/// Represents a compiler step value that consists of a pointer
using ValuePointer = sourcemeta::core::Pointer;

/// @ingroup evaluator
/// Represents a compiler step types properties value
using ValueTypedProperties = std::pair<ValueType, ValueStringSet>;

/// @ingroup evaluator
/// Represents a compiler step types property hashes value
using ValueStringHashes = std::pair<std::vector<ValueStringSet::hash_type>,
                                    std::vector<ValueIndexPair>>;

/// @ingroup evaluator
/// Represents a compiler step types property hashes value
using ValueTypedHashes = std::pair<ValueType, ValueStringHashes>;

/// @ingroup evaluator
using Value =
    std::variant<ValueNone, ValueJSON, ValueSet, ValueString, ValueProperty,
                 ValueStrings, ValueStringSet, ValueTypes, ValueType,
                 ValueRegex, ValueUnsignedInteger, ValueRange, ValueBoolean,
                 ValueNamedIndexes, ValueStringType, ValueStringMap,
                 ValuePropertyFilter, ValueIndexPair, ValuePointer,
                 ValueTypedProperties, ValueStringHashes, ValueTypedHashes>;

} // namespace sourcemeta::blaze

#endif
