#!/usr/bin/env bash

cp -r /home/deploy/code-test/docroot/blogmate /var/www/html
cd /var/www/html/blogmate
composer install
