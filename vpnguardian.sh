#!/bin/sh

# All Rights Reversed - No Rights Reserved
#
# Written by ILEV Trebla at Sweetmorn,
# the 64th day of The Aftermath in the YOLD 3180


# ┬  ┬┌─┐┬─┐┬┌─┐┌┐ ┬  ┌─┐┌─┐
# └┐┌┘├─┤├┬┘│├─┤├┴┐│  ├┤ └─┐
#  └┘ ┴ ┴┴└─┴┴ ┴└─┘┴─┘└─┘└─┘

# Service to stop/start if ping fails
VPN="/etc/init.d/openvpn"

LOG="/tmp/vpnguardian.log"
# TODO: ^^ fix unsafe creation of logfile in prev. line

# Try to ping these IP addresses
IP1="8.8.8.8"
IP2="8.8.4.4"
PING1="/bin/ping -c 1 $IP1"
PING2="/bin/ping -c 1 $IP2"


# ┌─┐┬ ┬┌┐┌┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
# ├┤ │ │││││   │ ││ ││││└─┐
# └  └─┘┘└┘└─┘ ┴ ┴└─┘┘└┘└─┘

log()
{
  echo "`/bin/date +%y%m%d-%H:%m:%S`; $1" >> $LOG
}

fail()
{
  echo "$1"
  log "$1"
  exit 1
}

try_ping()
{
  PINGRES=1
  if ! $PING1 > /dev/null; then
    log "fail $IP1"
    sleep 5
    if ! $PING2 > /dev/null; then
      log "fail $IP2"
      sleep 10
      if ! $PING1 > /dev/null; then
        log "fail $IP1"
        sleep 10
        if ! $PING2 > /dev/null; then
          log "fail $IP2, giving up"
          PINGRES=0
        fi
      fi
    fi
  fi
}


# ┌─┐┌─┐
# │ ┬│ │
# └─┘└─┘

rm -f $LOG

if test "`id -u`" != "0"; then
  fail "Run me as root, please!"
fi

log "VPN guardian started"

# State machine
STATE=1
log "State 1"

# The NeverEnding Story
while [ 1 ]; do

  case "$STATE" in

    # State 1, try ping while VPN tunnel up
    "1" )
      try_ping
      if test "$PINGRES" == "0"; then
          log "State 1 -> 2"
          STATE=2
      else
        sleep 90
      fi
      ;;

    # State 2, failed, bring tunnel down
    "2" )
      log "State 2, bring tunnel down"
      $VPN stop
      sleep 2
      log "State 2->3 (ping while tunnel down)"
      STATE=3
      ;;

    # State 3, ping while tunnel down
    "3" )
      try_ping
      if test "$PINGRES" == "1"; then
          STATE=4
      else
        # Internet connection down, continue trying
        # until connection becomes available
        sleep 30
      fi
      ;;

    # State 4, bring tunnel up and go to state 1
    "4" )
      log "State 4, bring tunnel up"
      $VPN start
      sleep 30
      STATE=1
      ;;

  esac

done

##
# Local Variables:
# mode: sh
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
