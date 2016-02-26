#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo $DIR

sed -i 's#$website_root#'"$DIR"'#g' test_templates/nginx_template
