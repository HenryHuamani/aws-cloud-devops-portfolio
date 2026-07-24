#!/bin/bash

# ====================================================
# AWS Cloud & DevOps Portfolio
# Lab 05 - Application Load Balancer
#
# Author : Henry Huamani
# Purpose: Configure Apache Web Server automatically
# ====================================================

# ----------------------------
# VARIABLES
# ----------------------------

SERVER_NAME="Server 01"
AVAILABILITY_ZONE="us-east-2a"

# ----------------------------
# UPDATE OS
# ----------------------------

dnf update -y

# ----------------------------
# INSTALL APACHE
# ----------------------------

dnf install httpd -y

systemctl enable httpd
systemctl start httpd

# ----------------------------
# CREATE WEB PAGE
# ----------------------------

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>AWS Cloud Portfolio</title>

<style>

body{
    background:#253142;
    color:white;
    font-family:Arial,Helvetica,sans-serif;
    text-align:center;
    padding-top:80px;
}

.card{
    width:700px;
    margin:auto;
    background:#3c4d63;
    padding:40px;
    border-radius:18px;
}

h1{
    color:#ff9900;
}

</style>

</head>

<body>

<div class="card">

<h1>AWS Cloud Portfolio</h1>

<h2>Application Load Balancer Lab</h2>

<h2>${SERVER_NAME}</h2>

<h3>Hostname: $(hostname)</h3>

<h3>Availability Zone: ${AVAILABILITY_ZONE}</h3>

</div>

</body>

</html>

EOF

# ----------------------------
# RESTART APACHE
# ----------------------------

systemctl restart httpd