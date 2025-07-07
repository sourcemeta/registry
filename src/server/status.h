#ifndef SOURCEMETA_REGISTRY_SERVER_STATUS_H
#define SOURCEMETA_REGISTRY_SERVER_STATUS_H

namespace sourcemeta::registry {

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#information_responses
const char *STATUS_CONTINUE = "100 Continue";
const char *STATUS_SWITCHING_PROTOCOLS = "101 Switching Protocols";
const char *STATUS_PROCESSING = "102 Processing";
const char *STATUS_EARLY_HINTS = "103 Early Hints";

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#successful_responses
const char *STATUS_OK = "200 OK";
const char *STATUS_CREATED = "201 Created";
const char *STATUS_ACCEPTED = "202 Accepted";
const char *STATUS_NON_AUTHORITATIVE_INFORMATION =
    "203 Non-Authoritative Information";
const char *STATUS_NO_CONTENT = "204 No Content";
const char *STATUS_RESET_CONTENT = "205 Reset Content";
const char *STATUS_PARTIAL_CONTENT = "206 Partial Content";
const char *STATUS_MULTI_STATUS = "207 Multi-Status";
const char *STATUS_ALREADY_REPORTED = "208 Already Reported";
const char *STATUS_IM_USED = "226 IM Used";

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#redirection_messages
const char *STATUS_MULTIPLE_CHOICES = "300 Multiple Choices";
const char *STATUS_MOVED_PERMANENTLY = "301 Moved Permanently";
const char *STATUS_FOUND = "302 Found";
const char *STATUS_SEE_OTHER = "303 See Other";
const char *STATUS_NOT_MODIFIED = "304 Not Modified";
const char *STATUS_USE_PROXY = "305 Use Proxy";
const char *STATUS_TEMPORARY_REDIRECT = "307 Temporary Redirect";
const char *STATUS_PERMANENT_REDIRECT = "308 Permanent Redirect";

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#client_error_responses
const char *STATUS_BAD_REQUEST = "400 Bad Request";
const char *STATUS_UNAUTHORIZED = "401 Unauthorized";
const char *STATUS_PAYMENT_REQUIRED = "402 Payment Required";
const char *STATUS_FORBIDDEN = "403 Forbidden";
const char *STATUS_NOT_FOUND = "404 Not Found";
const char *STATUS_METHOD_NOT_ALLOWED = "405 Method Not Allowed";
const char *STATUS_NOT_ACCEPTABLE = "406 Not Acceptable";
const char *STATUS_PROXY_AUTHENTICATION_REQUIRED =
    "407 Proxy Authentication Required";
const char *STATUS_REQUEST_TIMEOUT = "408 Request Timeout";
const char *STATUS_CONFLICT = "409 Conflict";
const char *STATUS_GONE = "410 Gone";
const char *STATUS_LENGTH_REQUIRED = "411 Length Required";
const char *STATUS_PRECONDITION_FAILED = "412 Precondition Failed";
const char *STATUS_PAYLOAD_TOO_LARGE = "413 Payload Too Large";
const char *STATUS_URI_TOO_LONG = "414 URI Too Long";
const char *STATUS_UNSUPPORTED_MEDIA_TYPE = "415 Unsupported Media Type";
const char *STATUS_RANGE_NOT_SATISFIABLE = "416 Range Not Satisfiable";
const char *STATUS_EXPECTATION_FAILED = "417 Expectation Failed";
const char *STATUS_IM_A_TEAPOT = "418 I'm a Teapot";
const char *STATUS_MISDIRECTED_REQUEST = "421 Misdirected Request";
const char *STATUS_UNPROCESSABLE_CONTENT = "422 Unprocessable Content";
const char *STATUS_LOCKED = "423 Locked";
const char *STATUS_FAILED_DEPENDENCY = "424 Failed Dependency";
const char *STATUS_TOO_EARLY = "425 Too Early";
const char *STATUS_UPGRADE_REQUIRED = "426 Upgrade Required";
const char *STATUS_PRECONDITION_REQUIRED = "428 Precondition Required";
const char *STATUS_TOO_MANY_REQUESTS = "429 Too Many Requests";
const char *STATUS_REQUEST_HEADER_FIELDS_TOO_LARGE =
    "431 Request Header Fields Too Large";
const char *STATUS_UNAVAILABLE_FOR_LEGAL_REASONS =
    "451 Unavailable For Legal Reasons";

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#server_error_responses
const char *STATUS_INTERNAL_SERVER_ERROR = "500 Internal Server Error";
const char *STATUS_NOT_IMPLEMENTED = "501 Not Implemented";
const char *STATUS_BAD_GATEWAY = "502 Bad Gateway";
const char *STATUS_SERVICE_UNAVAILABLE = "503 Service Unavailable";
const char *STATUS_GATEWAY_TIMEOUT = "504 Gateway Timeout";
const char *STATUS_HTTP_VERSION_NOT_SUPPORTED =
    "505 HTTP Version Not Supported";
const char *STATUS_VARIANT_ALSO_NEGOTIATES = "506 Variant Also Negotiates";
const char *STATUS_INSUFFICIENT_STORAGE = "507 Insufficient Storage";
const char *STATUS_LOOP_DETECTED = "508 Loop Detected";
const char *STATUS_NOT_EXTENDED = "510 Not Extended";
const char *STATUS_NETWORK_AUTHENTICATION_REQUIRED =
    "511 Network Authentication Required";

} // namespace sourcemeta::registry

#endif
