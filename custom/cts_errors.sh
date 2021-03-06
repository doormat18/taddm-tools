#!/bin/sh

#set -x

# get path of script
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# if not set, use default
COLLATION_HOME=${COLLATION_HOME:-/opt/IBM/taddm/dist}

BINDIR=$COLLATION_HOME/bin
COMMONPART="$BINDIR/common.sh"
. $COMMONPART

PROPS=$SCRIPTPATH/custom.properties
if [ -e $PROPS ]; then
  EMAIL=`awk -F= '/^EMAIL/ {print $2}' $PROPS`
else
  echo "Properties file $PROPS not found, no email will be sent"
fi

USER=operator
PASSWORD=collation

SQL="$COLLATION_HOME/custom/sql/cts_errors.sql"
ERRORS=$(cd $BINDIR; ./dbquery.sh -q -c -u "$USER" -p "$PASSWORD" "`cat $SQL`" | grep -v "SENSOR,EVENT_DESC")

if [ ! -z "$ERRORS" ]; then
  echo -e "Following errors were found during EMC SRM CTS sensor discovery and need addressed immediately: \n${ERRORS}" | mailx -s "TADDM ViPR SRM discovery error" -r "TADDM <${USER}@${HOSTNAME}>" $EMAIL 2>/dev/null
fi