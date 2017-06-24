#!/bin/sh

# Summary:
# This script is a one stop installing and maintenance script for Ion. 
# It is used to startup a new VPS. It will download, compile, and maintain the wallet.

# myScrapeAddress: This is the address that the wallet will scrape mining coins to:
# "IF YOU DON'T USE ATTRIBUTES TO PASS IN YOUR VALUES THEN:"
# "CHANGE THE ADDRESS BELOW TO BE THE ONE FOR YOUR WALLET"
myScrapeAddress=DJnERexmBy1oURgpp2JpzVzHcE17LTFavD
# "CHANGE THE ADDRESS ABOVE TO BE THE ONE FOR YOUR WALLET"
# "CHANGE THE ADDRESS ABOVE TO BE THE ONE FOR YOUR WALLET"

# Credit:
# Written by those who are dedicated to teaching other about ion (ionomy.com) and other cryptocurrencies. 
# Contributors:         ION Donation Address                      BTC Address
#   LordDarkHelmet      DJnERexmBy1oURgpp2JpzVzHcE17LTFavD        1NZya3HizUdeJ1CNbmeJEW3tHkXUG6PoNn
#   Broyhill            DQDAmUJKGyErmgVHSnSkVrrzssz3RedW2V
#   Coinkiller          DLvnNNYzbUxtDyADbyGDSio9ghazEcvRBk
#   Your name here, help add value by contributing. Contact LordDarkHelmet on Github!

# Version:
varVersionNumber="1.0.23"
varVersionDate="June 10, 2017"
varVersion="${varVersionNumber} ionStartupScript.sh ${varVersionDate} Released by LordDarkHelmet"

# The script was tested using on Vultr. Ubuntu 14.04, 16.04, & 17.04 x64, 1 CPU, 512 MB ram, 20 GB SSD, 500 GB bandwith
# LordDarkHelmet's affiliate link: http://www.vultr.com/?ref=6923885
# 
# If you are using Vultr as a VPN service and you run this in as your startup script, then you should see the results in /tmp/firstboot.log
# The script will take some time to run. You can view progress when you first log in by typing in the command:
# tail -f /tmp/firstboot.log


echo ""
echo "==========================================================================="
echo "$varVersion"
echo "Original Version found at: https://github.com/cevap/IonScripts"
echo "Local Filename: $0"
echo "Local Time: $(date +%F_%T)"
echo "System Info: $(uname -a)"
echo "User $(id -u -n)  UserID: $(id -u)"
echo "==========================================================================="

# Variables:
# These variables control the script's function. The only item you should change is the scrape address (the first variable, see above)
#

# Are you setting up a Ionode? if so you want to set these variables
# Set varIonode to 1 if you want to run a node, otherwise set it to zero. 
varIonode=0
# This will set the external IP to your IP address (linux only), or you can put your IP address in here
varIonodeExternalIP=$(hostname -I)
# This is your ionode private key. To get it run ion-cli ionode genkey
varIonodePrivateKey=ReplaceMeWithOutputFrom_ion-cli_ionode_genkey
# This is the label you want to give your ionode
varIonodeLabel=""

# Location of Ion Binaries, GIT Directories, and other useful files
# Do not use the GIT directory (/Ion/) for anything other than GIT stuff
varUserDirectory=/root/
varIonBinaries="${varUserDirectory}ION/bin/"
varScriptsDirectory="${varUserDirectory}ION/UserScripts/"
varIonConfigDirectory="${varUserDirectory}.ion/"
varIonConfigFile="${varUserDirectory}.ion/ion.conf"
varGITRootPath="${varUserDirectory}"
varGITIonPath="${varGITRootPath}Ion/"
varBackupDirectory="${varUserDirectory}ION/Backups/"

# Quick Non-Source Start (get binaries and blockchain from the web, not completely safe or reliable, but fast!)

# QuickStart Binaries
varQuickStart=true
# Quickstart compressed file location and name
varQuickStartCompressedFileLocation=https://github.com/duality-solutions/Ion/releases/download/v1.4.0.0/Ion-Linux-x64-v1.4.0.0.tar.gz
varQuickStartCompressedFileName=Ion-Linux-x64-v1.4.0.0.tar.gz
varQuickStartCompressedFilePathForDaemon=ion-1.4.0/bin/iond
varQuickStartCompressedFilePathForCLI=ion-1.4.0/bin/ion-cli

# QuickStart Bootstrap (The developer recommends that you set this to true. This will clean up the blockchain on the network.)
varQuickBootstrap=false
varQuickStartCompressedBootstrapLocation=http://ion.coin-info.net/bootstrap/bootstrap-latest.tar.gz
varQuickStartCompressedBootstrapFileName=bootstrap-latest.tar.gz
varQuickStartCompressedBootstrapFileIsZip=false

# QuickStart Blockchain (Downloading the blockchain will save time. It is up to you if you want to take the risk.)
varQuickBlockchainDownload=true
varQuickStartCompressedBlockChainLocation=http://108.61.216.160/cryptochainer.chains/chains/Ion_blockchain.zip
varQuickStartCompressedBlockChainFileName=Ion_blockchain.zip
varQuickStartCompressedBlockChainFileIsZip=true

# Compile
# -varCompile will compile the code
varCompile=true


#
#Expand Swap File
varExpandSwapFile=true

#Mining Variables
#varMining0ForNo1ForYes controls if we mine or not. set it to 0 if you don't want to mine, set to 1 if you want to mine
varMining0ForNo1ForYes=1
#varMiningProcessorLimit set the number of processors you want to use -1 for unbounded (all of them)
varMiningProcessorLimit=-1
#varMiningScrapeTime is the amount of time in minutes between scrapes use 5 recommended
varMiningScrapeTime=5

#Ion GIT
varRemoteRepository=https://github.com/duality-solutions/Ion

#Script Repository
#This can be used to auto heal and update the script system. 
#If a future deployment breaks something, an update by the repository owner can run a script on your machine. 
#This is dangerous and not implemented
varRemoteScriptRepository=https://github.com/cevap/IonScripts

#AutoUpdater
#This runs the auto update script. If you do not want to automatically update the script, then set this to false. If a new update 
varAutoUpdate=true

#AutoRepair
#Future Repair System. 
varAutoRepair=true
#Watchdog timer. Check every X min to see if we are still running. (5 min recommended)
varWatchdogTime=5
#Turn on or off the watchdog. default is true. 
varWatchdogEnabled=true

#System Lockdown
#Future System Lockdown. Firewall, security rules, etc. 
varSystemLockdown=true

#Filenames of Generated Scripts
ionStop="${varScriptsDirectory}ionStopIond.sh"
ionStart="${varScriptsDirectory}ionMineStart.sh"
ionScrape="${varScriptsDirectory}ionScrape.sh"
ionAutoUpdater="${varScriptsDirectory}ionAutoUpdater.sh"
ionPre_1_4_0_Fix="${varScriptsDirectory}ionPre_1_4_0_Fix.sh"
ionWatchdog="${varScriptsDirectory}ionWatchdog.sh"

#Vultr API additions
varVultrAPIKey=""
varVultrLabelmHz=false

#End of Variables


