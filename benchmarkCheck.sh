# benchmarkCheck.sh
# Written by Christopher Davis
# v0.1: 23Feb2016


# Bash script
# Generates benchmarking simulation spectra and checks to see differences with prior benchmarked spectra

# General Procedure:
# 1. scp old spectra to local machine
# 2. run simulations with new version
# 3. run checks between spectra
# 4. look for spectra differences (output warnings?)


####################### Prep to Run programs #########################
clear
echo "What is the name of your qshields application in your PATH? e.g. qshields-t15.11.b01"
read QSHIELDS_APP

echo "What is the name of your g4cuore application in your PATH? e.g. g4cuore-t15.11.b01"
read G4CUORE_APP

echo "WARNING"
echo "Program assumes no changes to the volume names between versions"
echo "If you changed the names of the volumes, you will need to edit the source code"
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

#### scp old spectra to local machine
ROMA_DIRECTORY=$WorkDirectory/Old_BenchmarkData
echo "Checking for benchmarking files in $ROMA_DIRECTORY..."
if [ -d "$ROMA_DIRECTORY" ]; then
    echo "files already here, great!"
else
    echo "files not found..."
    echo "loading old spectra to local machine"
    echo "What is your ROMA cluster username?"
    read ROMA_USERNAME 
    scp -r $ROMA_USERNAME@farm-login.roma1.infn.it:/cuore/data/simulation/CUORE/v_9.6/benchmark/t15.11.b01/ntp/ $ROMA_DIRECTORY
fi

# Decay Chain files
TH232=$WorkDirectory/DecayChains/th232_all
PB210=$WorkDirectory/DecayChains/pb210-pb206
U238=$WorkDirectory/DecayChains/u238_all

# The root script that will run over the output files and run checks
ROOTSCRIPT=$ROMA_DIRECTORY/benchmarkCheck_root.py


echo "Okay we will now run qshields on the benchmarking simulations"


##### Set Number of Events to Run ####################

# Number of events to be generated
PbREvents=100000
PbRLoops=10
CuFrameSxEvents=1000000
PTFESxEvents=1000000
TeO2SxEvents=10000
TeO2SxLoops=10
TeO2Events=1000000
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
echo -e "10mK: \t $_10mK_Ratio" >> $GeneratedEventsFile


########## Start Running Simulations ##################
StartTime=$(date -u +%s)
echo "starting at time: $StartTime"

# PbR-th232
echo "PbR-th232 MC"
$QSHIELDS_APP -U13 -G $TH232 -M$PbRLoops -N$PbREvents -or$SpectraDirectory/PbR-th232_Test.root > $LogDirectory/PbR-th232.log & 
#FinishTime=$(date -u +%s)
#echo "Done at time: $FinishTime"
#echo "Time Elapsed: $(($FinishTime - $StartTime))"

#echo "PbR Time Elapsed: $(($FinishTime - $StartTime))" > OutTimes.log
#echo "PbR Events = (($PbRLoops * $PbREvents))" >> OutTimes.log

# CuFrameSx-th232
echo "CuFrameSx-th232 MC"
#StartTime=$(date -u +%s)
#echo "starting at time: $StartTime"
$QSHIELDS_APP -X\(38,0,+0.0005\) -G $TH232 -N$CuFrameSxEvents -or$SpectraDirectory/CuFrameSx-th232_Test.root > $LogDirectory/CuFrameSx-th232.log &
#FinishTime=$(date -u +%s)

#echo "Done at time: $FinishTime"
#echo "Time Elapsed: $(($FinishTime - $StartTime))"

#echo "CuFrameSx Time Elapsed: $(($FinishTime - $StartTime))" >> OutTimes.log
#echo "CuFrameSx Events = $CuFrameSxEvents" >> OutTimes.log

