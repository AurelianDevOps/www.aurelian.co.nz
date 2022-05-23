#!/bin/sh
rm -r public/*
hugo
scp -r public www.aurelian.co.nz:
ssh www.aurelian.co.nz 'doas rm -r /var/www/htdocs/www.aurelian.co.nz'
ssh www.aurelian.co.nz 'doas cp -r /home/leon/public /var/www/htdocs/www.aurelian.co.nz'
ssh www.aurelian.co.nz 'rm -r ~/public'
