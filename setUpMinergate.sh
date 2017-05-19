##MINERGATE SETUP SCRIPT
##RANDY HOGGARD
##V1.1
##AUGUST 9, 2015
##Must invoke script with sudo or as root

###variables

MINER='' #system user for miner
MINERHOME='' #home directory for miner user
MINERGATEDIR='' #dirctory for minergate files
PASS='' #password for system user
ENCPASS='' #Encrypted Password for system user
USR='' #minergate username (the email used to login to minergate)
COIN='' #the coin or coins to mine
finish='' #used to determine if a generic while has finished
finishPass='' #used to determine if password while has finished

###get dependencies

apt-get install dialog screen

finish="false"
while [ "$finish" = 'false' ]
do
    dialog --title "System User" --inputbox "Enter a system user to run the miner:" 8 40 2>/tmp/dialog.ans
    if [ $? = 1 ]; then
        rm -f /tmp/dialog.ans
        clear
        exit 0
    fi
    ANS=`cat /tmp/dialog.ans`
    egrep "^$ANS" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        dialog --title "Confirm User" --yesno "You entered $ANS for the user to run the miner. Is this correct?" 8 40
        if [ $? = 0 ]; then
            MINER=$ANS
            rm -f /tmp/dialog.ans
            clear
            finish="true"
        else
            clear
        fi
    else
        dialog --title "Create User" --yesno "The user $ANS was not found in the system. Create this user?" 8 40
        if [ $? = 0 ]; then
            MINER=$ANS
            rm -f /tmp/dialog.ans
            finishPass="false"
            while [ "$finishPass" = 'false' ]
            do
                dialog --title "Password" --inputbox "Enter a password for $MINER :" 8 40 2>/tmp/dialog.ans
                 if [ $? = 1 ]; then
                     rm -f /tmp/dialog.ans
                     clear
                     exit 0
                 fi
                 ANS=`cat /tmp/dialog.ans`
                dialog --title "Confirm Password" --yesno "You entered $ANS for the password. Is this correct?" 8 40
                if [ $? = 0 ]; then
                    PASS=$ANS
                    rm -f /tmp/dialog.ans
                    ENCPASS=$(perl -e 'print crypt($ARGV[0], "salt")' $PASS)
                    useradd -m -p $ENCPASS $MINER
                    if [ $? = 0 ]; then
                        dialog --title "User Added" --msgbox "The user $MINER was successfully added to the system" 8 40
                    else 
                        dialog --title "Error" --msgbox "There was a problem adding user $MINER to the system" 8 40
                        clear
                        exit 1
                    fi
                    finishPass="true"
                    clear
                else
                    clear
                fi
            done
            finish="true"
        else
            clear
        fi
    fi 
done
MINERHOME="/home/$MINER"
finish="false"
while [ "$finish" = 'false' ]
do
    dialog --inputbox "Enter your Minergate Username (email):" 8 40 2>/tmp/dialog.ans
    if [ $? = 1 ]; then
        rm -f /tmp/dialog.ans
        clear
        exit 0
    fi
    ANS=`cat /tmp/dialog.ans`
    rm -f /tmp/dialog.ans
    clear
    dialog --title "Confirm Username" --yesno "You entered $ANS for your Minergate username. Is this correct?" 8 40
    if [ $? = 0 ]; then
        USR=$ANS
        clear
        finish="true"
    else
        clear
    fi
done
finish="false"
while [ "$finish" = 'false' ]
do 
    dialog --title "Coin Menu"  --menu\
    "Choose a coin to mine or press <Cancel> to exit"\
    31 50 23 \
    "bcn" "Bytecoin" \
    "xmr" "Monero" \
    "qcn" "QuazarCoin" \
    "xdn" "DigitalNote" \
    "fcn" "FantomCoin" \
    "mcn" "MonetaVerde" \
    "aeon" "Aeon Coin"\
    "dsh" "Dashcoin" \
    "inf8" "Infinium-8" \
    "fcn+bcn" "FantomCoin + Bytecoin" \
    "fcn+xmr" "FantomCoin + Monero" \
    "fcn+qcn" "FantomCoin + QuazarCoin" \
    "fcn+xdn" "FantomCoin + DigitalNote" \
    "fcn+aeon" "FantomCoin + Aeon Coin" \
    "fcn+dsh" "FantomCoin + Dashcoin" \
    "fcn+inf8" "FantomCoin + Infinium-8" \
    "mcn+bcn" "MonetaVerde + Bytecoin" \
    "mcn+xmr" "MonetaVerde + Monero" \
    "mcn+qcn" "MonetaVerde + QuazarCoin" \
    "mcn+xdn" "MonetaVerde + DigitalNote" \
    "mcn+aeon" "MonetaVerde + Aeon Coin" \
    "mcn+dsh" "MonetaVerde + Dashcoin" \
    "mcn+inf8" "MonetaVerde + Infinium-8" 2>/tmp/dialog.ans
    if [ $? = 1 ]; then
        rm -f /tmp/dialog.ans
        clear
        exit 0
    fi
    ANS=`cat /tmp/dialog.ans`
    dialog --title "Confirm Coin" --yesno "You entered $ANS for your coin to mine. Is this correct?" 8 40
    if [ $? = 0 ]; then
        COIN=$ANS
        rm -f /tmp/dialog.ans
        clear
        finish="true"
    else
        clear
    fi
done
mkdir "$MINERHOME/minergate"
MINERGATEDIR="$MINERHOME/minergate"
wget -P $MINERGATEDIR/ https://minergate.com/download/deb-cli
dpkg -i $MINERGATEDIR/deb-cli
rm $MINERGATEDIR/deb-cli
chown $MINER: $MINERGATEDIR
echo "minergate-cli -user $USR -$COIN" > $MINERGATEDIR/startMinergate.sh
chown $MINER: $MINERGATEDIR/startMinergate.sh
chmod 700 $MINERGATEDIR/startMinergate.sh



echo "#!/bin/bash
    temp=\$(ps aux | grep minergate-cli | grep -v grep)
    echo \$temp 
    if echo \"\$temp\" | grep -q 'minergate-cli'; then
        echo 'Minergate-cli EXISTS!'
    else
        su - $MINER -c 'screen -dmS minergate $MINERGATEDIR/startMinergate.sh'
        echo 'WORKED!'
    fi" > $MINERGATEDIR/autoStartMinergate.sh
chown $MINER: $MINERGATEDIR/autoStartMinergate.sh
chmod 700 $MINERGATEDIR/autoStartMinergate.sh
echo "sed -i '\$i cd $MINERGATEDIR/; ./autoStartMinergate.sh' /etc/rc.local" > $MINERGATEDIR/boot.sh
sh $MINERGATEDIR/boot.sh
rm $MINERGATEDIR/boot.sh
echo "*/4 * * * * root sh $MINERGATEDIR/autoStartMinergate.sh" > /etc/cron.d/updateMinergate
sh $MINERGATEDIR/autoStartMinergate.sh

rm -f /tmp/dialog.ans
echo $MINER
echo $PASS
echo $ENCPASS
echo $MINERHOME
echo $USR
echo $COIN
