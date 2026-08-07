#!/bin/bash

# ===========================================
# AWS Cloud & DevOps Portfolio
# Lab 07 - Amazon RDS
#
# Author : Henry Huamani
# Purpose: Connect securely to Amazon RDS
# ===========================================

set -e

RDS_ENDPOINT="portfolio-db.xxxxxxxxx.us-east-2.rds.amazonaws.com"
DB_PORT="3306"
DB_USER="admin"

# Download the latest Amazon RDS CA bundle if it doesn't exist
if [ ! -f "$HOME/global-bundle.pem" ]; then
    curl -o "$HOME/global-bundle.pem" \
    https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
fi

mysql \
-h ${RDS_ENDPOINT} \
-P ${DB_PORT} \
-u ${DB_USER} \
-p \
--ssl-ca="$HOME/global-bundle.pem" \
--ssl-verify-server-cert