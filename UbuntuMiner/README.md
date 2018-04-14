## Purpose

The purpose of this repository is to provide the necessar files to be able to run both AMD and Nvidia GPU's
simulataneously on an Ubuntu Server distro. This particular server was mounted from the following repo:
 
 - https://github.com/Cyclenerd/ethereum_nvidia_miner

The issue with that image was there was no support for AMD. I had the AMD drivers and tweak some configuration
files to get both drivers running smoothly at boot time. In order for this to happen there must be no dedicated
GPU at the grub boot prompt (as specified in `/etc/default/grub`) and `lightdm` must be installed.


The two seperate services are dedicated to Nvidia and AMD and are ran as two seperate processes. 

## Installation 

1. First Copy the files as they are located to their respective directories.

2. Customize the service script configuration variables.
```bash
MINER_NAME="miner-claymoreAMD"
WALLET_ADDR="0x62daeFB38BD2a7996975C362e711ACCf4A56EDF3"
PIDFILE="/var/run/$MINER_NAME.pid"
BINARY="/home/prospector/claymore-dual-miner-11.6/ethdcrminer64"
ACCOUNT="-eworker 71daf1 -epool stratum+tcp://pool-usa.ethosdistro.com:5001 -ewal $WALLET_ADDR -epsw x -epool stratum+tcp://pool-eu.ethosdistro.com:5001 -ewal $WALLET_ADDR -epsw x"
OPTIMIZATIONS="-esm 0 -dbg -1 -wd 0 -colors 0 -allcoins 1 -allpools 1 -gser 2 -di 0,1,2,3 -mclock 2100,2100,2100,2200 -cclock 1160,1160,1160,1250 -mport 0"
EMAIL="post@evert.net"
```

3. Enable the service and start them.
`sudo systemctl enable miner-claymoreAMD`
`sudo systemctl enable miner-claymoreNvidia`
`sudo systemctl start miner-claymoreAMD`
`sudo systemctl start miner-claymoreNvidia`

4. To perform logging:
`sudo screen -ls`
```
There are screens on:
  3013.miner-claymoreAMD  (04/14/2018 02:02:13 PM)  (Detached)
  2996.miner-claymoreNvidia
```
`sudo screen -r [process_id]`

