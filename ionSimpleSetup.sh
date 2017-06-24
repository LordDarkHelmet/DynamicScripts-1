#!/bin/sh

# Summary:
# This script makes setting up Ion (ION) miners and remote ionodes easy!
# It will download the latest startup script which can:
#  * Download and run the executables
#  * Download the Bootstrap
#  * Download the Blockchain
#  * Auto Scrapes
#  * Auto Updates
#  * Watchdog to keep the mining going just in case of a crash
#  * Startup on reboot
#  * Can create miners
#  * Can create remote ionodes
#  and more... See https://github.com/cevap/IonScripts for the latest.
#
# You can run this as one command on the command line
# wget -N https://github.com/cevap/IonScripts/releases/download/v1.0.0/ionSimpleSetup.sh && sh ionSimpleSetup.sh -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD
#
echo "===========================================================================" | tee -a ionSimpleSetup.log
echo "Version 1.0.5 of ionSimpleSetup.sh" | tee -a ionSimpleSetup.log
echo " Released May 4, 2017 Released by LordDarkHelmet" | tee -a ionSimpleSetup.log
echo "Original Version found at: https://github.com/cevap/IonScripts" | tee -a ionSimpleSetup.log
echo "Local Filename: $0" | tee -a ionSimpleSetup.log
echo "Local Time: $(date +%F_%T)" | tee -a ionSimpleSetup.log
echo "System:" | tee -a ionSimpleSetup.log
uname -a | tee -a ionSimpleSetup.log
echo "User $(id -u -n)  UserID: $(id -u)" | tee -a ionSimpleSetup.log
echo "If you found this script useful please contribute. Feedback is appreciated" | tee -a ionSimpleSetup.log
echo "===========================================================================" | tee -a ionSimpleSetup.log
varIsScrapeAddressSet=false
varShowHelp=false
while getopts :s:h option
do
	case "${option}" in
		h)
			varShowHelp=true
			#We are setting this to true because we are going to show help. No need to worry about scraping
			varIsScrapeAddressSet=true
			echo "We are going to show the most recent help info." | tee -a ionSimpleSetup.log
			echo "In order to do this we will still need to download the latest version from GIT." | tee -a ionSimpleSetup.log
			;;
		s)
			myScrapeAddress=${OPTARG}
			echo "-s has set myScrapeAddress=${myScrapeAddress}" | tee -a ionSimpleSetup.log
			varIsScrapeAddressSet=true
			;;
	esac
done

if [ "$varIsScrapeAddressSet" = false ]; then
	echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a ionSimpleSetup.log
	echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a ionSimpleSetup.log
	echo "SCRAPE ADDRESS HAS NOT BEEN SET!!! You will be donating your HASH power." | tee -a ionSimpleSetup.log
	echo "If you did not intend to do this then please use the -a attribute and set your scrape address!" | tee -a ionSimpleSetup.log
	echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a ionSimpleSetup.log
	echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a ionSimpleSetup.log
fi

echo "" | tee -a ionSimpleSetup.log
echo "" | tee -a ionSimpleSetup.log
echo "Step 1: Download the latest ionStartupScript.sh from GitHub, https://github.com/cevap/IonScripts" | tee -a ionSimpleSetup.log
echo "- To download from GitHub we need to install GIT" | tee -a ionSimpleSetup.log
sudo apt-get -y install git | tee -a ionSimpleSetup.log
echo "- we also use the \"at\" command we should install that too. " | tee -a ionSimpleSetup.log
sudo apt-get -y install at | tee -a ionSimpleSetup.log
echo "- Clone the repository" | tee -a ionSimpleSetup.log
sudo git clone https://github.com/cevap/IonScripts | tee -a ionSimpleSetup.log
echo "- Navigate to the script" | tee -a ionSimpleSetup.log
cd IonScripts
echo "- Just in case we previously ran this script, pull the latest from GitHub" | tee -a ../ionSimpleSetup.log
sudo git pull https://github.com/cevap/IonScripts | tee -a ../ionSimpleSetup.log
echo "" | tee -a ionSimpleSetup.log
echo "Step 2: Set permissions so that ionStartupScript.sh can run" | tee -a ../ionSimpleSetup.log
echo "- Change the permissions" | tee -a ../ionSimpleSetup.log
chmod +x ionStartupScript.sh | tee -a ../ionSimpleSetup.log
echo "" | tee -a ../ionSimpleSetup.log
echo "Step 3: Run the script." | tee -a ../ionSimpleSetup.log

if [ "$varShowHelp" = true ]; then
	echo "./ionStartupScript.sh -h" | tee -a ../ionSimpleSetup.log
	./ionStartupScript.sh -h  | tee -a ../ionSimpleSetup.log
else
	varLogFilename="ionStartupScript$(date +%Y%m%d_%H%M%S).log"
	#Due to the fact that some VPN servers have not enabled RemainAfterExit=yes", which if neglected, causes systemd to terminate all spawned processes from the imageboot unit, we need to schedule the script to run.
	#echo "sudo setsid ./ionStartupScript.sh $@ 1> $varLogFilename 2>&1 < /dev/null &"
	#sudo setsid ./ionStartupScript.sh $@ 1> $varLogFilename 2>&1 < /dev/null &
	#PID=`ps -eaf | grep ionStartupScript.sh | grep -v grep | awk '{print \$2}'`
	#echo "The script is now running in the background. PID=${PID}" | tee -a ../ionSimpleSetup.log
	#Because of that flaw, we are going to use the at command to schedule the process
	echo "" | tee -a ../ionSimpleSetup.log
	echo "$(date +%F_%T) Scheduling the script to run 2 min from now. We do this instead of nohup or setsid because some VPSs terminate " | tee -a ../ionSimpleSetup.log
	echo "We will execute the following command in 2 min:  ./ionStartupScript.sh $@ 1> $varLogFilename 2>&1 < /dev/null &" | tee -a ../ionSimpleSetup.log
	echo "./ionStartupScript.sh $@ 1> $varLogFilename 2>&1 < /dev/null &" | at now + 2 minutes  | tee -a ../ionSimpleSetup.log
	echo "" | tee -a ../ionSimpleSetup.log
	echo "If you want to follow its progress (once it starts in 2 min) then use the following command:" | tee -a ../ionSimpleSetup.log
	echo "" | tee -a ../ionSimpleSetup.log
	echo "tail -f ${PWD}/${varLogFilename}" | tee -a ../ionSimpleSetup.log
	echo "" | tee -a ../ionSimpleSetup.log
fi
