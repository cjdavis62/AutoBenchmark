#!/bin/bash

#****************************************#
# benchmarkCheck.sh
# Written by Christopher Davis
# v2.0: 4Apr2016
#****************************************#

# Bash script
# Generates benchmarking simulation spectra and checks to see differences with prior benchmarked spectra

# General Procedure:
# 1. scp old spectra to local machine
# 2. run simulations with new version
# 3. run checks between spectra
# 4. look for spectra differences (output warnings?)

# usage information
#. benchmark.sh -q /path/to/qshields -g /path/to/g4cuore


####################### Prep to Run programs #########################

clear
#echo "What is the name of your qshields application in your PATH? e.g. qshields-t15.11.b01"
#read QSHIELDS_APP

#echo "What is the name of your g4cuore application in your PATH? e.g. g4cuore-t15.11.b01"
#read G4CUORE_APP

HELP_INFORMATION="This script generates benchmarking simulation spectra and checks to see differences with prior benchmarked spectra\n
General Procedure:\n
    \t1. scp old spectra to local machine\n
    \t2. run simulations with new version\n
    \t3. run checks between spectra\n
    \t4. look for spectra differences\n
Steps 3 and 4 are performed in benchmarkCheck_root.py which is called at the end of this script\n
 usage information: -u\n
\t    . benchmark.sh -q /path/to/qshields -g /path/to/g4cuore\n
use the -h option or --help to display this information again\n
" 

USAGE_INFORMATION="usage:
./benchmark.sh -q /path/to/qshields -g /path/to/g4cuore"

QSHIELDS_APP=""
G4CUORE_APP=""

#while getopts ":q:g:h" opt; do
while getopts ":g:q:h" opt; do
    case $opt in
    q)
	    QSHIELDS_APP=$OPTARG
	    ;;

    g)
	    G4CUORE_APP=$OPTARG
	    ;;

    h)
	    echo -e $HELP_INFORMATION
	    exit
	    ;;

    u)
	    echo -e $USAGE_INFORMATION
	    exit
	    ;;

    \?)
	    echo "Didn't understand all the arguments..."
	    echo "Printing help information...."
	    echo -e $HELP_INFORMATION
	    exit 1
	    ;;
    :)
	    echo "Need to pass arguments to the script"
	    echo -e $HELP_INFORMATION
	    exit 1
	    ;;
    
    esac
done

# Check to make QSHIELDS_APP and G4CUORE_APP defined by arguments
if [ -z "$QSHIELDS_APP" ]; then
#if [ $QSHIELDS_APP -eq "" ] || [ $G4CUORE_APP -eq "" ]; then
    echo -e $USAGE_INFORMATION
    exit 2
fi

if [ -z "$G4CUORE_APP" ]; then
    echo -e $USAGE_INFORMATION
    exit 2
fi

# Tell the user what they put in
echo "Using qshields located at: $QSHIELDS_APP"
echo "Using g4cuore located at: $G4CUORE_APP"
	    

echo "********************"
echo "WARNING"
echo "********************"
echo "1. Program assumes no changes to the volume names between versions"
echo "If you changed the names of the volumes, you will need to edit the source code"
echo "2. Make sure you don't have anything else running in the background, as this script uses the bash 'wait' command"
# to fix this, look for lines that contain $QSHIELDS_APP and make necessary adjustments

# make directories to place files in
echo "Now generating directories to place output files"
WorkDirectory=BenchmarkTestFiles
if ! [ -d $WorkDirectory ]; then
    mkdir $WorkDirectory
fi

# log files go here
LogDirectory=$WorkDirectory/log
if ! [ -d $LogDirectory ]; then
    mkdir $LogDirectory
fi

# spectra go here
SpectraDirectory=$WorkDirectory/spectra
if ! [ -d $SpectraDirectory ]; then
    mkdir $SpectraDirectory
fi

# ratios of generated events go under spectra directory
GeneratedEventsFile=$SpectraDirectory/EventRatios.txt

#g4cuore data go here
NTPDirectory=$WorkDirectory/NTP
if ! [ -d $NTPDirectory ]; then
    mkdir $NTPDirectory
fi

echo "spectra will be located in $SpectraDirectory"
echo "g4cuore outputs will be located in $NTPDirectory"

#### scp old spectra to machine
ROMA_DIRECTORY=$WorkDirectory/Old_BenchmarkData
echo "Checking for benchmarking files in $ROMA_DIRECTORY..."
if [ -d "$ROMA_DIRECTORY" ]; then
    echo "files already here, great!"
else
    echo "files not found..."
    echo "loading old spectra to machine"
    echo "What is your ROMA cluster username?"
    read ROMA_USERNAME 
    scp -r $ROMA_USERNAME@farm-login.roma1.infn.it:/cuore/data/simulation/CUORE/v_9.6/benchmark/t15.11.b01/ntp/ $ROMA_DIRECTORY
fi

# Decay Chain files
TH232=$WorkDirectory/DecayChains/th232_all
PB210=$WorkDirectory/DecayChains/pb210-pb206
U238=$WorkDirectory/DecayChains/u238_all

# The root script that will run over the output files and run checks
ROOTSCRIPT=benchmarkCheck_root.py

echo "Okay we will now run qshields on the benchmarking simulations"


##### Set Number of Events to Run ####################

# Number of events to be generated
PbREvents=1000
PbRLoops=10000
CuFrameSxEvents=5000000
PTFESxEvents=10000000
TeO2SxEvents=5000
TeO2SxLoops=1000
TeO2Events=5000000
_10mKEvents=5000000

