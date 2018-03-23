#!/bin/bash

##
# Script to send notifications from Zabbix to a Slack channel using WebHooks.
#
# For instructions and the source of this script please see https://github.com/flelli/slack-integrations
##

####################################################
# Configuration
# Set the following values before you use the script
####################################################

# The WebHook URL you need to get from Slack when configuring the integration
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/ABCDEFGHI/FGHIJKLMN/123abc456def789ldt645Bgs"

# The name of your Slack team
SLACK_TEAM="myslackteam"

# The name of the user that appears as sending messages
SLACK_USER="zabbix"

# This controls how much detail you want to have
MESSAGE_VERBOSITY="DETAILED"

# Set this to true if you want to enable debug messages to appear in logs
DEBUG=""

# The channel, subject and body must be the first three parameters on the command line, in order
SLACK_CHANNEL="$1"
ZABBIX_OUTPUT_SUBJECT="$2"
ZABBIX_OUTPUT_BODY="$3"

POSITIONAL=()
shift 3

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
	"--url="*)
	    SLACK_WEBHOOK_URL=$(echo $key | sed -e 's/^--url=//')
	    shift
	    ;;
	"--team="*)
	    SLACK_TEAM=$(echo $key | sed -e 's/^--team=//')
	    shift
	    ;;
	"--user="*)
	    SLACK_USER=$(echo $key | sed -e 's/^--user=//')
	    shift
	    ;;
	"--detail="*)
	    MESSAGE_VERBOSITY=$(echo $key | sed -e 's/^--detail=//')
	    shift
	    ;;
	"-d")
	    DEBUG="true"
	    shift
	    ;;
	*)
	    echo "Unknown option "$key
	    shift
	    ;;
    esac
done
set -- "${POSITIONAL[@]}"

#Set the message color based on Zabbix severity. These are color codes recognized by Slack
#If the message subject contains "OK" we sow the green message, if it contains "PROBLEM" red, otherwise we don't set the color
MSG_COLOR=""
[[ $ZABBIX_OUTPUT_SUBJECT =~ .*OK.* ]] && MSG_COLOR="good"
[[ $ZABBIX_OUTPUT_SUBJECT =~ .*PROBLEM.* ]] && MSG_COLOR="danger"

############################################
# Populate the message body
############################################
MSG_BODY="{\"channel\": \"$SLACK_CHANNEL\", \"username\": \"$SLACK_USER\", "
MSG_BODY+="    \"text\": \"$ZABBIX_OUTPUT_SUBJECT\","
if [[ "DETAILED" == "$MESSAGE_VERBOSITY" ]] || [[ "COMPACT" == "$MESSAGE_VERBOSITY" ]]; then
    MSG_BODY+="    \"attachments\": ["
    MSG_BODY+="		{"
    MSG_BODY+="			\"color\": \"$MSG_COLOR\","
    MSG_BODY+="			\"author_name\": \"$SLACK_USER\","
    MSG_BODY+="                 \"fields\": ["
    MSG_BODY+="                    {"
    MSG_BODY+="                         \"title\": \"Message\","
    MSG_BODY+="                         \"value\": \"$ZABBIX_OUTPUT_BODY\""
    MSG_BODY+="                    }"
    MSG_BODY+="                 ]"
    MSG_BODY+="         }"
    MSG_BODY+="     ]"
fi
MSG_BODY+="}"
############################################
# Message body complete
############################################

[[ ! -z $DEBUG ]] && echo "Webhook URL: $SLACK_WEBHOOK_URL"
[[ ! -z $DEBUG ]] && echo "Team       : $SLACK_TEAM"
[[ ! -z $DEBUG ]] && echo "User       : $SLACK_USER"
[[ ! -z $DEBUG ]] && echo "Channel    : $SLACK_CHANNEL"
[[ ! -z $DEBUG ]] && echo "Message body is:"
[[ ! -z $DEBUG ]] && echo $MSG_BODY

#Actually send the message to Slack
/usr/bin/curl -X POST -H "Content-type: application/json" --data "$MSG_BODY" $SLACK_WEBHOOK_URL