#
echo "-------------------------------------------"
echo "Read in attributes. This allows someone to run the script with their variables without having to modify this script."
echo ""
echo "To see all options pass in the -h attribute"
echo ""
echo "Options passed in: $@"
echo ""
while getopts :s:d:y:a:r:l:w:c:v:h option
do
    case "${option}"
    in
        s) 
            myScrapeAddress=${OPTARG}
            echo "-s has set myScrapeAddress=${myScrapeAddress}"
            ;;
        d) 
            varIonodePrivateKey=${OPTARG}
            varIonode=1
            echo "-d has set varIonode=1, and has set varIonodePrivateKey=${varIonodePrivateKey} (the script will set up a ionode)"
            ;;
		y) 
            varIonodeLabel=${OPTARG}
            echo "-y has set varIonodeLabel=${varIonodeLabel}"
            ;;
        a)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varAutoUpdate=true
                echo "-a has set varAutoUpdate to true (default), the system will auto update at a random time every 24 hours"
            else
                varAutoUpdate=false
                echo "-a has set varAutoUpdate to false, the system will not auto update. If an update occurs, you must do it manually."
            fi
            ;;
        r)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varAutoRepair=true
                echo "-r AUTO REPAIR NOT IMPLEMENTED YET, Auto Repair is set to True (default), the system will auto repair"
            else
                varAutoRepair=false
                echo "-r AUTO REPAIR NOT IMPLEMENTED YET, Auto Repair is set to FALSE, the system will not auto repair. If there is an issue you must repair it manually."
            fi
            ;;
        l)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varSystemLockdown=true
                echo "-l AUTO LOCKDOWN NOT IMPLEMENTED YET, Auto Lockdown is set to True (default), System will be secured"
            else
                varSystemLockdown=false
                echo "-l AUTO LOCKDOWN NOT IMPLEMENTED YET, Auto Lockdown is set to FALSE, the system will not be secured."
            fi
			;;
        w)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varWatchdogEnabled=true
                echo "-w varWatchdogEnabled is set to true (default), Watchdog will check every $varWatchdogTime min to see if iond is still running"
            else
                varWatchdogEnabled=false
                echo "-w varWatchdogEnabled is set to false, Watchdog will be disabled"
            fi
            ;;
        c)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varCompile=true
                echo "-c varCompile is set to true (default), We will compile the code"
            else
                varCompile=false
                echo "-c varCompile is set to false, We will not compile"
                varAutoUpdate=false
                echo "   varAutoUpdate is also set to false because it requires compiling"
            fi
            ;;
        v)
		    myTemp=${OPTARG}
			if [ "$( echo "${myTemp}" | tr '[A-Z]' '[a-z]' )" = mhz ]; then
                varVultrLabelmHz=true
                echo "-v has set an option to show the server's mHz on the label"
            else
                varVultrAPIKey=${myTemp}
                echo "-v has set varVultrAPIKey=${varVultrAPIKey}"
            fi
            ;;
        h)
            echo ""
			echo "Help:"
			echo "This script, $0 , can use the following attributes:"
            echo " -s Scrape address requires an attribute Ex.  -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD"
            echo " -d Ionode Private key. if you populate this it will setup a ionode.  ex -d ReplaceMeWithOutputFrom_ion-cli_ionode_genkey"
			echo " -y Ionode Label, a human redable label for your ionode. Usefull with the -v option."
            echo " -a Auto Updates. Turns auto updates (on by default) on or off, ex -a true"
            echo " -r Auto Repair. Turn auto repair on (default) or off, ex -r true"
            echo " -l System Lockdown. (future) Secure the instance. True to lock down your system. ex -l false"
            echo " -w Watchdog. The watchdog restarts processes if they fail. true for on, false for off."
            echo " -c Compile. Compile the code, default is true. If you set it to false it will also turn off AutoUpdate"
			echo " -v Vultr API. see http://www.vultr.com/?ref=6923885 If you are using vultr as an API service, this will change the label to update the last watchdog status"
            echo " -h Display Help then exit."
			echo ""
			echo "Example 1: Just set up a simple miner"
			echo "sudo sh $0 -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD"
			echo ""
			echo "Example 2: Setup a remote ionode"
			echo "sudo sh $0 -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD -d ReplaceMeWithOutputFrom_ion-cli_ionode_genkey"
			echo ""
			echo "Example 3: Run a miner, but don't compile (auto update will be turned off by default), useful for low RAM VPS's that don't allow for SWAP files"
			echo "sudo sh $0 -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD -c false"			
			echo ""
			echo "Example 4: Turn off auto update on a ionode, you will be required to manually update if a new version comes along"
			echo "sudo sh $0 -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD -d ReplaceMeWithOutputFrom_ion-cli_ionode_genkey -a false"
			echo ""			
			echo "sudo sh Example 5: Setup a miner that donates to the author's address DJnERexmBy1oURgpp2JpzVzHcE17LTFavD"
			echo "$0"
			echo ""			
			echo "PLEASE REMEMBER TO USE THE \"-s\" attribute. If you don't then you will be donating and not scraping to your address."
			echo ""
			echo ""
			exit 1
            ;;
        \?) echo "Invalid Option Tag: -$OPTARG";;
        :) echo "Option -$OPTARG requires an argument. Using Default Values and continuing.";;
    esac
done

