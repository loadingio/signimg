#!/usr/bin/env bash
mkdir -p key
openssl genrsa -out key/pvk.pem 2048
openssl rsa -in key/pvk.pem -pubout -out key/pbk.pem
