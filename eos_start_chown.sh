#!/bin/bash

chown -R daemon /var/spool/eos
find /var/log/eos -maxdepth 1 -type d -exec chown daemon {} \;
find /var/eos/ -maxdepth 1 -mindepth 1 -not -path "/var/eos/fs" -not -path "/var/eos/fusex" -type d -exec chown -R daemon {} \;
chown daemon /var/eos/auth /var/eos/stage

