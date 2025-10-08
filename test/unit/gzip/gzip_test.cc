#include <gtest/gtest.h>

#include <sourcemeta/registry/gzip.h>

#include <sstream>

TEST(GZIP, compress_stream_1) {
  const auto value{"Hello World"};
  std::istringstream input{value};
  std::ostringstream output;
  sourcemeta::registry::gzip(input, output);
  EXPECT_EQ(output.str().size(), 31);
}

TEST(GZIP, compress_stream_to_string_1) {
  const auto value{"Hello World"};
  std::istringstream input{value};
  const auto result{sourcemeta::registry::gzip(input)};
  EXPECT_EQ(result.size(), 31);
}

TEST(GZIP, compress_string_to_string_1) {
  const auto result{sourcemeta::registry::gzip("Hello World")};
  EXPECT_EQ(result.size(), 31);
}

TEST(GZIP, decompress_stream_1) {
  const auto value{"Hello World"};
  std::istringstream input{sourcemeta::registry::gzip(value)};
  std::ostringstream output;
  sourcemeta::registry::gunzip(input, output);
  EXPECT_EQ(output.str(), value);
}

TEST(GZIP, decompress_stream_error_1) {
  std::istringstream input{"not-zlib-content"};
  std::ostringstream output;
  EXPECT_THROW(sourcemeta::registry::gunzip(input, output),
               sourcemeta::registry::GZIPError);
}

TEST(GZIP, decompress_stream_to_string_1) {
  const auto value{"Hello World"};
  std::istringstream input{sourcemeta::registry::gzip(value)};
  const auto result{sourcemeta::registry::gunzip(input)};
  EXPECT_EQ(result, value);
}

TEST(GZIP, decompress_string_to_string_1) {
  const auto value{"Hello World"};
  const auto result{
      sourcemeta::registry::gunzip(sourcemeta::registry::gzip(value))};
  EXPECT_EQ(result, value);
}
