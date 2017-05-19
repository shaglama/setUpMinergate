# setUpMinergate
Set up minergate cli  miner on ubuntu systems. tested on 16.04. may work on others.
**********************************************************************************************
to use, download setUpMinergate.sh, then run. i.e. :
in terminal :

wget https://github.com/shaglama/setUpMinergate/raw/master/setUpMinergate.sh

chmod +x setUpMinergate.sh

./setUpMinergate.sh

Anser the questions and pick your coin and the script will set up everything for you. It will configure the miner to start at boot and will check every so often to make sure the miner is still running and restart it if it isn't. The script starts the miner in the background in screen. To access the miner display, open terminal and type:
screen -s minergate
***********************************************************************************************
To kill miner:
with miner display open:
hold control and press a
press k
press y
note: miner will automatically restart. To disable automatic restart, comment out a line similar to this line in /etc/rc.local by placing a # at the beginning of the line : 
*/4 * * * * root sh $MINERGATEDIR/autoStartMinergate.sh" > /etc/cron.d/updateMinergate

options for automatic enable and disable of autostart planned for future release of script
 ***********************************************************************************************
To uninstall miner:
in terminal:

rm /etc/cron.d/updateMinergate

sed '/autoStartMinergate/d' /etc/rc.local
 
enter home directory of user chosen during install
find minergate directory
delete the directory
 
ie:
rm -r /home/user/minergate
 
a seperate automated uninstall option is planned for the next version of the script
