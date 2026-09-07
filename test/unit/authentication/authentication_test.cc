#include <sourcemeta/core/test.h>
#include <sourcemeta/one/authentication.h>

#include <array>       // std::array
#include <cstddef>     // std::size_t
#include <filesystem>  // std::filesystem::path
#include <span>        // std::span
#include <string>      // std::string
#include <string_view> // std::string_view
#include <vector>      // std::vector

// Every gate question is asked about a canonical location, so the tests name
// one the same way a request would
static auto at(const std::string_view input)
    -> sourcemeta::one::Authentication::Path {
  return sourcemeta::one::Authentication::Path::parse(input,
                                                      "http://localhost:8000")
      .value();
}

// These tests name locations directly rather than modelling what an instance
// serves, so every path a policy is scoped to is one to gate
static auto anywhere(const std::string_view) -> bool { return true; }

// The artifact is compiled and then persisted, which the tests below do
// together because they read it back through a file
static auto
save(const std::span<const sourcemeta::one::Authentication::Policy> policies,
     const std::filesystem::path &configuration,
     const std::filesystem::path &destination,
     const sourcemeta::one::Authentication::PathGuard &gateable) -> void {
  sourcemeta::one::Authentication::Table::write(
      sourcemeta::one::Authentication::Table::compile(policies, configuration,
                                                      gateable),
      destination);
}

// The names a table serves, which is what the naming rule below decides. What
// each name stands for is read from what its view reaches rather than from the
// set behind it, since that set is the artifact's own business
static auto view_names(const sourcemeta::one::Authentication::Table &table)
    -> std::vector<std::string_view> {
  std::vector<std::string_view> result;
  for (const auto &view : table.views()) {
    result.push_back(view.name());
  }

  return result;
}

static auto test_path(const std::string &name) -> std::filesystem::path {
  return std::filesystem::path{AUTHENTICATION_TEST_DIRECTORY} / name;
}

TEST(admits_every_path_without_a_credential) {
  const sourcemeta::one::Authentication authentication{
      sourcemeta::one::Authentication::Table{
          std::filesystem::path{"/no/such/authentication.bin"}},
      {}};
  EXPECT_TRUE(
      authentication.permits(at("/"), authentication.caller({.bearer = ""})));
  EXPECT_TRUE(
      authentication.permits(at(""), authentication.caller({.bearer = ""})));
  EXPECT_TRUE(authentication.permits(at("/acme/foo/bar"),
                                     authentication.caller({.bearer = ""})));
}

TEST(admits_every_path_with_any_credential) {
  const sourcemeta::one::Authentication authentication{
      sourcemeta::one::Authentication::Table{
          std::filesystem::path{"/no/such/authentication.bin"}},
      {}};
  EXPECT_TRUE(authentication.permits(
      at("/internal"), authentication.caller({.bearer = "anything"})));
  EXPECT_TRUE(authentication.permits(
      at("/internal/foo"), authentication.caller({.bearer = "another"})));
}

TEST(save_emits_an_empty_artifact_that_admits_everything) {
  const auto path{test_path("community_public_root.bin")};
  save({}, path, path, anywhere);

  EXPECT_TRUE(std::filesystem::exists(path));
  EXPECT_EQ(std::filesystem::file_size(path), 0);

  const sourcemeta::one::Authentication authentication{
      sourcemeta::one::Authentication::Table{path}, {}};
  EXPECT_TRUE(
      authentication.permits(at("/"), authentication.caller({.bearer = ""})));
  EXPECT_TRUE(authentication.permits(at("/internal/foo"),
                                     authentication.caller({.bearer = ""})));
}

TEST(save_creates_the_directory_it_writes_into) {
  const auto path{test_path("nested") / "deeper" / "authentication.bin"};
  std::filesystem::remove_all(test_path("nested"));
  save({}, path, path, anywhere);

  EXPECT_TRUE(std::filesystem::exists(path));
  EXPECT_EQ(std::filesystem::file_size(path), 0);
}

TEST(save_rejects_any_policy) {
  const std::array<std::string_view, 1> paths{{"/internal"}};
  const std::array<sourcemeta::one::Authentication::Policy, 1> policies{
      {{.paths = paths}}};
  const auto path{test_path("community_policy.bin")};
  try {
    save(policies, path, path, anywhere);
    FAIL();
  } catch (const sourcemeta::one::EnterpriseOnlyFeatureError &error) {
    EXPECT_STREQ(error.what(),
                 "Authentication is only available on the enterprise edition");
  }
}

