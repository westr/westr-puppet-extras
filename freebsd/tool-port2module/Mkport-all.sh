#!/bin/sh

# Wrapper for all ports

# cmd: pkg_info -Qo *
# 
# output example:
# pth-2.0.7:devel/pth
# puppet-0.25.4:sysutils/puppet
# pure-ftpd-1.0.21_2:ftp/pure-ftpd
# py25-MySQLdb-1.2.2:databases/py-MySQLdb
# python-2.5,2:lang/python
# python25-2.5.4_1:lang/python25
# rancid-2.3.1_3:net-mgmt/rancid
# razor-agents-2.84:mail/razor-agents
# rbldnsd-0.996a:dns/rbldnsd
# re2c-0.13.5:devel/re2c
# rpm-3.0.6_14:archivers/rpm
# rsync-3.0.5:net/rsync
# ruby-1.8.6.287,1:lang/ruby18
# ruby18-bdb-0.6.4:databases/ruby-bdb

OUTPUT=`pkg_info -Qo '*' | sed -n -E 's/^([a-z0-9-]+)-([0-9._,]+)\:(.*)$/\1 \3/Ip'`

IFS='
'  # Stupid newline include

for LINE in $OUTPUT
do
	echo "Line = ($LINE)"
	CMD="./Mkport.sh $LINE"
	eval $CMD
done





