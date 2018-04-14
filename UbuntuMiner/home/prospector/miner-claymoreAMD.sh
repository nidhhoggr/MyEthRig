#!/bin/bash
# starts or stops the claymore miner in a screen
# run from rc.local using $0 start screen
# or use the systemd service file

# systemd notes:
# sudo cp claymore.service /etc/systemd/system/
# sudo systemctl enable claymore
# beware of the PIDFILE location ;)

# Evert Mouw <post@evert.net>
# 2017-12-11

## Arch Linux specific
## installed libcurl-compat and
## needs env "LD_PRELOAD=libcurl.so.4.0.0"
## https://github.com/nanopool/Claymore-Dual-Miner/issues/10

## Optimizations are from:
## https://www.reddit.com/r/EtherMining/comments/6b9vcu/need_help_rx580_dual_mining_bios_modding_and/
## Note: -tstop is configured to prevent overheating

MINER_NAME="miner-claymoreAMD"
WALLET_ADDR="0x62daeFB38BD2a7996975C362e711ACCf4A56EDF3"
PIDFILE="/var/run/$MINER_NAME.pid"
BINARY="/home/prospector/claymore-dual-miner-11.6/ethdcrminer64"
ACCOUNT="-eworker 71daf1 -epool stratum+tcp://pool-usa.ethosdistro.com:5001 -ewal $WALLET_ADDR -epsw x -epool stratum+tcp://pool-eu.ethosdistro.com:5001 -ewal $WALLET_ADDR -epsw x"
OPTIMIZATIONS="-esm 0 -dbg -1 -wd 0 -colors 0 -allcoins 1 -allpools 1 -gser 2 -di 0,1,2,3 -mclock 2100,2100,2100,2200 -cclock 1160,1160,1160,1250 -mport 0"
EMAIL="post@evert.net"

## environment variables
## use sudo with -E or --preserve-env
#*segfault!*#export GPU_FORCE_64BIT_PTR=0
export GPU_MAX_ALLOC_PERCENT=100

MINERBIN=$(basename $BINARY)

# First test sudo rights (kenorb, 2014).
if timeout 2 sudo id > /dev/null
then
  echo "Yes, we can sudo :-)"
else
  echo "You need sudo rights."
  exit 1
fi

# If "stop" option is given, kill the process
if [ "$1" == "stop" ]
then
  echo "Stopping the miner with signal 2 (ctrl-q)"
  pkill -2 $MINERBIN
  sleep 2
  if pidof $BINARY > /dev/null
  then
    killall $MINERBIN
  fi
  if [ -e $PIDFILE ]
  then
    rm $PIDFILE
  fi
  exit
fi

# Start the miner
if [ "$1" == "start" ]
then
  MSG=""
  echo "Starting the miner!"
  if [ "$2" == "screen" ]
  then
    echo "(in a detached screen)"
    PREFIX="screen -dm -S $MINER_NAME"
    MSG="Detached screen session loaded while "
  fi
  $PREFIX sudo -E env "LD_PRELOAD=libcurl.so.4.0.0" $BINARY $ACCOUNT $OPTIMIZATIONS
  MSG="$MSG starting the miner :-)" | mail -s "#~ Miner started on $(hostname)" $EMAIL
  if [ "$2" == "screen" ]
  then
    sleep 1
    PID=$(screen -list | grep $MINER_NAME | egrep -o [0-9]+)
    echo "$PID" > $PIDFILE
  fi
  exit
fi

# Get process
if [ "$1" == "status" ]
then
  if pidof $BINARY > /dev/null
  then
    echo "PIDs of running miner $MINERBIN (started)"
    pidof $MINERBIN
    echo "Active screen sessions:"
    screen -list | grep $MINER_NAME
  else
    "$MINERBIN not running (stopped)"
  fi
  exit
fi

# Help
if [ "$1" == "help" ]
then
  echo "Run $0 with one of these arguments:"
  echo "start | stop | status | help"
  exit
fi

