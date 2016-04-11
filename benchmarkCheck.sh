#!/bin/bash

#****************************************#
# benchmarkCheck.sh                      #
# Written by Christopher Davis           #
# v2.1: 6Apr2016                         #
# christopher.davis@yale.edu             #
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

echo "****************************************"
echo "****** Starting Benchmarking Tool ******"
echo "****************************************"

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
	    



echo "********** Warning **********"
echo "1. Program assumes no changes to the volume names between versions"
echo -e "\t If you changed the names of the volumes, you will need to edit the source code"
echo "2. Make sure you don't have anything else running in the background, as this script uses the bash 'wait' command"
echo "*****************************"
# make directories to place files in
echo "Now generating directories to place output files..."
WORK_DIRECTORY=BenchmarkTestFiles
if ! [ -d $WORK_DIRECTORY ]; then
    mkdir $WORK_DIRECTORY
fi

# log files go here
LOG_DIRECTORY=$WORK_DIRECTORY/log
if ! [ -d $LOG_DIRECTORY ]; then
    mkdir $LOG_DIRECTORY
fi

# spectra go here
SPECTRA_DIRECTORY=$WORK_DIRECTORY/spectra
if ! [ -d $SPECTRA_DIRECTORY ]; then
    mkdir $SPECTRA_DIRECTORY
fi

# ratios of generated events go under spectra directory
GeneratedEventsFile=$SPECTRA_DIRECTORY/EventRatios.txt

#g4cuore data go here
NTP_DIRECTORY=$WORK_DIRECTORY/NTP
if ! [ -d $NTP_DIRECTORY ]; then
    mkdir $NTP_DIRECTORY
fi


echo -e "\t Spectra will be located in $SPECTRA_DIRECTORY"
echo -e "\t g4cuore outputs will be located in $NTP_DIRECTORY"

#### scp old spectra to machine
ROMA_DIRECTORY=$WORK_DIRECTORY/Old_BenchmarkData
DECAY_DIRECTORY=$WORK_DIRECTORY/DecayChains
echo "Checking for necessary benchmarking files in $ROMA_DIRECTORY and $DECAY_DIRECTORY..."
if [ -d "$ROMA_DIRECTORY" ] && [ -d "$DECAY_DIRECTORY" ]; then
    echo "files already here, great!"
else
    echo "Required benchmarking files not found..."
    echo "Loading old spectra and decay chains to machine"
    echo "What is your ROMA cluster username?"
    echo "**** User input required ****"
    read ROMA_USERNAME
    echo "Thanks! Downloading files now..."
    echo "Please input your password at the prompt"
    echo "**** User input required ****"
    scp -r $ROMA_USERNAME@farm-login.roma1.infn.it:/cuore/data/simulation/CUORE/v_9.6/benchmark/benchmark_auto_files/Auto_Benchmark_Files.tar $WORK_DIRECTORY/.
    echo "Files downloaded. Unpacking..."
    tar -xf $WORK_DIRECTORY/Auto_Benchmark_Files.tar -C $WORK_DIRECTORY/.
fi

# Decay Chain files
TH232=$DECAY_DIRECTORY/th232_all
PB210=$DECAY_DIRECTORY/pb210-pb206
U238=$DECAY_DIRECTORY/u238_all

# The root script that will run over the output files and run checks
ROOTSCRIPT=benchmarkCheck_root.py

echo "All set to run benchmarking simulations!"
echo "Now running qshields on the benchmarking simulations"

##### Set Number of Events to Run ####################

# Number of events to be generated
PbREvents=1500
PbRLoops=10000
CuFrameSxEvents=5000000
PTFESxEvents=5000000
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

echo -e "PbR: \t $PbR_Ratio" > $GeneratedEventsFile
echo -e "CuFrameSx: \t $CuFrameSx_Ratio" >> $GeneratedEventsFile
echo -e "PTFESx: \t $PTFESx_Ratio" >> $GeneratedEventsFile
echo -e "TeO2Sx: \t $TeO2Sx_Ratio" >> $GeneratedEventsFile
echo -e "TeO2: \t $TeO2_Ratio" >> $GeneratedEventsFile
echo -e "10mK: \t $_10mK_Ratio" >> $GeneratedEventsFile


########## Start Running Simulations ##################
StartTime=$(date -u +%s)
StartTime_Readable=$(date)
echo "starting at time: $StartTime_Readable"

