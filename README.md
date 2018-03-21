# Summary
Here are some scripts and utilities I'm using to integrate [Slack](https://slack.com/) with other apps and services.
Use them freely.

* [nagios](nagios) contains scripts used for (Nagios)[https://www.nagios.org/]
* [zabbix](zabbix) contains scripts used for (Zabbix)[https://www.zabbix.com/]

# Set up
## Slack Webhook
In order to receive notifications you need an active Slack team and know which channel you will send the notifications to. You may wish to set up a new channel for notifications.
For general instructions about Slack incoming webhooks just jump to (this page)[https://api.slack.com/incoming-webhooks].

Then you're ready to set up your webhook by following these simple steps:
1. open the (Incoming Webhook)[https://my.slack.com/services/new/incoming-webhook/] custom integration page for your team
2. in the *Post to Channel* box select the default channel you want notifications to be sent to (or create a new channel in place). You will be able to override the target channel when using the script to send notifications
3. in the next page take note of the **Webhook URL** that was generated and optionally set other fields like the webhook label, name, icon etc. The URL looks like `https://hooks.slack.com/services/ABCDEFGHI/FGHIJKLMN/123abc456def789ldt645Bgs`. In the **Customize Name** field you can set the username you want notifications to appear from. For example you may set `nagios` or `zabbix`