# PTFESx-th232
echo "PTFESx-th232"
#StartTime=$(date -u +%s)
#echo "starting at time: $StartTime"
$QSHIELDS_APP -X\(42,0,+0.0005\) -G $TH232 -N$PTFESxEvents -or$SpectraDirectory/PTFESx-th232_Test.root > $LogDirectory/PTFESx-th232.log &
#FinishTime=$(date -u +%s)

#echo "Done at time: $FinishTime"
#echo "Time Elapsed: $(($FinishTime - $StartTime))"

#echo "PTFESx Time Elapsed: $(($FinishTime - $StartTime))" >> OutTimes.log
#echo "PTFESx Events = $PTFESxEvents" >> OutTimes.log

# TeO2Sx-pb210
echo "TeO2Sx-pb210"
#StartTime=$(date -u +%s)
#echo "starting at time: $StartTime"
$QSHIELDS_APP -X\(37,0,+0.0001\) -G $PB210 -M$TeO2SxLoops -N$TeO2SxEvents -or$SpectraDirectory/TeO2Sx-pb210_Test.root > $LogDirectory/TeO2Sx-pb210.log &
#FinishTime=$(date -u +%s)

#echo "Done at time: $FinishTime"
#echo "Time Elapsed: $(($FinishTime - $StartTime))"

#echo "TeO2Sx Time Elapsed: $(($FinishTime - $StartTime))" >> OutTimes.log
#echo "TeO2Sx Events = (($TeO2SxLoops * $TeO2SxEvents))" >> OutTimes.log

# TeO2-u238
echo "TeO2-u238"
#StartTime=$(date -u +%s)
#echo "starting at time: $StartTime"
$QSHIELDS_APP -U37 -G $U238 -N$TeO2Events -or$SpectraDirectory/TeO2-u238_Test.root > $LogDirectory/TeO2-u238.log &
#FinishTime=$(date -u +%s)

#echo "Done at time: $FinishTime"
#echo "Time Elapsed: $(($FinishTime - $StartTime))"

#echo "TeO2 Time Elapsed: $(($FinishTime - $StartTime))" >> OutTimes.log
#echo "TeO2 Events = $TeO2Events" >> OutTimes.log

# 10mK-u238
#echo "10mK-u238"
#StartTime=$(date -u +%s)
#echo "starting at time: $StartTime"
$QSHIELDS_APP -U18 -G $U238 -N$_10mKEvents -or$SpectraDirectory/10mK-u238_Test.root > $LogDirectory/10mK-u238.log &
#FinishTime=$(date -u +%s)

#echo "Done at time: $FinishTime"
#echo "Time Elapsed: $(($FinishTime - $StartTime))"

#echo "10mK Time Elapsed: $(($FinishTime - $StartTime))" >> OutTimes.log
#echo "10mK Events = $_10mKEvents" >> OutTimes.log

echo "Waiting for simulation jobs to complete..."
wait
echo "Done waiting!"

##### Run g4cuore############################################

echo "Running g4cuore now"

rateValue=0.0001
integrationTime=0.005


# PbR-th232
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/PbR-th232_Test_g4cuore.root -ir$SpectraDirectory/PbR-th232_Test.root
# CuFrameSx-th233
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/CuFrameSx-th232_Test_g4cuore.root -ir$SpectraDirectory/CuFrameSx-th232_Test.root
# PTFESx-th232
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/PTFESx-th232_Test_g4cuore.root -ir$SpectraDirectory/PTFESx-th232_Test.root
# TeO2Sx-pb210
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/TeO2Sx-pb210_Test_g4cuore.root -ir$SpectraDirectory/TeO2Sx-pb210_Test.root
# TeO2-u238
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/TeO2-u238_Test_g4cuore.root -ir$SpectraDirectory/TeO2-u238_Test.root
# 10mK-u238
$G4CUORE_APP -r$rateValue -D$integrationTime -or$NTPDirectory/10mK-u238_Test_g4cuore.root -ir$SpectraDirectory/10mK-u238_Test.root

echo "Done with generating spectra"


#### make comparisons

# run root file to generate plots and determine differences

python $ROOTSCRIPT
