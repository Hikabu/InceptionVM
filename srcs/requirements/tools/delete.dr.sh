#!/bin/bash

set -a
source .env
set +a

delete_directory() {
    if [ -d "$1" ]; then
        sudo rm -rf "$1"
        echo "Deleted directory: $1"
    fi
}

delete_directory "$wordpress_dir"
delete_directory "$mariadb_dir"
delete_directory "$portainer_dir"