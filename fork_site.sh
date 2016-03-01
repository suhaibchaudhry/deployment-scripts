#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo -e "is this a new server? (y/n) \c"
read forkServerAnswer

case $forkServerAnswer in
  'y')
    echo -e "launching server setup...\n"
    source new_server_fork.sh
    ;;
  'n')
    echo -e "launching fork setup...\n"
    source recycled_server_fork.sh
    ;;
  *)
    echo "y for new server or n for recycled server: "
    ;;
esac