TEST(permits_every_reference) {
  const sourcemeta::one::Authentication::Table gate{
      std::filesystem::path{"/no/such/authentication.bin"}};
  EXPECT_TRUE(gate.reference_permitted(at("/one"), at("/two")));
  EXPECT_TRUE(gate.reference_permitted(at("/public/one"), at("/private/two")));
  EXPECT_TRUE(gate.reference_permitted(at("/internal/a"), at("/internal/a")));
}

TEST(records_the_anonymous_view_alone) {
  const sourcemeta::one::Authentication::Table gate{
      std::filesystem::path{"/no/such/authentication.bin"}};
  const auto table{gate.views()};
  EXPECT_EQ(table.size(), std::size_t{1});
  EXPECT_EQ(table.at(0).name(), "public");
  // And it holds nothing, which is what it reaching every location shows
  EXPECT_TRUE(gate.visible(at("/internal/foo"), table.at(0)));
}

TEST(shows_every_path_in_its_only_view) {
  const sourcemeta::one::Authentication::Table gate{
      std::filesystem::path{"/no/such/authentication.bin"}};
  const auto anonymous{gate.view("public")};
  EXPECT_TRUE(gate.visible(at("/"), anonymous));
  EXPECT_TRUE(gate.visible(at(""), anonymous));
  EXPECT_TRUE(gate.visible(at("/internal/foo"), anonymous));
}

TEST(serves_a_name_no_view_holds_as_the_anonymous_one) {
  const sourcemeta::one::Authentication::Table gate{
      std::filesystem::path{"/no/such/authentication.bin"}};
  const auto withdrawn{gate.view("retired")};
  EXPECT_EQ(withdrawn.name(), "public");
  // Nothing is governed here, so the one view shows every location whichever
  // name it was asked for
  EXPECT_TRUE(gate.visible(at("/"), withdrawn));
  EXPECT_TRUE(gate.visible(at("/internal/foo"), withdrawn));
}

TEST(serves_every_caller_the_anonymous_view) {
  const std::array<std::string_view, 1> cookies{
      {"sourcemeta_one_session=whatever"}};
  const sourcemeta::one::Authentication authentication{
      sourcemeta::one::Authentication::Table{
          std::filesystem::path{"/no/such/authentication.bin"}},
      {}};
  EXPECT_EQ(authentication.caller({.bearer = ""}).view(), "public");
  EXPECT_EQ(authentication.caller({.bearer = "anything"}).view(), "public");
  EXPECT_EQ(authentication.caller({.bearer = "", .cookies = cookies}).view(),
            "public");
}

// Nothing is governed here, so a caller presenting anything at all reaches
// everywhere, which is the same answer they get for presenting nothing
TEST(admits_a_caller_presenting_nothing_everywhere) {
  const sourcemeta::one::Authentication authentication{
      sourcemeta::one::Authentication::Table{
          std::filesystem::path{"/no/such/authentication.bin"}},
      {}};
  EXPECT_TRUE(authentication.permits(at("/"), authentication.caller({})));
  EXPECT_TRUE(
      authentication.permits(at("/internal/foo"), authentication.caller({})));
}

TEST(admits_a_caller_presenting_a_credential_everywhere) {
  const std::array<std::string_view, 1> cookies{
      {"sourcemeta_one_session=whatever"}};
  const sourcemeta::one::Authentication authentication{
      sourcemeta::one::Authentication::Table{
          std::filesystem::path{"/no/such/authentication.bin"}},
      {}};
  EXPECT_TRUE(authentication.permits(
      at("/internal/foo"), authentication.caller({.bearer = "anything"})));
  EXPECT_TRUE(authentication.permits(
      at("/internal/foo"),
      authentication.caller({.bearer = "", .cookies = cookies})));
  EXPECT_TRUE(authentication.permits(
      at("/internal/foo"),
      authentication.caller({.bearer = "another", .cookies = cookies})));
}

TEST(views_of_nothing_are_the_public_one_alone) {
  const auto path{test_path("views_of_nothing_are_the_public_one_alone.bin")};
  save(std::span<const sourcemeta::one::Authentication::Policy>{}, path, path,
       anywhere);
  const sourcemeta::one::Authentication::Table gate{path};
  EXPECT_EQ(view_names(gate), (std::vector<std::string_view>{"public"}));
}