echo "-------------------------------------------"
echo "==============================================================="
echo "SCRAPE ADDRESS: $myScrapeAddress"
echo "==============================================================="
echo "System Information:"
cat /etc/*release | grep -v URL
echo "If you found this script useful please contribute. Feedback is appreciated"
echo "==============================================================="


### Prep your VPS (Increase Swap Space and update) ###

if [ "$varExpandSwapFile" = true ]; then
    cd $varUserDirectory
    # This will expand your swap file. It is not necessary if your VPS has more than 4G of ram, but it wont hurt to have
    echo "Expanding the swap file for optimization with low RAM VPS..."
    echo "sudo fallocate -l 4G /swapfile"
	sudo fallocate -l 4G /swapfile
    echo "sudo chmod 600 /swapfile"
	sudo chmod 600 /swapfile
	echo "sudo mkswap /swapfile"
    sudo mkswap /swapfile
    echo "sudo swapon /swapfile"
	sudo swapon /swapfile

    # the following command will append text to fstab to make sure your swap file stays there even after a reboot.
	varSwapFileLine=$(cat /etc/fstab | grep "/swapfile none swap sw 0 0")
	if [  "varSwapFileLine" = "" ]; then
	    echo "Adding swap file line to /etc/fstab"
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
	else
	    echo "Swap file line is already in /etc/fstab"
	fi
    echo "Swap file expanded."	
	
	echo "Current Swap File Status:"
	echo "sudo swapon -s"
	sudo swapon -s
	echo ""
	echo "Let's check the memory"
	echo "free -m"
	free -m
	echo ""
	echo "Ok, now let's check the swapieness"
	echo "cat /proc/sys/vm/swappiness"
	cat /proc/sys/vm/swappiness
	echo ""
	echo "Desktops usually have a swapieness of 60 or so, VPS's are usually lower. It should not matter for this application. It is just a curiosity."
	echo "End of Swap File expansion"
	echo "-------------------------------------------"
fi

# Ensure that your system is up to date and fully patched
echo ""
echo "Updating OS and packages..."
echo "sleeping for 60 seconds, this is because some VPS's are not fully up if you use this as a startup script"
sleep 60
echo "sudo apt-get update"
sudo apt-get update
echo "sudo apt-get -y upgrade"
sudo apt-get -y upgrade
echo "OS and packages updated."
echo ""

#Install any utilities you need for the script
echo ""
echo "Installing the JSON parser jq"
sudo apt-get -y install jq
echo "Installing the unzip utility"
sudo apt-get -y install unzip
echo "Installing nano"
sudo apt-get -y install nano
echo ""


## make the directories we are going to use
echo "Make the directories we are going to use"
mkdir -pv $varIonBinaries
mkdir -pv $varScriptsDirectory
mkdir -pv $varBackupDirectory

## Create Scripts ##
echo "-------------------------------------------"
echo "Create the scripts we are going to use: "
echo "--"

### Script #1: Stop iond ###
# Filename ionStopIond.sh
cd $varScriptsDirectory
echo "Creating The Stop iond Script: ionStopIond.sh"
echo '#!/bin/sh' > ionStopIond.sh
echo "# This file was generated. $(date +%F_%T) Version: $varVersion" >> ionStopIond.sh
echo "# This script is here to force stop or force kill iond" >> ionStopIond.sh
echo "echo \"\$(date +%F_%T) Stopping the iond if it already running \"" >> ionStopIond.sh
echo "PID=\`ps -eaf | grep iond | grep -v grep | awk '{print \$2}'\`" >> ionStopIond.sh
echo "if [ \"\" !=  \"\$PID\" ]; then" >> ionStopIond.sh
echo "    if [ -e ${varIonBinaries}ion-cli ]; then"  >> ionStopIond.sh
echo "        sudo ${varIonBinaries}ion-cli stop" >> ionStopIond.sh
echo "        echo \"\$(date +%F_%T) Stop sent, waiting 30 seconds\""  >> ionStopIond.sh
echo "        sleep 30" >> ionStopIond.sh
echo "    fi"  >> ionStopIond.sh
echo "# At this point we should be stopped. Let's recheck and kill if we need to. "  >> ionStopIond.sh
echo "    PID=\`ps -eaf | grep iond | grep -v grep | awk '{print \$2}'\`" >> ionStopIond.sh
echo "    if [ \"\" !=  \"\$PID\" ]; then" >> ionStopIond.sh
echo "        echo \"\$(date +%F_%T) Rouge iond process found. Killing PID: \$PID\""  >> ionStopIond.sh
echo "        sudo kill -9 \$PID" >> ionStopIond.sh
echo "        sleep 5" >> ionStopIond.sh
echo "        echo \"\$(date +%F_%T) Iond has been Killed! PID: \$PID\""  >> ionStopIond.sh
echo "    else"  >> ionStopIond.sh
echo "        echo \"\$(date +%F_%T) Iond has been stopped.\""  >> ionStopIond.sh
echo "    fi" >> ionStopIond.sh
echo "else"  >> ionStopIond.sh
echo "    echo \"\$(date +%F_%T) Ion is not running. No need for shutdown commands.\""  >> ionStopIond.sh
echo "fi" >> ionStopIond.sh
echo "# End of generated Script" >> ionStopIond.sh
echo "Changing the file attributes so we can run the script"
chmod +x ionStopIond.sh
echo "Created ionStopIond.sh"
ionStop="${varScriptsDirectory}ionStopIond.sh"
echo "--"

### Script #2: MINING START SCRIPT ###
# Filename ionMineStart.sh
cd $varScriptsDirectory
echo "Creating Mining Start script: ionMineStart.sh"
echo '#!/bin/sh' > ionMineStart.sh
echo "" >> ionMineStart.sh
echo "# This file, ionMineStart.sh, was generated. $(date +%F_%T) Version: $varVersion" >> ionMineStart.sh
echo "echo \"\$(date +%F_%T) Starting Ion miner: \$(date)\"" >> ionMineStart.sh
echo "sudo ${varIonBinaries}iond --daemon" >> ionMineStart.sh
echo "echo \"\$(date +%F_%T) Waiting 15 seconds \"" >> ionMineStart.sh
echo "sleep 15" >> ionMineStart.sh
echo "# End of generated Script" >> ionMineStart.sh
#./ion-cli settxfee 0.0

echo "Changing the file attributes so we can run the script"
chmod +x ionMineStart.sh
echo "Created ionMineStart.sh."
ionStart="${varScriptsDirectory}ionMineStart.sh"
echo "--"

### script #3: GENERATE SCRAPE SCRIPT ###
# Filename: ionScrape.sh
cd $varScriptsDirectory
echo "Creating Scrape script: ionScrape.sh"
echo '#!/bin/sh' > ionScrape.sh
echo "" >> ionScrape.sh
echo "# This file, ionScrape.sh, was generated. $(date +%F_%T) Version: $varVersion" >> ionScrape.sh
echo "" >> ionScrape.sh
echo "myBalance=\$(sudo ${varIonBinaries}ion-cli getbalance)" >> ionScrape.sh
echo "if [ \"\$myBalance\" = \"\" ] ; then" >> ionScrape.sh
echo "    echo \"\$(date +%F_%T) No Response, is the daemon running, does it exist yet?\"" >> ionScrape.sh
echo "else" >> ionScrape.sh
echo "    if [ \$myBalance != \"0.00000000\" ];then" >> ionScrape.sh
echo "        echo \"\$(date +%F_%T) Scraping a balance of \$myBalance to $myScrapeAddress \"" >> ionScrape.sh
echo "        sudo ${varIonBinaries}ion-cli sendtoaddress \"$myScrapeAddress\" \$(sudo ${varIonBinaries}ion-cli getbalance) \"\" \"\" true " >> ionScrape.sh
echo "    fi" >> ionScrape.sh
echo "fi" >> ionScrape.sh
echo "# End of generated Script" >> ionScrape.sh
echo "Changing the file attributes so we can run the script"
chmod +x ionScrape.sh
echo "Created ionScrape.sh."
ionScrape="${varScriptsDirectory}ionScrape.sh"
echo "--"

### script #4: AUTO UPDATER SCRIPT ###
# Filename: ionAutoUpdater.sh
cd $varScriptsDirectory
echo "Creating Scrape script: ionAutoUpdater.sh"
echo '#!/bin/sh' > ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo "# This file, ionAutoUpdater,sh, was generated. $(date +%F_%T) Version: $varVersion" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo "cd $varGITIonPath" >> ionAutoUpdater.sh
echo "if [ \"\`git log --pretty=%H ...refs/heads/master^ | head -n 1\`\" = \"\`git ls-remote $varRemoteRepository -h refs/heads/master |cut -f1\`\" ] ; then " >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : We are up to date.\"" >> ionAutoUpdater.sh
echo "else" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Changes to the repository, Preparing to update.\"" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo " # 1. Download the new source code from the repository if it has been updated" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Remove old repository, we need to do a clean clone for the next version comparison to work. Do not git pull.\"" >> ionAutoUpdater.sh
echo " rm -fdr $varGITIonPath" >> ionAutoUpdater.sh
echo " mkdir -p $varGITIonPath" >> ionAutoUpdater.sh
echo " cd $varUserDirectory" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Downloading the source code\"" >> ionAutoUpdater.sh
echo " sudo git clone $varRemoteRepository" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo " # 2. Compile the new code" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Compile the souce code\"" >> ionAutoUpdater.sh
echo " cd $varGITIonPath" >> ionAutoUpdater.sh
echo " echo \"Check if we can optimize mining using the avx2 instruction set\"" >> ionAutoUpdater.sh
echo " varavx2=\$(grep avx2 /proc/cpuinfo)" >> ionAutoUpdater.sh
echo " if [  \"varavx2\" = \"\" ]; then" >> ionAutoUpdater.sh
echo "   echo \"avx2 not found, normal compile, no avx2 optimizations\"" >> ionAutoUpdater.sh
echo " else" >> ionAutoUpdater.sh
echo "   CPPFLAGS=-march=native" >> ionAutoUpdater.sh
echo " fi" >> ionAutoUpdater.sh
echo " sudo ./autogen.sh && sudo ./configure --without-gui && sudo make" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Compile Finished.\"" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo " # 3. Scrape if there are any funds before we stop" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Scrape if there are any funds before we stop.\"" >> ionAutoUpdater.sh
echo " sudo ${ionScrape}" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo " echo \"Fix for wallets below 1.4.0\"" >> ionAutoUpdater.sh 
echo " sudo ${ionPre_1_4_0_Fix}" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo " # 4. Stop the running daemon" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Stop the running daemon.\"" >> ionAutoUpdater.sh
echo " sudo ${ionStop}" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo " # 5. Replace the executable files" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Replace the executable files.\"" >> ionAutoUpdater.sh
echo " mkdir -pv $varIonBinaries" >> ionAutoUpdater.sh
echo " sudo cp -v ${varGITIonPath}src/iond $varIonBinaries" >> ionAutoUpdater.sh
echo " sudo cp -v ${varGITIonPath}src/ion-cli $varIonBinaries" >> ionAutoUpdater.sh
echo " sudo cp -v ${varGITIonPath}src/iond /usr/local/bin" >> ionAutoUpdater.sh
echo " sudo cp -v ${varGITIonPath}src/ion-cli /usr/local/bin" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo " # 6. Start the daemon" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Start the daemon. Mining will automatically start once synced.\"" >> ionAutoUpdater.sh
echo " sudo ${varIonBinaries}iond --daemon" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo " echo "waiting 10 seconds"" >> ionAutoUpdater.sh
echo " sleep 10" >> ionAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Now running the latest GIT version.\"" >> ionAutoUpdater.sh
echo "" >> ionAutoUpdater.sh
echo "fi" >> ionAutoUpdater.sh
echo "# End of generated Script" >> ionAutoUpdater.sh
echo "Changing the file attributes so we can run the script"
chmod +x ionAutoUpdater.sh
echo "Created ionAutoUpdater.sh."
ionAutoUpdater="${varScriptsDirectory}ionAutoUpdater.sh"
echo "--"


### Script #5: Fix wallet issues in version 1.4.0 and below ###
# Filename ionPre_1_4_0_Fix.sh
# This file will be deprecated a version or two past where the network no longer connects to versions below 1.4.0
cd $varScriptsDirectory
echo "Creating The Stop iond Script: ionPre_1_4_0_Fix.sh"
echo '#!/bin/sh' > ionPre_1_4_0_Fix.sh
echo "# This file, ionPre_1_4_0_Fix.sh, was generated.  Version: $varVersion" >> ionPre_1_4_0_Fix.sh
echo "# This file will be deprecated a version or two past where the network no longer connects to versions below 1.4.0" >> ionPre_1_4_0_Fix.sh
echo "
echo \"---------------------------------
\$(date +%F_%T)\ ionPre_1_4_0_Fix Started
Take care of the wallet upgrade issue from versions earlier that 1.4.0         
The developers require us to manually export private keys and then import them 
into a new wallet. This is an issue if you keep coins in the wallet. 
This script was built to scape all coins in this instances wallet, and transfer
them to a controller wallet, exchange, or other address. Basically, there 
should be no coins in this wallet. This allows us to simply transfer the coins 
out then delete the wallet.dat file.

We are better than that though. In case something went wrong we should create a
backup of the wallet.dat file, then delete the file.

Step 1: Scrape the coins if they exist\"
sudo $ionScrape

echo \"
Setp 2: Create a backup of the wallet.dat file\"
mkdir -pv ${varBackupDirectory}
sudo cp -v ${varIonConfigDirectory}wallet.dat ${varBackupDirectory}wallet_backup_\$(date +%Y%m%d_%H%M%S).dat

echo \"
Step 3: If we are not running, or we are running a version less than version then we get rid of the wallet.dat file.\"
myVersion=\"\$(sudo ${varIonBinaries}ion-cli getinfo | jq -r '.version')\"
echo \"Current Version returned: \\\"\$myVersion\\\"\"

if [ \"\$myVersion\" = \"\" ] ; then
    echo \"Because ion is not running or not installed we do not know the version. We are going to backup the file anyways\"
    sudo ${ionStop}
    mv -v ${varIonConfigDirectory}wallet.dat ${varIonConfigDirectory}wallet_backup_Version_unknown_\$(date +%Y%m%d_%H%M%S).dat
else
    if [ \"\$myVersion\" -ge 1040000 ];then
        echo \"Our version is greater than or equal to version 1.4.0, backing up the wallet.dat file, but keeping the exising wallet in place\"
		cp -v ${varIonConfigDirectory}wallet.dat ${varIonConfigDirectory}wallet_backup_Version_\${myVersion}_\$(date +%Y%m%d_%H%M%S).dat
    else
        echo \"Our version is less than 1.4.0, stop ion and move the wallet file\"
		sudo ${ionStop}
		mv -v ${varIonConfigDirectory}wallet.dat ${varIonConfigDirectory}wallet_backup_Version_\${myVersion}_\$(date +%Y%m%d_%H%M%S).dat
    fi
fi
sleep 1
echo \"\$(date +%F_%T) ionPre_1_4_0_Fix Finished\"
echo \"---------------------------------\"
#end of generated file" >> ionPre_1_4_0_Fix.sh
echo "Changing the file attributes so we can run the script"
chmod +x ionPre_1_4_0_Fix.sh
echo "Created ionPre_1_4_0_Fix.sh"
ionPre_1_4_0_Fix="${varScriptsDirectory}ionPre_1_4_0_Fix.sh"
echo "--"




### Script #6: Watchdog, Checks to see if the process is running and restarts it if it is not. ###
# Filename ionWatchdog.sh
cd $varScriptsDirectory
echo "Creating The Stop iond Script: ionWatchdog.sh"
echo '#!/bin/sh' > ionWatchdog.sh
echo "# This file, ionWatchdog.sh, was generated. $(date +%F_%T) Version: $varVersion" >> ionWatchdog.sh
echo "# This script checks to see if iond is running. If it is not, then it will be restarted. " >> ionWatchdog.sh
echo "PID=\`ps -eaf | grep iond | grep -v grep | awk '{print \$2}'\`" >> ionWatchdog.sh
echo "if [ \"\" =  \"\$PID\" ]; then" >> ionWatchdog.sh
echo "    if [ -e ${varIonBinaries}ion-cli ]; then"  >> ionWatchdog.sh
echo "        echo \"\$(date +%F_%T) STOPPED: Wait 2 minutes. We could be in an auto-update or other momentary restart.\""  >> ionWatchdog.sh
echo "        sleep 120" >> ionWatchdog.sh
echo "        PID=\`ps -eaf | grep iond | grep -v grep | awk '{print \$2}'\`" >> ionWatchdog.sh
echo "        if [ \"\" =  \"\$PID\" ]; then" >> ionWatchdog.sh
echo "            echo \"\$(date +%F_%T) Starting: Attempting to start the ion daemon \""  >> ionWatchdog.sh
echo "            sudo ${ionStart}" >> ionWatchdog.sh
echo "            echo \"\$(date +%F_%T) Starting: Attempt complete. We will see if it worked the next watchdog round. \""  >> ionWatchdog.sh
echo "            myVultrStatusInfo=\"Starting ...\""  >> ionWatchdog.sh
echo "        else"  >> ionWatchdog.sh
echo "            echo \"\$(date +%F_%T) Running: Must have been some reason it was down. \""  >> ionWatchdog.sh
echo "            myVultrStatusInfo=\"Running ...\""  >> ionWatchdog.sh
echo "        fi"  >> ionWatchdog.sh
echo "    else"  >> ionWatchdog.sh
echo "        echo \"\$(date +%F_%T) Error the file ${varIonBinaries}ion-cli does not exist! \""  >> ionWatchdog.sh
echo "        myVultrStatusInfo=\"Error: ion-cli does not exist!\""  >> ionWatchdog.sh
echo "    fi"  >> ionWatchdog.sh
echo "else"  >> ionWatchdog.sh
echo "    myBlockCount=\$(sudo ${varIonBinaries}ion-cli getblockcount)"  >> ionWatchdog.sh
echo "    myHashesPerSec=\$(sudo ${varIonBinaries}ion-cli gethashespersec)"  >> ionWatchdog.sh
#echo "    myNetworkDifficulty=\$(sudo ${varIonBinaries}ion-cli getdifficulty)"  >> ionWatchdog.sh
echo "    myNetworkHPS=\$(sudo ${varIonBinaries}ion-cli getnetworkhashps)"  >> ionWatchdog.sh
echo "    myVultrStatusInfo=\"\${myHashesPerSec} hps\""  >> ionWatchdog.sh
echo "    echo \"\$(date +%F_%T) Running: Block Count: \$myBlockCount Hash Rate: \$myHashesPerSec Network HPS \$myNetworkHPS \""  >> ionWatchdog.sh
echo "fi" >> ionWatchdog.sh

if [ "" = "$varVultrAPIKey" ]; then
    echo "No Vultr API Key, skipping Vultr specific label updater"
else

    myCommand="mySUBID=\$(curl -s -H 'API-Key: ${varVultrAPIKey}' https://api.vultr.com/v1/server/list?main_ip=$(hostname -I) | jq -r '.[].SUBID')"
    echo $myCommand
	eval $myCommand
	if [ "$mySUBID" = "" ]; then
		#if you are starting a lot of servers at once, you could have flooded the API, set a random delay and try again once.
		sleep $(shuf -i 1-60 -n 1)
		echo "Second attempt to get the SUBID"
		eval $myCommand
	fi
		
	echo "Vultr SUBID=${mySUBID}" 
    echo "mySUBIDStr=\"'SUBID=${mySUBID}'\""  >> ionWatchdog.sh

	if [ "$varVultrLabelmHz" = true ]; then
		echo "myMHz=\"| \$(cat /proc/cpuinfo |grep -m 1 \"cpu MHz\"|cut -d' ' -f 3-) MHz \""  >> ionWatchdog.sh
    fi
	
	if [ "$varIonode" = 1 ]; then
	    echo "myMNStatus=\$(sudo ${varIonBinaries}ion-cli ionode debug)"  >> ionWatchdog.sh
		echo "myLabel=\"'label=IONODE ${varIonodeLabel} | \$(date \"+%F %T\") | v${varVersionNumber} \${myMHz}| \${myVultrStatusInfo} | \${myMNStatus} '\""  >> ionWatchdog.sh
	else
		echo "myLabel=\"'label=\$(date \"+%F %T\") | v${varVersionNumber} \${myMHz}| \${myVultrStatusInfo} '\""  >> ionWatchdog.sh
	fi
	
    echo "#due to API rate limiting lets go at a random time in the next 3 min."  >> ionWatchdog.sh
    echo "sleep \$(shuf -i 1-180 -n 1)"  >> ionWatchdog.sh
    echo "myCommand=\"curl -s -H 'API-Key: ${varVultrAPIKey}' https://api.vultr.com/v1/server/label_set --data \${mySUBIDStr} --data \${myLabel}\""  >> ionWatchdog.sh
	
	if [ "$mySUBID" = "" ]; then
	    echo "#We did not find the SUBID, so we are not going to execute the API command to update the Vultr hosted label." >> ionWatchdog.sh
		echo "#You can get it by running this command: mySUBID=\$(curl -H 'API-Key: ${varVultrAPIKey}' https://api.vultr.com/v1/server/list?main_ip=\$(hostname -I) | jq -r '.[].SUBID')" >> ionWatchdog.sh
		echo "#eval \$myCommand" >> ionWatchdog.sh
	else
		echo "eval \$myCommand" >> ionWatchdog.sh
	fi
	
fi




echo "# End of generated Script" >> ionWatchdog.sh
echo "Changing the file attributes so we can run the script"
chmod +x ionWatchdog.sh
echo "Created ionWatchdog.sh"
ionWatchdog="${varScriptsDirectory}ionWatchdog.sh"
echo "--"


### Script #7: Vultr Label Update ###
# Filename vultr.sh
# This file will be deprecated a version or two past where the network no longer connects to versions below 1.4.0
cd $varScriptsDirectory
echo "Creating The Stop iond Script: vultr.sh"
echo '#!/bin/sh' > vultr.sh
echo "# This file, vultr.sh, was generated. $(date +%F_%T) Version: $varVersion" >> vultr.sh
echo "# This file Updates the Vultr Label using the Vultr API-Key" >> vultr.sh
echo "" >> vultr.sh
echo "echo \"---------------------------------\"" >> vultr.sh
echo "mySUBID=\$(curl -H 'API-Key: ${varVultrAPIKey}' https://api.vultr.com/v1/server/list?main_ip=\$(hostname -I) | jq -r '.[].SUBID')" >> vultr.sh
echo "mySUBIDStr=\"'SUBID=\${mySUBID}'\"" >> vultr.sh

if [ "$varVultrLabelmHz" = true ]; then
    echo "myMHz=\$(cat /proc/cpuinfo |grep -m 1 \"cpu MHz\"|cut -d' ' -f 3-)" >> vultr.sh
    echo "myMHz=\"| \${myMHz} MHz \"" >> vultr.sh
fi

if [ "$varIonode" = 1 ]; then
	echo "myLabel=\"'label=IONODE ${varIonodeLabel} | v${varVersionNumber} | Setting Up... \${myMHz}'\"" >> vultr.sh
else
	echo "myLabel=\"'label=v${varVersionNumber} | Setting Up... \${myMHz}'\"" >> vultr.sh
fi


echo "myCommand=\"curl -H 'API-Key: ${varVultrAPIKey}' https://api.vultr.com/v1/server/label_set --data \${mySUBIDStr} --data \${myLabel}\"" >> vultr.sh
echo "eval \$myCommand" >> vultr.sh
echo "echo \"---------------------------------\"" >> vultr.sh
echo "#end of generated file" >> vultr.sh

echo "Changing the file attributes so we can run the script"
chmod +x vultr.sh
echo "Created vultr.sh"
vultr="${varScriptsDirectory}vultr.sh"
echo "--"


if [ "" = "$varVultrAPIKey" ]; then
    echo "No Vultr API Key, skipping Vultr specific initial label"
else
    #due to API rate limiting lets go at a random time in the next 40 seconds.
	echo "Waiting a random period of time, no more than 40 seconds to prevent pegging the vultr API server"
    sleep $(shuf -i 1-40 -n 1)
    sudo ${vultr}
fi




echo "Done creating scripts"
echo "-------------------------------------------"




### Functions ###

funcCreateIonConfFile ()
{
 echo "---------------------------------"
 echo "- Creating the configuration file."
 echo "- Creating the ion.conf file, this replaces any existing file. "
 echo "Need to crate a random password and user name. Check current entropy"
 sudo cat /proc/sys/kernel/random/entropy_avail

 sleep 1
 Myrpcuser=$(sudo tr -d -c "a-zA-Z0-9" < /dev/urandom | sudo head -c 34)
 echo "Myrpcuser=$Myrpcuser"
 sleep 1
 Myrpcpassword=$(sudo tr -d -c "a-zA-Z0-9" < /dev/urandom | sudo head -c $(shuf -i 30-36 -n 1))
 echo "Myrpcpassword=$Myrpcpassword"
 Myrpcport=$(shuf -i 50000-65000 -n 1)
 Myport=$(shuf -i 1-500 -n 1)
 Myport=$((Myrpcport+Myport))
 
 mkdir -pv $varIonConfigDirectory
 echo "# This file was generated. $(date +%F_%T)  Version: $varVersion" > $varIonConfigFile
 echo "# Do not use special characters or spaces with username/password" >> $varIonConfigFile
 echo "rpcuser=$Myrpcuser" >> $varIonConfigFile
 echo "rpcpassword=$Myrpcpassword" >> $varIonConfigFile
 echo "rpcport=31350" >> $varIonConfigFile
 echo "port=31300" >> $varIonConfigFile
 echo "" >> $varIonConfigFile
 echo "# MINIMG:  These are your mining variables" >> $varIonConfigFile
 echo "# Gen can be 0 or 1. 1=mining, 0=No mining" >> $varIonConfigFile
 echo "gen=$varMining0ForNo1ForYes" >> $varIonConfigFile
 echo "# genproclimit sets the number of processors you want to use -1 for unbounded (all of them)" >> $varIonConfigFile
 echo "genproclimit=$varMiningProcessorLimit" >> $varIonConfigFile
 echo "" >> $varIonConfigFile

 if [ "$varIonode" = 1 ]; then
  echo "# IONODE: " >> $varIonConfigFile
  echo "externalip=$varIonodeExternalIP" >> $varIonConfigFile
  echo "ionode=$varIonode" >> $varIonConfigFile
  echo "ionodeprivkey=$varIonodePrivateKey" >> $varIonConfigFile
  echo "" >> $varIonConfigFile
 fi

 echo "# End of generated file" >> $varIonConfigFile
 echo "- Finished creating ion.conf"
 echo "---------------------------------"
 sleep 1
}


####### Security Lockdown Function #############
#Permanent lockdown and security of the node/miner. Not implementing before we work out the bugs. (don't want to lock us out from debugging it)
funcLockdown ()
{
    echo "---------------------------------"
    echo "-Permanent lockdown and security of the node and or miner."
 
    echo "-Remove SSH Access, Usually on Port 22. This will lock you out as well."
	#edit /etc/ssh/sshd_config to remove the line or change the line that says Port 22
	# it is suggested that you use a port between 49152 and 65535    MySSHport=$(shuf -i 49152-65535 -n 1)
	# note: To check is a port is in use netstat -an | grep “port”
	# Save the file and return to the console
    # At this point the sshd_config file has been changed, but the SSH service needs to be restarted in order for those changes to take effect.
    # sudo service ssh restart
    # When you connect back to your VPS via an SSH client, be sure to change the port to the one you specified in your sshd_config file. While you are more secure because you changed the port and you have a really secure password, an attacker can still find your port and attempt to break your password via a brute force attack. To prevent this you will need a firewall to limit the number of attempts per second, making a brute force attack impossibly long.
 
    # Install a Firewalledit
    # The Uncomplicated Firewall (UFW) is the default firewall configuration tool for Ubuntu.
    # 
    # The following commands can be used to install and setup your UFW to help protect your system.
    # 
    # sudo apt-get install ufw # this installs UFW
    # sudo ufw default deny # By default UFW will deny all connections. 
    # sudo ufw allow XXXXX/tcp # replace XXXXX with your SSH port chosen earlier
    # sudo ufw limit XXXXX/tcp # limits SSH connection attempts from an IP to 6 times in 30 seconds
    # sudo ufw allow YYYYY/tcp # replace YYYYY with your iond port (ion.conf file under port=#####)
    # sudo ufw allow ZZZZZ/tcp # replace ZZZZZ with your rpc port (ion.conf file under rpcport=#####)
    # sudo ufw logging on # this turns the log on, optional, but helps itentify attacks ans issues
    # sudo ufw enable # This will start the firewall, you only need to do this once after you install
    # 
    # You can verify that your firewall is running and the rules it has by using the following command
    # 
    # sudo ufw status
 
 #Lessons fromthe ncident Report on DDoS attack against Dash’s Masternode P2P network: https://www.dash.org/2017/03/08/DDoSReport.html
 # Suggested IP Table rules: https://gist.github.com/chaeplin/5dabcef736f599f3bc64bdce7b62b817
 
 
 

}
####### Security Lockdown Function #############



echo "Lets Scrape, if this is an upgrade, you may have mined coins."
sudo ${ionScrape}
echo "--"
echo "Fix for wallets below 1.4.0"
sudo ${ionPre_1_4_0_Fix}
echo "--"

## Quick Start Get Botstrap Data, recommended by the development team.
if [ "$varQuickBootstrap" = true ]; then
    echo "Starting Bootstrap and Blockchain download."
    echo "Step 1: If the iond process is running, Stop it"
    sudo ${ionStop}

    echo "Step 2: Backup wallet.dat files"
    #We are not backing up the full data directory contrary to the instructions. The reason is that this is most likely an automated situation and a backup will just waste space
    myBackupDirectory="${varBackupDirectory}Backup$(date +%Y%m%d_%H%M%S)/"
    mkdir -pv ${myBackupDirectory}backups/
    sudo cp -r ${varIonConfigDirectory}backups/* ${myBackupDirectory}backups/
    sudo cp -v ${varIonConfigDirectory}wallet.dat ${myBackupDirectory}
    sudo cp -v ${varIonConfigDirectory}ion.conf ${myBackupDirectory}
	sudo cp -v ${varIonConfigDirectory}dncache.dat ${myBackupDirectory}
    echo "Files backed up to ${myBackupDirectory}"

    echo "Step 3: Delete all data apart from your wallet.dat, conf files and backup folder."
    rm -fdr $varIonConfigDirectory
    #we make sure the directory is there for the script.
    mkdir -pv $varIonConfigDirectory

    echo "Step 4: Download the bootstrap.dat compressed file"

    mkdir -pv ${varUserDirectory}QuickStart
    cd ${varUserDirectory}QuickStart

    echo "Downloading blockchain bootstrap and extracting to data folder..."

    rm -fdr $varQuickStartCompressedBootstrapFileName
    mkdir -pv $varIonConfigDirectory
    echo "wget -o /dev/null $varQuickStartCompressedBootstrapLocation"
    wget -o /dev/null $varQuickStartCompressedBootstrapLocation

    if [ $? -eq 0 ]; then
        echo "Download succeeded, extract ..."
        if [ "$varQuickStartCompressedBootstrapFileIsZip" = true ]; then
            unzip -o $varQuickStartCompressedBootstrapFileName -d $varIonConfigDirectory
            echo "Extracted Zip file ( $varQuickStartCompressedBootstrapFileName ) to the config directory ( $varIonConfigDirectory )"
        else
            tar -xvf $varQuickStartCompressedBootstrapFileName -C $varIonConfigDirectory
            echo "Extracted TAR file ( $varQuickStartCompressedBootstrapFileName ) to the config directory ( $varIonConfigDirectory )"
        fi
    else
        echo "Download of bootstrap failed. setting varQuickBootstrap=false"
	    varQuickBootstrap=false
	    echo "because the bootstrap failed, we are going to resort to downloading the blockchain"
	    varQuickBlockchainDownload=true
    fi

    echo "Step 5: Start Ion and import from bootstrap.dat. Daemon users need to use the \"--loadblock=\" argument when starting Ion"
    echo "We will complete this step later on in the setup file, either on download of the binaries, or on completion of the compellation if you don't download the binaries"
    sleep 1
    echo "Bootstrap Prep completed!"
    echo ""
fi


## blockchain download (get blockchain from the web, not completely safe or reliable, but fast!)

## Quick Start (get blockchain from the web, not completely safe or reliable, but fast!)
## If you are bootstraping, you can still download the blockchain. While the developers recommend you only bootstrap, this will save time while syncing.
## 
if [ "$varQuickBlockchainDownload" = true ]; then
    echo "Blockchain Download"
    
	echo "Step 1: If the iond process is running, Stop it"
    sudo ${ionStop}

    echo "Step 2: Backup wallet.dat files"
    #We are not backing up the full data directory contrary to the instructions. The reason is that this is most likely an automated situation and a backup will just waste space
	sleep 2
    myBackupDirectory="${varBackupDirectory}Backup$(date +%Y%m%d_%H%M%S)/"
    mkdir -pv ${myBackupDirectory}backups/
    sudo cp -r ${varIonConfigDirectory}backups/* ${myBackupDirectory}backups/
    sudo cp -v ${varIonConfigDirectory}wallet.dat ${myBackupDirectory}
    sudo cp -v ${varIonConfigDirectory}ion.conf ${myBackupDirectory}
	sudo cp -v ${varIonConfigDirectory}dncache.dat ${myBackupDirectory}
    echo "Files backed up to ${myBackupDirectory}"

    echo "Step 3: Delete all data apart from your wallet.dat, conf files and backup folder."
    rm -fdr $varIonConfigDirectory
    #we make sure the directory is there for the script.
    mkdir -pv $varIonConfigDirectory

    echo "Step 4: Download the blockchain compressed file"

    mkdir -pv ${varUserDirectory}QuickStart
    cd ${varUserDirectory}QuickStart

    echo "Downloading blockchain bootstrap and extracting to data folder..."
    rm -fdr $varQuickStartCompressedBlockChainFileName
	echo "wget -o /dev/null $varQuickStartCompressedBlockChainLocation"
    wget -o /dev/null $varQuickStartCompressedBlockChainLocation
	
	if [ $? -eq 0 ]; then
	    echo "Download succeeded, extract ..."
        mkdir -pv $varIonConfigDirectory
        if [ "$varQuickStartCompressedBlockChainFileIsZip" = true ]; then
            unzip -o $varQuickStartCompressedBlockChainFileName -d $varIonConfigDirectory
            echo "Extracted Zip file ( $varQuickStartCompressedBlockChainFileName ) to the config directory ( $varIonConfigDirectory )"
        else
            tar -xvf $varQuickStartCompressedBlockChainFileName -C $varIonConfigDirectory
            echo "Extracted TAR file ( $varQuickStartCompressedBlockChainFileName ) to the config directory ( $varIonConfigDirectory )"
        fi
	else
	    echo "Blockchain Download Failed"
	    varQuickBlockchainDownload=false
	fi

    echo "Finished blockchain download and extraction"
    echo ""
fi

## Creating the config file. This prevents the boot up, have to shut down thing in iond. We do this here just in case the quickstart stuff deletes the config file.
echo ""
echo "Ok, now we are going to modify the ion.conf file so that when you boot up iond, you will be mining. No need to invoke ion-cli setgenerate true"
funcCreateIonConfFile
echo "Now that we have crated the ion.conf file, there is no need to do the boot up shut down thing with dyanmicd"
echo ""


## Quick Start (get binaries from the web, not completely safe or reliable, but fast!)
if [ "$varQuickStart" = true ]; then
echo "Beginning QuickStart Executable (binaries) download and start"

echo "If the iond process is running, this will kill it."
sudo ${ionStop}

mkdir -pv ${varUserDirectory}QuickStart
cd ${varUserDirectory}QuickStart
echo "Downloading and extracting Ion binaries"
rm -fdr $varQuickStartCompressedFileName
echo "wget -o /dev/null $varQuickStartCompressedFileLocation"
wget -o /dev/null $varQuickStartCompressedFileLocation
tar -xzf $varQuickStartCompressedFileName

echo "Copy QuickStart binaries"
mkdir -pv $varIonBinaries
sudo cp -v $varQuickStartCompressedFilePathForDaemon $varIonBinaries
sudo cp -v $varQuickStartCompressedFilePathForCLI $varIonBinaries
sudo cp -v $varQuickStartCompressedFilePathForDaemon /usr/local/bin
sudo cp -v $varQuickStartCompressedFilePathForCLI /usr/local/bin


echo "Launching daemon for the first time."
if [ "$varQuickBootstrap" = true ]; then
  echo "sudo ${varIonBinaries}iond --daemon --loadblock=${varIonConfigDirectory}bootstrap.dat"
  sudo ${varIonBinaries}iond --daemon --loadblock=${varIonConfigDirectory}bootstrap.dat 
else
  echo "sudo ${varIonBinaries}iond --daemon"
  sudo ${varIonBinaries}iond --daemon
fi

echo "The Daemon has started."

if [ $varQuickBlockchainDownload = true ] ; then
	# Downloading the blockchain is significantly faster. you will most likely be mining within 5 min. 
    echo "We have downloaded the blockchain and the binaries, let's give some time for the blockchain to load"
	echo "Out of all of the options, this is the fastest and actually has a chance of completing before compiling starts"
    echo "Sleeping for 15 min"
    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
    do
        sleep 60
        echo "$i out of 15 min completed"
    done
	echo "sudo ${varIonBinaries}ion-cli gethashespersec"
    sudo ${varIonBinaries}ion-cli gethashespersec
    echo "* note: hash rate may be 0 if the blockchain has not fully synced yet."
else
    echo "Waiting 60 seconds"
    sleep 60
fi


echo "Wait period over We are currently on Block:"
echo "sudo ${varIonBinaries}ion-cli getblockcount"
sudo ${varIonBinaries}ion-cli getblockcount
echo "A full sync can take many hours. Mining will automatically start once synced."
sleep 1

echo ""
echo "In case Compiling later on fails, we want to put all of our cron jobs in"
echo ""

## CREATE CRON JOBS ###
echo "Creating Boot Start and Scrape Cron jobs..."

startLine="@reboot sh $ionStart >> ${varScriptsDirectory}ionMineStart.log 2>&1"
scrapeLine="*/$varMiningScrapeTime * * * * $ionScrape >> ${varScriptsDirectory}ionScrape.log 2>&1"

