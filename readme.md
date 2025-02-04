# port checker
a simple yet powerful tool for scheduling and logging port scans performed by nmap on specified hosts, with the ability to notify the administrator by email
## prerequisities
* `python3` - for mail notifications
* `python3 venv` package if not included in base python3 (many package managers as `apt` overrides `pip`'s abillities and does not provide all packages, like `emails`)
* `cron` (it works fine without cron, you just cannot schedule the script. tested on chimera.)
* `nmap` - for scanning
## configuration
```
git clone https://github.com/gegangene/portchecker
```
**remember, that you need to have the rwx permissions in the project directory, as well as the script itself**

* set what is needed in the `portchecker.conf` file. the config file could be a readme itself, it contains all the information needed to set up the tool properly.
* set up the email account configuration in the `mailconfig.json` file
* check that the executable files: `initialise.sh`, `combine_ports.awk`, `sender.py` and `portchecker.sh` have the permission to execute
```
./initialise.sh
```
the initialiser should set up a python virtual environment, install `emails` module with pip and set up the cron. 

it can also update the e-mail account domain if you set using your device hostname as an email domain in config file. 

the `initialise.sh` script will be invoked every time the schedule in crontable will be different than in config file (also eligible when there is no crontable - it will be invoked every time).

## operation and features
the script `portchecker.sh` is invoked by cron every interval defined in the `rescan_every` value in the configuration file. if you don't use cron, the interval at which a script runs is up to you.

you can specify the `host`, the list of `ports` you want to scan and the `state` of the ports to focus on. the scan results will be stored in the `results_path`/`host` directory which you can also define (by default it is set as the project directory).

> [!IMPORTANT]
> the script needs to have permissions to read and write in the `results_path` directory.

the scan results are named according to the convention `unixstamp_on_start_of_scan.pclog`.

you can use the value of `notify_on_change_last` to specify whether you want to be notified only if there has been a change since the last scan, or every time.

> [!IMPORTANT]
> when comparison is enabled, the scan results file will have an extra line to indicate changes within ports, e.g. `o|f80` if port 80 has changed from open to filtered. this can be useful for administrators to effectively track port changes while keeping the mailbox clean.

the script also has the ability to find the same port state changes in previous records and store the previous state change unixstamp with the results. this can be useful for troubleshooting and pattern detection

to set this feature up, you need to enable `notify_on_change_comparison` and specify the range of files you want to search in (in seconds) in the value of `compare_age`.

> [!IMPORTANT]
> historical port state change detection requires file comparison to be enabled in order to work. when enabled, the scan results file will have an extra line to store the last unixstamps when such a change occurred.
