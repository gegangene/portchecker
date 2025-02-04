# port checker
a simple yet powerful tool for scheduling and logging port scans done by nmap on given hosts with ability to notify administrator by e-mail
## prerequisities
* `python3` - for mail notifications
* `python3 venv` package if not included in base python3 (many package managers as apt overrides pip abillities and not provides all packages, like `emails`)
* `cron` (it works great without cron, you just cannot schedule. tested on chimera.)
* `nmap` - for scanning
## configuration
```
git clone https://github.com/gegangene/portchecker
```
**remember, that you need to have the rwx permissions in the project directory, as the script itself**

* set what is needed in `portchecker.conf` file. the config file could be a readme itself, it contains any information needed to set up tool properly.
* set e-mail account configuration in `mailconfig.json` file
* check whether the executable files: `initialise.sh`, `combine_ports.awk`, `sender.py` and `portchecker.sh` have the permission to execute
```
./initialise.sh
```
the initialiser should set up a python virtual environment, install `emails` module with pip and set up the cron. it can also update the e-mail account domain if you set using your device hostname as a domain in config file. the script is invoken every time the schedule in crontable will be different than in config file (also eligible when there is no crontable - it will be invoken every time).