(crontab -u root -l 2>/dev/null | grep -v -F "$ionStart"; echo "$startLine") | crontab -u root -
echo " cron job $ionStart is setup: $startLine"
(crontab -u root -l 2>/dev/null | grep -v -F "$ionScrape"; echo "$scrapeLine") | crontab -u root -
echo " cron job $ionScrape is setup: $scrapeLine"

if [ "$varWatchdogEnabled" = true ]; then
    watchdogLine="*/$varWatchdogTime * * * * $ionWatchdog >> ${varScriptsDirectory}ionWatchdog.log 2>&1"
    (crontab -u root -l 2>/dev/null | grep -v -F "$ionWatchdog"; echo "$watchdogLine") | crontab -u root -
	echo " cron job $ionWatchdog is setup: $watchdogLine"
fi

echo "Boot Start and Scrape cron jobs created"


echo "QuickStart complete"
fi
#End of QuickStart
echo ""
echo ""

# Compile the code
if [ "$varCompile" = true ]; then

    echo "######### Start Compile #########"
    echo ""
#Ok If you did a QuickStart, we are going to build a new wallet. 
#This will happen while you are mining, so it will take super long, but you don't care.
#when we complete the build we will stop the miner, replace the binary, and continue.  

# Install Dependencies and other tools
    echo "Install Dependencies and other tools"
    sudo apt-get -y install software-properties-common python-software-properties 
    sudo add-apt-repository -y ppa:git-core/ppa 
    sudo apt-get -y update 
    sudo apt-get -y install nano
    sudo apt-get -y install git
    sudo apt-get -y install git build-essential libtool autotools-dev autoconf pkg-config bsdmainutils libssl-dev libcrypto++-dev libevent-dev automake libminiupnpc-dev libgmp-dev libboost-all-dev
    sudo add-apt-repository -y ppa:bitcoin/bitcoin
    sudo apt-get -y update
    sudo add-apt-repository -y ppa:silknetwork/silknetwork
    sudo apt-get -y update
    sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
    sudo apt-get -y update
    sudo apt-get -y upgrade
    echo ""

	
