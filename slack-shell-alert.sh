#!/bin/bash

##
# Script to send generic notifications from the command line to a Slack channel using WebHooks.
#
# For instructions and the source of this script please see https://github.com/flelli/slack-integrations
##

####################################################
# Configuration
# You can set these values if you don't want to
# set them as arguments.
# Default values are set when appropriate
####################################################

# The WebHook URL you need to get from Slack when configuring the integration
SLACK_WEBHOOK_URL=""

# The name of your Slack team
SLACK_TEAM=""

# The cannel/user to send the message to
SLACK_CHANNEL="#monitoring"

# The name of the user that appears as sending messages
SLACK_USER="zabbix"

# The color to use for the message
MESSAGE_COLOR=""

# This controls how much detail you want to have
MESSAGE_VERBOSITY="DETAILED"

# The subject of the message
OUTPUT_SUBJECT=""

# The body of the message
OUTPUT_BODY=""


POSITIONAL=()
while [[ $# -gt 1 ]]
do
    key="$1"

    case $key in
        -U)
            SLACK_WEBHOOK_URL="$2"
            shift # past argument
            ;;
        -t)
            SLACK_TEAM="$2"
            shift # past argument
            ;;
        -c)
            SLACK_CHANNEL="$2"
            shift # past argument
            ;;
        -u)
            SLACK_USER="$2"
            shift # past argument
            ;;
        -v)
            MESSAGE_VERBOSITY="$2"
            shift # past argument
            ;;
        -C)
            MESSAGE_COLOR="$2"
            shift # past argument
            ;;
        -M)
            OUTPUT_SUBJECT="$2"
            shift # past argument
            ;;
        -B)
            OUTPUT_BODY="$2"
            shift # past argument
            ;;
        *)
            # unknown option
            echo "Unknown option "$key
            shift # past argument
        ;;
    esac
    shift # past argument or value
done
set -- "${POSITIONAL[@]}"



# Sanity checks
# Check that a valid URL has been provided
[[ -z "$SLACK_WEBHOOK_URL" ]] && echo "No Slack Webhook URL provided. Please provide one with the -U parameter" && exit 1
[[ -z "$SLACK_TEAM" ]] && echo "No Slack team provided. Please provide one with the -t parameter" && exit 1

############################################
# Populate the message body
############################################
MSG_BODY="{\"channel\": \"$SLACK_CHANNEL\", \"username\": \"$SLACK_USER\", "
MSG_BODY+="    \"text\": \"$OUTPUT_SUBJECT\","
if [[ "DETAILED" == "$MESSAGE_VERBOSITY" ]] || [[ "COMPACT" == "$MESSAGE_VERBOSITY" ]]; then
    MSG_BODY+="    \"attachments\": ["
    MSG_BODY+="         {"
    MSG_BODY+="                 \"color\": \"$MESSAGE_COLOR\","
    MSG_BODY+="                 \"author_name\": \"$SLACK_USER\","
    MSG_BODY+="                 \"fields\": ["
    MSG_BODY+="                    {"
    MSG_BODY+="                         \"title\": \"Message\","
    MSG_BODY+="                         \"value\": \"$OUTPUT_BODY\""
    MSG_BODY+="                    }"
    MSG_BODY+="                 ]"
    MSG_BODY+="         }"
    MSG_BODY+="     ]"
fi
MSG_BODY+="}"
############################################
# Message body complete
############################################

#Actually send the message to Slack
/usr/bin/curl -X POST -H "Content-type: application/json" --data "$MSG_BODY" $SLACK_WEBHOOK_URL
