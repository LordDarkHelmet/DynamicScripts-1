# IonScripts
<b>Scripts for the Ion (ION) Cryptocurrency</b>

You can now setup a ion miner with one line! Example: (<i>be sure to replace the address with your scrape address</i>)

<code>wget -N https://github.com/cevap/IonScripts/releases/download/v1.0.0/ionSimpleSetup.sh && sudo sh ionSimpleSetup.sh -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD</code>

The above line will download the latest startup script which can: 
 * Create miners
 * Create remote ionodes
 * Auto Scrapes
 * Auto Updates
 * Watchdog to keep the mining going just in case of a crash
 * Startup on reboot
 * Download and run the executables
 * Download the Bootstrap
 * Download the Blockchain
 * and more...
 
 You can also setup ionodes with one line. Use the -h command to see the full list of capabilietes and options, Examples are provided.  
 
 <code>wget -N https://github.com/cevap/IonScripts/releases/download/v1.0.0/ionSimpleSetup.sh && sudo sh ionSimpleSetup.sh -h</code>
 

This is a collection of scripts that will assist users in setting up and managing instances of the ion wallet.

<b>ionSimpleSetup.sh</b>
This script is used in conjunction with the ionStartupScript.sh script. It is a non, or rarely changing script that will pull the latest ionStartupScript.sh script and run it. This allows us to have a static location for a release script so we can use one line startup commands while always running the latest script. 

<b>ionStartupScript.sh:</b>
This script is a one stop shop. Run it on your VPS and it will do everything hands off. It will mine for you, it will scrape for you, it will auto update when new versions come out, it can even setup a ionode for you. Simple and easy. If you set it as a startup script, you will never need to log into your VPS.


Ion (ION) is a cryptocurrency. You can find out more at:
https://ion.duality.solutions/