# Clone the github repository
    echo "Clone the github repository"
    cd $varGITRootPath
    sudo git clone $varRemoteRepository
    echo "Pull changes from the github repository. If they update the code, this will bring your code up to date. "
    cd $varGITIonPath
    sudo git pull $varRemoteRepository
    
# Compile the Daemon Client


    echo "-------------------------------------------"
    echo "Compile the Daemon Client"
    cd $varGITIonPath
    echo "-----------------"
	echo "Check if we can optimize mining using the avx2 instruction set"
	varavx2=$(grep avx2 /proc/cpuinfo)
	if [  "varavx2" = "" ]; then
	  echo "avx2 not found, normal compile, no avx2 optimizations"
	  echo "Just creating the CLI and Deamon Only"
	  echo "sudo ./autogen.sh && sudo ./configure --without-gui && sudo make"
      sudo ./autogen.sh && sudo ./configure --without-gui && sudo make
	else
	  echo "avx2 found, avx2 optimizations enabled"
	  echo "Just creating the CLI and Deamon Only"
	  echo "CPPFLAGS=-march=native && echo \$CPPFLAGS && sudo ./autogen.sh && sudo ./configure --without-gui && sudo make"
      CPPFLAGS=-march=native && echo $CPPFLAGS && sudo ./autogen.sh && sudo ./configure --without-gui && sudo make
	fi
    echo "-----------------"
    echo "Compile Finished."
    echo "-------------------------------------------"

    
    echo "If the iond process is running, this will kill it."

    echo "Lets Scrape, if this is an upgrade, you may have mined coins."
    sudo ${ionScrape}
    echo "--"
    echo "Fix for wallets below 1.4.0"
    sudo ${ionPre_1_4_0_Fix}
    echo "--"

    sudo ${ionStop}

    echo "Copy compiled binaries, if you used QuickStart your binaries are being replaced by the compiled ones"
    mkdir -pv $varIonBinaries
    sudo cp -v ${varGITIonPath}src/iond $varIonBinaries
    sudo cp -v ${varGITIonPath}src/ion-cli $varIonBinaries
	sudo cp -v ${varGITIonPath}src/iond /usr/local/bin
    sudo cp -v ${varGITIonPath}src/ion-cli /usr/local/bin
	
    
    if [ "$varQuickBootstrap" = true ]; then
    
        if [ "$varQuickStart" = true ]; then
            echo "skipping the pre-launch because we already did it with the quickstart"
	        echo "sudo ${varIonBinaries}iond --daemon"
	        sudo ${varIonBinaries}iond --daemon
        else
            echo "Doing the bootstrap from step 4 here because we want to boot strap"
	        echo "sudo ${varIonBinaries}iond --daemon --loadblock=${varIonConfigDirectory}bootstrap.dat"
            sudo ${varIonBinaries}iond --daemon --loadblock=${varIonConfigDirectory}bootstrap.dat
        fi
    else
        echo "sudo ${varIonBinaries}iond --daemon"
        sudo ${varIonBinaries}iond --daemon
    fi

    echo "waiting 60 seconds"
    sleep 60

    echo "The Daemon has started. We are currently on Block:"
    echo "sudo ${varIonBinaries}ion-cli getblockcount"
    sudo ${varIonBinaries}ion-cli getblockcount
    echo "A full sync can take many hours. Mining will automatically start once synced."
    sleep 1

    echo "Ion Wallet created and blockchain should be syncing."
    
    
