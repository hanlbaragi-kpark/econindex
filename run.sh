#!/bin/bash

command=$1

if [[ ! -z $command ]]; then
    case $command in
    build)
        docker-compose build --force-rm --build-arg USER_ID=$(id -u) --build-arg USER_NAME=$(id -un) web
        ;;
    start)
        docker-compose up -d
        ;;
    stop)
        docker-compose down
        ;;
    shell)
        docker-compose exec -u $(id -u):$(id -g) web /bin/bash
        ;;
    shell-root)
        docker-compose exec web /bin/bash
        ;;
    esac
else
    echo "Usage: $0 {start <workspace name> | stop | shell}"
    echo "   build        build services"
    echo "   start        start services"
    echo "   stop         stop services"
    echo "   shell        execute shell"
    echo "   shell-root   execute root shell"
fi
