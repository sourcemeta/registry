#!/bin/sh

set -o errexit
set -o nounset

name="$1"
shift
start_time="$(date +%s)"
"$@" >&2
end_time="$(date +%s)"
duration="$((end_time - start_time))"

printf '[\n'
printf '    {\n'
printf '        "name": "%s",\n' "$name"
printf '        "unit": "Seconds",\n'
printf '        "value": %s\n' "$duration"
printf '    }\n'
printf ']\n'
