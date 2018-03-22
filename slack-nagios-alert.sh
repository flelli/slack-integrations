#!/bin/bash

##
# Script to send notifications from Nagios to a Slack channel using WebHooks.
#
# For instructions and the source of this script please see https://github.com/flelli/slack-integrations
##

# Default values
MESSAGE_VERBOSITY="DETAILED"

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
	-I)
	    NAGIOS_ITEM_TYPE="$2"
	    shift # past argument
	    ;;
	-Y)
	    NAGIOS_NOTIFICATION_TYPE="$2"
	    shift # past argument
	    ;;
	-H)
	    NAGIOS_HOSTNAME="$2"
	    shift # past argument
	    ;;
	-A)
	    NAGIOS_HOSTIP="$2"
	    shift # past argument
	    ;;
	-S)
	    NAGIOS_SERVICENAME="$2"
	    shift # past argument
	    ;;
	-X)
	    NAGIOS_STATE="$2"
	    shift # past argument
	    ;;
	-M)
	    NAGIOS_OUTPUT="$2"
	    shift # past argument
	    ;;
	-T)
	    NAGIOS_TIMESTAMP="$2"
	    shift # past argument
	    ;;
	-Q)
	    NAGIOS_SERVER_BASE_CGI_URL="$2"
	    NAGIOS_SERVER_STATUS_URL=$NAGIOS_SERVER_BASE_CGI_URL"cgi-bin/status.cgi"
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

# Sanity checks
# Check that a valid URL has been provided
[[ -z "$SLACK_WEBHOOK_URL" ]] && echo "No Slack Webhook URL provided. Please provide one with the -U parameter" && exit 1
[[ -z "$SLACK_TEAM" ]] && echo "No Slack team provided. Please provide one with the -t parameter" && exit 1

#Set the message color based on Nagios service state. These are color codes recognized by Slack
case $NAGIOS_STATE in
	"CRITICAL")
	    MSG_COLOR="danger"
	    ;;
	"WARNING")
	    MSG_COLOR="warning"
	    ;;
	"OK")
	    MSG_COLOR="good"
	    ;;
	*)
	    MSG_COLOR=""
	    ;;
esac

############################################
# Populate the message body
############################################
MSG_BODY="{\"channel\": \"$SLACK_CHANNEL\", \"username\": \"$SLACK_USER\", "
case $NAGIOS_ITEM_TYPE in
    HOST)
	MSG_BODY+="    \"text\": \"From $SLACK_USER: host $NAGIOS_HOSTNAME is in state $NAGIOS_STATE\","
	;;
    SERVICE)
	MSG_BODY+="    \"text\": \"From $SLACK_USER: service $NAGIOS_SERVICENAME on $NAGIOS_HOSTNAME is in state $NAGIOS_STATE\","
	;;
    *)
	MSG_BODY+="    \"text\": \"From $SLACK_USER: unknown $NAGIOS_STATE notification with undefined item type\","
	;;
esac
if [[ "DETAILED" == "$MESSAGE_VERBOSITY" ]] || [[ "COMPACT" == "$MESSAGE_VERBOSITY" ]]; then
    MSG_BODY+="    \"attachments\": ["
    MSG_BODY+="		{"
    MSG_BODY+="			\"color\": \"$MSG_COLOR\","
    MSG_BODY+="			\"author_name\": \"$SLACK_USER\","
    MSG_BODY+="			\"author_link\": \"$NAGIOS_SERVER_BASE_CGI_URL\","
    MSG_BODY+="			\"footer\": \"Event occurred on $NAGIOS_TIMESTAMP\","
    MSG_BODY+="			\"fields\": ["
    if [ "$NAGIOS_ITEM_TYPE" = "SERVICE" ]; then
	MSG_BODY+="                {"
	MSG_BODY+="                    \"title\": \"Service\","
	MSG_BODY+="                    \"value\": \"$NAGIOS_SERVICENAME\""
	MSG_BODY+="                },"
    fi
    MSG_BODY+="                {"
    MSG_BODY+="                    \"title\": \"Host\","
    MSG_BODY+="                    \"value\": \"$NAGIOS_HOSTNAME ($NAGIOS_HOSTIP)\""
    MSG_BODY+="                },"
    MSG_BODY+="                {"
    MSG_BODY+="                    \"title\": \"State\","
    MSG_BODY+="                    \"value\": \"$NAGIOS_STATE\","
    MSG_BODY+="                    \"short\": true"
    MSG_BODY+="                },"
    MSG_BODY+="                {"
    MSG_BODY+="                    \"title\": \"Type\","
    MSG_BODY+="                    \"value\": \"$NAGIOS_NOTIFICATION_TYPE\","
    MSG_BODY+="                    \"short\": true"
    MSG_BODY+="                }"
    MSG_BODY+="            ]"
    MSG_BODY+="        }"
    if [[ "DETAILED" = "$MESSAGE_VERBOSITY" ]]; then
	MSG_BODY+="        ,{"
	MSG_BODY+="            \"color\": \"$MSG_COLOR\","
        MSG_BODY+="            \"title\": \"Details\","
	MSG_BODY+="            \"fields\": ["
        MSG_BODY+="                {"
	MSG_BODY+="                    \"title\": \"Message\","
        MSG_BODY+="                    \"value\": \"$NAGIOS_OUTPUT\""
	MSG_BODY+="                },"
        MSG_BODY+="                {"
	MSG_BODY+="                    \"title\": \"Further details\","
        case $NAGIOS_ITEM_TYPE in
    	    HOST)
    		MSG_BODY+="                    \"value\": \"<$NAGIOS_SERVER_STATUS_URL?hostgroup=all&style=hostdetail|Click here> for more details.\","
		;;
	    SERVICE)
		MSG_BODY+="                    \"value\": \"<$NAGIOS_SERVER_STATUS_URL?host=all|Click here> for more details.\","
		;;
	    *)
		MSG_BODY+="                    \"value\": \"<$NAGIOS_SERVER_STATUS_URL|Click here> for more details.\","
		;;
	esac	
	MSG_BODY+="                    \"short\": true"
	MSG_BODY+="                }"
	MSG_BODY+="            ]"
	MSG_BODY+="         }"	
    fi
    MSG_BODY+="    ]"
fi
MSG_BODY+="}"
############################################
# Message body complete
############################################

#Actually send the message to Slack
/usr/bin/curl -X POST -H "Content-type: application/json" --data "$MSG_BODY" $SLACK_WEBHOOK_URL
