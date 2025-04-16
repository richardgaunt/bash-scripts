#!/bin/bash


fix_docker_permissions() {
 sudo chown $USER:docker -R .ahoy.yml ./
}
