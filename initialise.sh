#!/bin/bash

test $( find . -maxdepth 1 -name pyvenv -type d | wc -w ) -eq 0 && mkdir pyvenv && python3 -m venv pyvenv
test $( find . -maxdepth 6 -name emails -type d | wc -w ) -eq 0 && source pyvenv/bin/activate && pip3 install emails && deactivate

test "$( grep "^use_hostname_as_domain:" portchecker.conf | awk '{ print $2 }' )" = "1" && sed --version >/dev/null 2>&1 && sed -i "s/\"sender_domain\": \".*\"/\"sender_domain\": \"$(hostname -f)\"/" mailconfig.json || sed -i '' "s/\"sender_domain\": \".*\"/\"sender_domain\": \"$(hostname -f)\"/" mailconfig.json

export scriptPath=$( pwd )

crontab -l > crontab.copy
if [ ` grep -c "$scriptPath/portchecker.sh" crontab.copy ` -gt 0 ]; then
	exit
fi
grep "^rescan_every:" portchecker.conf | awk '{ print $2 " " $3 " " $4 " " $5 " " $6 " cd " ENVIRON["scriptPath"] " && " ENVIRON["scriptPath"] "/portchecker.sh" }' >> crontab.copy
crontab crontab.copy
