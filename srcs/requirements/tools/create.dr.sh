#!/bin/bash

set -a
source .env
set +a

create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Directory created successfully: $1"
    fi
}

create_directory "$wordpress_dir"
create_directory "$mariadb_dir"
create_directory "$portainer_dir"