# Events in standard simulation
PbREvents_standard=100000
PbRLoops_standard=10000
CuFrameSxEvents_standard=10000000
PTFESxEvents_standard=10000000
TeO2SxEvents_standard=10000
TeO2SxLoops_standard=1000
TeO2Events_standard=10000000
_10mKEvents_standard=50000000


# Ratio of Events generated automatically to standard events #
PbR_Ratio=$(((PbREvents_standard * PbRLoops_standard) / (PbREvents * PbRLoops))) 
CuFrameSx_Ratio=$(((CuFrameSxEvents_standard) / CuFrameSxEvents))
PTFESx_Ratio=$(((PTFESxEvents_standard) / PTFESxEvents))
TeO2Sx_Ratio=$(((TeO2SxEvents_standard * TeO2SxLoops_standard) / (TeO2SxEvents * TeO2SxLoops)))
TeO2_Ratio=$(((TeO2Events_standard) / TeO2Events))
_10mK_Ratio=$(((_10mKEvents_standard) / _10mKEvents))

# testing
echo $PbR_Ratio
echo $CuFrameSx_Ratio
echo $PTFESx_Ratio
echo $TeO2Sx_Ratio
echo $TeO2_Ratio
echo $_10mK_Ratio


echo -e "PbR: \t $PbR_Ratio" > $GeneratedEventsFile
echo -e "CuFrameSx: \t $CuFrameSx_Ratio" >> $GeneratedEventsFile
echo -e "PTFESx: \t $PTFESx_Ratio" >> $GeneratedEventsFile
echo -e "TeO2Sx: \t $TeO2Sx_Ratio" >> $GeneratedEventsFile
echo -e "TeO2: \t $TeO2_Ratio" >> $GeneratedEventsFile
echo -e "10mK: \t $_10mK_Ratio" >> $GeneratedEventsFile


########## Start Running Simulations ##################
StartTime=$(date -u +%s)
echo "starting at time: $StartTime"

# PbR-th232
echo "PbR-th232 MC"
$QSHIELDS_APP -U13 -G $TH232 -M$PbRLoops -N$PbREvents -or$SpectraDirectory/PbR_th232_Test.root > $LogDirectory/PbR_th232.log & 

# CuFrameSx-th232
echo "CuFrameSx-th232 MC"
$QSHIELDS_APP -X\(38,0,+0.0005\) -G $TH232 -N$CuFrameSxEvents -or$SpectraDirectory/CuFrameSx_th232_Test.root > $LogDirectory/CuFrameSx_th232.log &

# PTFESx-th232
echo "PTFESx-th232"
$QSHIELDS_APP -X\(42,0,+0.0005\) -G $TH232 -N$PTFESxEvents -or$SpectraDirectory/PTFESx_th232_Test.root > $LogDirectory/PTFESx_th232.log &

#/cmn/cuore/geant4/tag/t15.11.b01/bin/9.6.p03/qshields-t15.11.b01 -X\(42,0,+0.0005\) -G $TH232 -N$PTFESxEvents -or$SpectraDirectory/PTFESx_th232_Test.root > $LogDirectory/PTFESx_th232.log &

# TeO2Sx-pb210
echo "TeO2Sx-pb210"
$QSHIELDS_APP -X\(37,0,+0.0001\) -G $PB210 -M$TeO2SxLoops -N$TeO2SxEvents -or$SpectraDirectory/TeO2Sx_pb210_Test.root > $LogDirectory/TeO2Sx_pb210.log &

# TeO2-u238
echo "TeO2-u238"
$QSHIELDS_APP -U37 -G $U238 -N$TeO2Events -or$SpectraDirectory/TeO2_u238_Test.root > $LogDirectory/TeO2_u238.log &

# 10mK-u238
$QSHIELDS_APP -U18 -G $U238 -N$_10mKEvents -or$SpectraDirectory/10mK_u238_Test.root > $LogDirectory/10mK_u238.log &

echo "Waiting for simulation jobs to complete..."
echo "Warning! Make sure no other bash commands are running in the background."
echo "This script waits for all other background scripts to finish to continue..."
wait
echo "Done waiting! Continuing..."

FinishTime=$(date -u +%s)
echo "Done at time: $FinishTime"
echo "Time Elapsed: $(($FinishTime - $StartTime))"

##### Run g4cuore############################################

echo "Running g4cuore now"

rateValue=0.0001
integrationTime=0.005


# PbR-th232
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/PbR_th232_Test_g4cuore.root -ir$SpectraDirectory/PbR_th232_Test.root
# CuFrameSx-th233
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/CuFrameSx_th232_Test_g4cuore.root -ir$SpectraDirectory/CuFrameSx_th232_Test.root
# PTFESx-th232
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/PTFESx_th232_Test_g4cuore.root -ir$SpectraDirectory/PTFESx_th232_Test.root
# TeO2Sx-pb210
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/TeO2Sx_pb210_Test_g4cuore.root -ir$SpectraDirectory/TeO2Sx_pb210_Test.root
# TeO2-u238
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/TeO2_u238_Test_g4cuore.root -ir$SpectraDirectory/TeO2_u238_Test.root
# 10mK-u238
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/10mK_u238_Test_g4cuore.root -ir$SpectraDirectory/10mK_u238_Test.root

echo "Done with generating spectra"


#### make comparisons

# run root file to generate plots and determine differences

python $ROOTSCRIPT