## CREATE CRON JOBS ###
    echo "-------------------------------------------"
    echo "Creating Boot Start and Scrape Cron jobs..."

    startLine="@reboot sh $ionStart >> ${varScriptsDirectory}ionMineStart.log 2>&1"
    scrapeLine="*/$varMiningScrapeTime * * * * $ionScrape >> ${varScriptsDirectory}ionScrape.log 2>&1"

    (crontab -u root -l 2>/dev/null | grep -v -F "$ionStart"; echo "$startLine") | crontab -u root -
    echo " cron job $ionStart is setup: $startLine"
    (crontab -u root -l 2>/dev/null | grep -v -F "$ionScrape"; echo "$scrapeLine") | crontab -u root -
    echo " cron job $ionScrape is setup: $scrapeLine"
    
    if [ "$varWatchdogEnabled" = true ]; then
        watchdogLine="*/$varWatchdogTime * * * * $ionWatchdog >> ${varScriptsDirectory}ionWatchdog.log 2>&1"
        (crontab -u root -l 2>/dev/null | grep -v -F "$ionWatchdog"; echo "$watchdogLine") | crontab -u root -
    	echo " cron job $ionWatchdog is setup: $watchdogLine"
    fi

    if [ "$varAutoUpdate" = true ]; then

        #we don't want eveyone updating at the same time, that would be bad for the network, so check for updates at a random time.
        AutoUpdaterLine="$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1) * * * $ionAutoUpdater >> ${varScriptsDirectory}ionAutoUpdater.log 2>&1"
        #this will check once a day, just at a random time of day from other runs of this script. 

        (crontab -u root -l 2>/dev/null | grep -v -F "$ionAutoUpdater"; echo "$AutoUpdaterLine") | crontab -u root -
        echo " cron job $ionAutoUpdater is setup: $AutoUpdaterLine"
        echo " Auto Update cron job has been set:"
        echo " Auto Update will run once a day and automatically compile and execute new code if there have been commits to the remote repository."
        echo " Remote Repository: $varRemoteRepository"
    else
        echo " Auto Update is set to false. We will not update if new code is updated in the repository: $varRemoteRepository"
    fi


    echo "Created cron jobs."
    echo "-------------------------------------------"
fi
	
echo "

===========================================================
All set! 
Helpful commands: 
\"ion-cli getmininginfo\" to check mining and # of blocks synced.
\"iond --daemon\" starts the daemon.
\"ion-cli stop\" stops the daemon. 
\"ion-cli setgenerate true -1\" to start mining.
\"ion-cli listaddressgroupings\" to see mined balances.
\"ion-cli getblockcount\" gets the current blockcount
\"ion-cli gethashespersec\" gets your current hash rate.
\"ion-cli help\" for a full list of commands.

You may need to navigate to ${varIonBinaries} before you can run the commands. 
This command will navigate to ${varIonBinaries} the directory
cd ${varIonBinaries}

Alternatively, you can put the path (directory) before the command

example: Getting the blockcount:
sudo ${varIonBinaries}ion-cli getblockcount"
sudo ${varIonBinaries}ion-cli getblockcount
echo "
example: Getting the hash rate:
sudo ${varIonBinaries}ion-cli gethashespersec"
sudo ${varIonBinaries}ion-cli gethashespersec
echo "* note: hash rate may be 0 if the blockchain has not fully synced yet.

===========================================================

Version: $varVersion
end of startup script
"
