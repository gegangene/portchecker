#!/bin/bash

export scriptPath=$( pwd )
# getting values from config file
hostToCheck=$( grep "^host:" portchecker.conf | awk '{ print $2 }' )
ports=$( grep "^ports:" portchecker.conf | awk '{ print $2 }' )
resultsPath=$( grep "^results_path:" portchecker.conf | awk '{ print $2 }' )
compareAge=$( grep "^compare_age:" portchecker.conf | awk '{ print $2 }' )
rescanEvery=$( grep "^rescan_every:" portchecker.conf | awk '{ print $2" "$3" "$4" "$5" "$6 }' )
notifyAbout=$( grep "^notify_about:" portchecker.conf | awk '{ print $2 }' )
notifyOnChangeLast=$( grep "^notify_on_change_last:" portchecker.conf | awk '{ print $2 }' )
notifyOnChangeComparison=$( grep "^notify_on_change_comparison:" portchecker.conf | awk '{ print $2 }' )

# checking whether cron has up-to-date settings
checkCrontab=$( crontab -l | grep "$scriptPath/portchecker.sh" | awk '{ print $1" "$2" "$3" "$4" "$5 }')
test "$rescanEvery" != "$checkCrontab" && crontab -l | grep -v "$scriptPath/portchecker.sh" | crontab - && ./initialise.sh

# to avoid regex errors
test "$notifyAbout" = "*" && notifyAbout=""

# activation of python environment
source pyvenv/bin/activate

# getting current timestamp
unixstamp=$( date +%s )

# testing whether host directory exists. if not - creating it
test $( find . -maxdepth 1 -name $hostToCheck -type d | wc -w ) -eq 0 && mkdir $hostToCheck

# getting name of last log file before scanning and creating new one if the comparison with prevoius logfile is set to on
test $notifyOnChangeLast -eq 1 && lastResult=$( find $resultsPath/$hostToCheck -name "[0-9]*.pclog" | tail -n 1 )

# scanning + saving results in format portnumber/tcp\tstate\tservice_name
nmap -sV -p $ports $hostToCheck | grep "^[0-9]" | grep "$notifyAbout" | awk '{ print $1 "\t" $2 "\t" $3 }' > "$resultsPath"/$hostToCheck/$unixstamp.pclog

toSend=1

# comparison with previous file if set so. saving changes in format [previous_state]|[current_state][port_number] in extra line.
if test $notifyOnChangeLast -eq 1; test "$lastResult" != ""; then
	currentResult="$resultsPath/$hostToCheck/$unixstamp.pclog"
	
	if test "$lastResult" = "$( ls $lastResult )" && test "$( grep "/" $currentResult )" = "$( grep "/" $lastResult )"; then
		toSend=0
	else
		openThen=$( cat $lastResult | grep -v "$( cat $currentResult )" | grep "open" | cut -d/ -f1 | awk '{print "o" $1}' | column -x )
		closedThen= $( cat $lastResult | grep -v "$( cat $currentResult )" | grep "closed" | cut -d/ -f1 | awk '{print "c" $1}' | column -x )
		filteredThen=$( cat $lastResult | grep -v "$( cat $currentResult )" | grep "filtered" | cut -d/ -f1 | awk '{print "f" $1}' | column -x )
		openNow=$( cat $currentResult | grep -v "$( cat $lastResult )" | grep "open" | cut -d/ -f1 | awk '{print "o" $1}' | column -x )
		closedNow=$( cat $currentResult | grep -v "$( cat $lastResult )" | grep "closed" | cut -d/ -f1 | awk '{print "c" $1}' | column -x )
		filteredNow=$( cat $currentResult | grep -v "$( cat $lastResult )" | grep "filtered" | cut -d/ -f1 | awk '{print "f" $1}' | column -x )
		diff="$openThen $closedThen $filteredThen $openNow $closedNow $filteredNow"
		echo "$diff" | ./combine_ports.awk >> "$resultsPath"/$hostToCheck/$unixstamp.pclog
	fi
fi

# searching for the most recent of old scans when such a change occured (if set so). saving timestamps of last changes in extra line
if test $notifyOnChangeLast -eq 1 && test $notifyOnChangeComparison -eq 1; then
	unixstampSecAgo=$(( $unixstamp-1 ))
	oldUnixstamp=$(( $unixstamp-$compareAge ))
	changes=($( grep "|" "$resultsPath"/$hostToCheck/$unixstamp.pclog ))
	changesUnixstamps=""
	for port in "${changes[@]}"; do
		portChange=""
		for (( file=unixstampSecAgo; file>=oldUnixstamp; file-- )); do
			fileWlog="$file.pclog"
			if [[ -e "$resultsPath/$hostToCheck/$fileWlog" ]]; then
#				echo "zyje"
				if fgrep -q "$port" "$resultsPath/$hostToCheck/$fileWlog"; then
					portChange="${file}"
					changesUnixstamps="${changesUnixstamps}${file} "
					break
				fi
#			else
#				echo "umarl"
			fi
		done
		test "$portChange" = "" && changesUnixstamps="${changesUnixstamps}n/a "
	done
	echo $changesUnixstamps >> "$resultsPath"/$hostToCheck/$unixstamp.pclog
fi

# if eligible - sending notification for administrator
test $toSend -eq 1 && ./sender.py "$resultsPath"/$hostToCheck/$unixstamp.pclog 

#exiting python environment
deactivate
