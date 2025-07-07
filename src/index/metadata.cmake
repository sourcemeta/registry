file(MD5 "${INPUT}" MD5_HASH)

get_filename_component(INPUT_EXTENSION "${INPUT}" EXT)
string(TOLOWER "${INPUT_EXTENSION}" INPUT_EXTENSION)

if(INPUT_EXTENSION STREQUAL ".png")
  set(MIME "image/png")
elseif(INPUT_EXTENSION STREQUAL ".svg")
  set(MIME "image/svg+xml")
elseif(INPUT_EXTENSION STREQUAL ".min.css")
  set(MIME "text/css")
elseif(INPUT_EXTENSION STREQUAL ".js")
  set(MIME "text/javascript")
elseif(INPUT_EXTENSION STREQUAL ".ico")
  set(MIME "image/vnd.microsoft.icon")
elseif(INPUT_EXTENSION STREQUAL ".webmanifest")
  set(MIME "application/manifest+json")
elseif(INPUT_EXTENSION STREQUAL ".woff")
  set(MIME "font/woff")
elseif(INPUT_EXTENSION STREQUAL ".woff2")
  set(MIME "font/woff2")
else()
  message(FATAL_ERROR "Cannot determine MIME type for ${INPUT}")
endif()

execute_process(
  COMMAND date -u -r "${INPUT}" "+%a, %d %b %Y %H:%M:%S GMT"
  OUTPUT_VARIABLE LAST_MODIFIED
  OUTPUT_STRIP_TRAILING_WHITESPACE)

set(JSON_CONTENT "{ \"md5\": \"${MD5_HASH}\", \"mime\": \"${MIME}\", \"lastModified\": \"${LAST_MODIFIED}\" }")
file(WRITE "${OUTPUT}" "${JSON_CONTENT}\n")