# PbR-th232
echo "PbR-th232 MC starting"
$QSHIELDS_APP -U13 -G $TH232 -M$PbRLoops -N$PbREvents -or$SPECTRA_DIRECTORY/PbR_th232.root &> $LOG_DIRECTORY/PbR_th232.log -i 1 & 

# CuFrameSx-th232
echo "CuFrameSx-th232 MC starting"
$QSHIELDS_APP -X\(38,0,+0.0005\) -G $TH232 -N$CuFrameSxEvents -or$SPECTRA_DIRECTORY/CuFrameSx_th232.root &> $LOG_DIRECTORY/CuFrameSx_th232.log &

# PTFESx-th232
echo "PTFESx-th232 MC starting"
$QSHIELDS_APP -X\(42,0,+0.0005\) -G $TH232 -N$PTFESxEvents -or$SPECTRA_DIRECTORY/PTFESx_th232.root &> $LOG_DIRECTORY/PTFESx_th232.log &

# TeO2Sx-pb210
echo "TeO2Sx-pb210 MC starting"
$QSHIELDS_APP -X\(37,0,+0.0001\) -G $PB210 -M$TeO2SxLoops -N$TeO2SxEvents -or$SPECTRA_DIRECTORY/TeO2Sx_pb210.root &> $LOG_DIRECTORY/TeO2Sx_pb210.log &

# TeO2-u238
echo "TeO2-u238 MC starting"
$QSHIELDS_APP -U37 -G $U238 -N$TeO2Events -or$SPECTRA_DIRECTORY/TeO2_u238.root &> $LOG_DIRECTORY/TeO2_u238.log &

# 10mK-u238
echo "10mK-u238 MC starting"
$QSHIELDS_APP -U18 -G $U238 -N$_10mKEvents -or$SPECTRA_DIRECTORY/10mK_u238.root &> $LOG_DIRECTORY/10mK_u238.log &

echo "Waiting for simulation jobs to complete..."
echo "Warning! Make sure no other bash commands are running in the background."
echo "This script waits for all other background scripts to finish to continue..."
wait
echo "Done waiting!"

FinishTime=$(date -u +%s)
FinishTime_Readable=$(date)
echo "Done at time: $FinishTime_Readable"
echo "Time Elapsed: $(($FinishTime - $StartTime)) seconds"

##### Run g4cuore############################################

echo "Running g4cuore now"

rateValue=0.0001
integrationTime=0.0005

echo "[1/6] PbR_th232"
# PbR-th232
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTP_DIRECTORY/PbR_th232_g4cuore.root -ir$SPECTRA_DIRECTORY/PbR_th232.root > $LOG_DIRECTORY/PbR_th232_g4cuore.log
echo "[2/6] CuFrameSx_th232"
# CuFrameSx-th233
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTP_DIRECTORY/CuFrameSx_th232_g4cuore.root -ir$SPECTRA_DIRECTORY/CuFrameSx_th232.root > $LOG_DIRECTORY/CuFrameSx_th232_g4cuore.log
echo "[3/6] PTFESx_th232"
# PTFESx-th232
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTP_DIRECTORY/PTFESx_th232_g4cuore.root -ir$SPECTRA_DIRECTORY/PTFESx_th232.root > $LOG_DIRECTORY/PTFESx_th232_g4cuore.log
echo "[4/6] TeO2Sx_pb210" 
# TeO2Sx-pb210
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTP_DIRECTORY/TeO2Sx_pb210_g4cuore.root -ir$SPECTRA_DIRECTORY/TeO2Sx_pb210.root > $LOG_DIRECTORY/TeO2Sx_pb210_g4cuore.log
echo "[5/6] TeO2_u238"
# TeO2-u238
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTP_DIRECTORY/TeO2_u238_g4cuore.root -ir$SPECTRA_DIRECTORY/TeO2_u238.root > $LOG_DIRECTORY/TeO2_u238_g4cuore.log
echo "[6/6] 10mK_u238"
# 10mK-u238
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTP_DIRECTORY/10mK_u238_g4cuore.root -ir$SPECTRA_DIRECTORY/10mK_u238.root > $LOG_DIRECTORY/10mK_u238_g4cuore.log

echo "Done with generating spectra"
echo "Now running python script for analysis..."

#### make comparisons

# run root file to generate plots and determine differences

python $ROOTSCRIPT