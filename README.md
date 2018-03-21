# Summary
Here are some scripts and utilities I'm using to integrate [Slack](https://slack.com/) with other apps and services. They don't use Perl. Instead, they're simple *bash* script that only require [curl](https://curl.haxx.se/) to be installed.
Use them freely.

These scripts have been tested with:
* [Nagios](https://www.nagios.org/)
* [Zabbix](https://www.zabbix.com/)

Below you can find instructions on how to set them up along with some examples.

## Slack alert notification scripts
* `slack-nagios-alert.sh` is the script specifically tailored for [Nagios](https://www.nagios.org/) that sends alerts to [Slack](https://slack.com/)
* `slack-zabbix-alert.sh`, on the other hand, is suited for [Zabbix](https://www.zabbix.com/)

As you can see from the example screenshots below, these scripts send meaningful and well formatted notifications to Slack, using different colors to give a quick idea of the severity. Moreover, back links are provided so that you just need to click on them to open the issue specific page of the monitoring platform.

### Nagios notification script synopsys
Usage: `slack-nagios-alert.sh [OPTIONS]`
* `-U <SLACK WEBHOOK URL>`: the URL of the Slack webkhook. See below on how to get one
* `-t <SLACK TEAM>`: the slack team name. This is the first part of the Slack URL you use (i.e. if your Slack is at `myrockingteam.slack.com` then the team name to use here is `myrockingteam`)
* `-c <SLACK CHANNEL>`: the Slack channel name (without the leading '#', e.e. \"monitoring\" for using the \"#monitoring\" channel). This may be ignored if the Slack webhook is configured for a fixed channel.
* `-u <SLACK USER>`: the user to display as the message sender on Slack (i.e. \"nagios\"). This may be ignored if the Slack webhook is configured for a fixed user.
* `-W <NAGIOS TYPE>`: set it to `HOST` if it's an host notification or `SERVICE` if it's a service notification
* `-Y <NAGIOS NOTIFICATION TYPE>`: the notification type (i.e. `PROBLEM`) coming from Nagios
* `-H <NAGIOS HOST NAME>`: the host name coming from Nagios (i.e. `nagios.example.com`)
* `-A <NAGIOS HOST IP ADDRESS>`: this is the host IP address coming from Nagios
* `-S <NAGIOS SERVICE NAME>`: the service name the notification is about
* `-X <NAGIOS STATE>`: the Nagios issue severity and can be `CRITICAL`, `WARNING`, `OK`. This will also determine the colors used in the Slack message
* `-M <NAGIOS OUTPUT>`: the service or host output message coming Nagios (i.e. an error message)
* `-T <NAGIOS TIMESTAMP>`: the message timestamp coming from Nagios
* `-Q <NAGIOS SERVER BASE URL>`: the base URL of the Nagios server. This is used to build URLs in the notification message that can be clicked to access the Nagios page for the problem. This DNS name may be a private name, in this case just remember that the back link will work only when connected to the private network that resolves that DNS name

Examples are provided below along with the resulting screenshots.

# Set up
## Set up the Slack Webhook
In order to receive notifications you need an active Slack team and know which channel you will send the notifications to. You may wish to set up a new channel for notifications.
For general instructions about Slack incoming webhooks just jump to [this page](https://api.slack.com/incoming-webhooks).

Then you're ready to set up your webhook by following these simple steps:
1. open the [Incoming Webhook](https://my.slack.com/services/new/incoming-webhook/) custom integration page for your team
2. in the *Post to Channel* box select the default channel you want notifications to be sent to (or create a new channel in place). You will be able to override the target channel when using the script to send notifications
3. in the next page take note of the **Webhook URL** that was generated and optionally set other fields like the webhook label, name, icon etc. The URL looks like `https://hooks.slack.com/services/ABCDEFGHI/FGHIJKLMN/123abc456def789ldt645Bgs`. In the **Customize Name** field you can set the username you want notifications to appear from. For example you may set `nagios` or `zabbix`

Now you're ready to go on the Slack side and you can start sending notifications.

## Set up Slack alert notifications for Nagios
Before you go any further you can test the script by sending manual notifications and simulate alerts. Example command lines are povided below along with the example screenshots.

## Nagios settings

### Copy the script in the Nagios folder
You first have to copy the `/slack-nagios-alert.sh` script in the Nagios plugins directory, usually `/usr/local/nagios/libexec/`. Also make sure that the Nagios user has execution rights on the script.

### Define the notification commands in Nagios configuration
In the commands configuration file (usually `objects/commands.cfg`) add the Slack notification command. We need two commands, one for service notifications and one for hosts. Full descriptions is available in the [official Nagios docs](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/4/en/objectdefinitions.html#command). What follows is an example:
```
# The commands used for Slack channel notifications. They use custom address fields (addressX) to define Slack specific parameters
define command {
   command_name     service-notify-by-slack
   command_line     /usr/local/nagios/libexec/slack-nagios-alert.sh -U '$CONTACTADDRESS3$' -Q 'http://nagios.example.com/nagios' -t '$CONTACTADDRESS1$' -c '$CONTACTADDRESS2$' -u nagios -W SERVICE -Y '$NOTIFICATIONTYPE$' -S '$SERVICEDESC$' -H '$HOSTNAME$' -A '$HOSTADDRESS$' -X '$SERVICESTATE$' -M '$SERVICEOUTPUT$' -T '$LONGDATETIME$'
}

define command {
      command_name     host-notify-by-slack
      command_line     /usr/local/nagios/libexec/slack-nagios-alert.sh -U '$CONTACTADDRESS3$' -Q 'http://nagios.example.com/nagios' -t '$CONTACTADDRESS1$' -c '$CONTACTADDRESS2$' -u nagios -W HOST -Y '$NOTIFICATIONTYPE$' -H '$HOSTNAME$' -A '$HOSTADDRESS$' -X '$SERVICESTATE$' -M '$SERVICEOUTPUT$' -T '$LONGDATETIME$'
}
```

### Define the contact in Nagios configuration
In the contacts configuration file (usually `objects/contacts.cfg`) add the Slack notification contact. Full descriptions is available in the [official Nagios docs](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/4/en/objectdefinitions.html#contact). What follows is an example:
```
define contact{
   contact_name                    slack
   alias                           Slack
   
   service_notification_commands   service-notify-by-slack
   host_notification_commands      host-notify-by-slack

   address1                        SLACK_TEAM              ; set the name of the Slack team
   address2                        SLACK_CHANNEL           ; set the name of the Slack channel to post to
   # Use the Slack Webhook URL here
   address3                        https://hooks.slack.com/services/ABCDEFGHI/FGHIJKLMN/123abc456def789ldt645Bgs
        }
```

### Test the configuration
Now it's all set and you should be able to receive notifications to your Slack channel. Just trigger some test alerts to make sure.

### Example screenshots
#### A *CRITICAL* message about a *HOST* from Nagios
![Nagios Critical Host Alert](screenshots/nagios-host-critical-example.jpg)

You can simulate this message by invoking the `slack-nagios-alert.sh` manually like:
```
./slack-nagios-alert.sh -U "<WEBHOOK_URL>" -t <SLACK_TEAM> -c <SLACK_CHANNEL> -u <SLACK_USER> -W HOST -Y PROBLEM -H bigbox.example.com -A 192.168.1.1 -X CRITICAL -M "Host down" -T "Mon Oct 17 06:00:00 CEST 2016" -Q "http://nagios.example.com/nagios"
```

#### A *WARNING* message about a *HOST* from Nagios
![Nagios Warning Host Alert](screenshots/nagios-host-warning-example.jpg)

You can simulate this message by invoking the `slack-nagios-alert.sh` manually like:
```
./slack-nagios-alert.sh -U "<WEBHOOK_URL>" -t <SLACK_TEAM> -c <SLACK_CHANNEL> -u <SLACK_USER> -W HOST -Y WARNING -H bigbox.example.com -A 192.168.1.1 -X CRITICAL -M "Host unreachable" -T "Mon Oct 17 06:00:00 CEST 2016" -Q "http://nagios.example.com/nagios"
```

#### An *OK* message about a *HOST* from Nagios
![Nagios OK Host Alert](screenshots/nagios-host-ok-example.jpg)

You can simulate this message by invoking the `slack-nagios-alert.sh` manually like:
```
./slack-nagios-alert.sh -U "<WEBHOOK_URL>" -t <SLACK_TEAM> -c <SLACK_CHANNEL> -u <SLACK_USER> -W HOST -Y WARNING -H bigbox.example.com -A 192.168.1.1 -X OK -M "Host is now OK" -T "Mon Oct 17 06:00:00 CEST 2016" -Q "http://nagios.example.com/nagios"
```

#### A *CRITICAL* message about a *SERVICE* from Nagios
![Nagios Critical Host Alert](screenshots/nagios-service-critical-example.jpg)

You can simulate this message by invoking the `slack-nagios-alert.sh` manually like:
```
./slack-nagios-alert.sh -U "<WEBHOOK_URL>" -t <SLACK_TEAM> -c <SLACK_CHANNEL> -u <SLACK_USER> -W SERVICE -Y PROBLEM -H bigbox.example.com -A 192.168.1.1 -S SSH -X CRITICAL -M "Service down" -T "Mon Oct 17 06:00:00 CEST 2016" -Q "http://nagios.example.com/nagios"
```

#### A *WARNING* message about a *SERVICE* from Nagios
![Nagios Warning Host Alert](screenshots/nagios-service-warning-example.jpg)

You can simulate this message by invoking the `slack-nagios-alert.sh` manually like:
```
./slack-nagios-alert.sh -U "<WEBHOOK_URL>" -t <SLACK_TEAM> -c <SLACK_CHANNEL> -u <SLACK_USER> -W SERVICE -Y PROBLEM -H bigbox.example.com -A 192.168.1.1 -S SSH -X WARNING -M "Service unreachable" -T "Mon Oct 17 06:00:00 CEST 2016" -Q "http://nagios.example.com/nagios"
```

#### An *OK* message about a *SERVICE* from Nagios
![Nagios OK Host Alert](screenshots/nagios-service-ok-example.jpg)

You can simulate this message by invoking the `slack-nagios-alert.sh` manually like:
```
./slack-nagios-alert.sh -U "<WEBHOOK_URL>" -t <SLACK_TEAM> -c <SLACK_CHANNEL> -u <SLACK_USER> -W SERVICE -Y PROBLEM -H bigbox.example.com -A 192.168.1.1 -S SSH -X OK -M "Service is now OK" -T "Mon Oct 17 06:00:00 CEST 2016" -Q "http://nagios.example.com/nagios"
```
