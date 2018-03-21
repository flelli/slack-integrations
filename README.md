# Summary
Here are some scripts and utilities I'm using to integrate [Slack](https://slack.com/) with other apps and services. They don't use Perl. Instead, they're simple *bash* script that only require [curl](https://curl.haxx.se/) to be installed.

These scripts have been tested with [Nagios](https://www.nagios.org/) and [Zabbix](https://www.zabbix.com/).

## Slack alert notification scripts
* `slack-nagios-alert.sh` is the script specifically tailored for [Nagios](https://www.nagios.org/) that sends alerts to [Slack](https://slack.com/)
* `slack-zabbix-alert.sh`, on the other hand, is suited for [Zabbix](https://www.zabbix.com/)

These scripts send meaningful and well formatted notifications to Slack, using different colors to give a quick idea of the severity. Moreover, back links are provided so that you just need to click on them to open the issue specific page of the monitoring platform.

To set up notifications for Nagios please refer to [NAGIOS.md](NAGIOS.md) while for Zabbix use [ZABBIX.md](ZABBIX.md).
