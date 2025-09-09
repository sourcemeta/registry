#include <sourcemeta/registry/shared_license.h>

#include <cstdlib> // std::getenv

namespace sourcemeta::registry {

#ifdef SOURCEMETA_REGISTRY_STARTER
auto license_permitted() -> bool { return true; }
#else
auto license_permitted() -> bool {
  // TODO: Investigate this warning
  const char *check{
      // NOLINTNEXTLINE(concurrency-mt-unsafe)
      std::getenv("SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE")};
  return check != nullptr && check[0] != '\0';
}
#endif

constexpr std::string_view LICENSE_ERROR{R"EOF(
╔════════════════════════════════════════════════════════════════════╗
║                     CONFIRM COMMERCIAL LICENSE                     ║
╠════════════════════════════════════════════════════════════════════╣
║ You are running a commercial version of the Sourcemeta Registry.   ║
║ This software requires a valid commercial license to operate.      ║
║                                                                    ║
║ To confirm your license, set the following environment variable:   ║
║   SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE                  ║
║                                                                    ║
║ By setting this variable, you agree to the terms of the license    ║
║ at: https://github.com/sourcemeta/registry                         ║
║                                                                    ║
║ Running this software without a commercial license is strictly     ║
║ prohibited and may result in legal action.                         ║
╚════════════════════════════════════════════════════════════════════╝
)EOF"};

auto license_error() -> std::string_view { return LICENSE_ERROR; }

} // namespace sourcemeta::registry
