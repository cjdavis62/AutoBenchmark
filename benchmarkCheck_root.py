# This script runs over the .cc file that takes in the benchmark .root files
# The output of the .cc file is collected here and the values are checked for consistency


# Written by Christopher Davis
# christopher.davis@yale.edu
# v0.1 8Mar2016

# Usage information:
# This script needs be run from the same directory in which the files were written 


#import os
from numpy import *
from pylab import *


# Ask the user where to output plots
print "Where should we output the generated plots in BenchmarkTestFiles"?
Plot_Output_Location = raw_input("> BenchmarkTestFiles/")
Plot_Output_Location = "BenchmarkTestFiles/" + Plot_Output_Location


# Names of the volumes to be checked
Simulation_Names=["PbR-th232", "CuFrameSx-th232", "PTFESx-th232", "TeO2Sx-pb210", "TeO2-u238", "10mK-u238"]

# Number of bins depends on each file
PbR-th232_Bins = 3500
CuFrameSx-th232_Bins = 10000
PTFESx-th232_Bins = 10000
TeO2Sx-pb210_Bins = 6000
TeO2-u238_Bins = 12000
_10mK-u238_Bins = 3500

# Loop over the filenames
for Name in Simulation_Names:
	Cpp_Name = "plot_energy_%s.cc" %(name)
	
	# create new file to work on
	os.system("cp plot_energy_template.cc %s" %(Cpp_Name))
	
	# Change variable names in the file
			
	os.system("sed ")
	# Change void name and change volume names
	os.system("sed 's/_volume_/%s/ <Cpp_Name >Cpp_Name" %(Name))
	
	# Change number of bins
	if "PbR-th232" in Name:
		os.system("sed 's/_number_of_bins_/%s/ <Cpp_Name >Cpp_Name" %(PbR-th232_Bins))
	elif "CuFrameSx-th232" in Name:
		os.system("sed 's/_number_of_bins_/%s/ <Cpp_Name >Cpp_Name" %(CuFrameSx-th232_Bins))
	elif "PTFESx-th232" in Name:
		os.system("sed 's/_number_of_bins_/%s/ <Cpp_Name >Cpp_Name" %(PTFESx-th232_Bins))
	elif "TeO2Sx-pb210" in Name:
		os.system("sed 's/_number_of_bins_/%s/ <Cpp_Name >Cpp_Name" %(TeO2Sx-pb210_Bins))
	elif "TeO2-u238" in Name:
		os.system("sed 's/_number_of_bins_/%s/ <Cpp_Name >Cpp_Name" %(TeO2-u238_Bins))
	elif "10mK-u238" in Name:
		os.system("sed 's/_number_of_bins_/%s/ <Cpp_Name >Cpp_Name" %(_10mK-u238_Bins))	
		
	# Change names of the ntp files to run on
	WorkDirectory = "BenchmarkTestFiles"
	Old_NTP_Directory = WorkDirectory + "/Old_Benchmark_Data/ntp"
	New_NTP_Directory = WorkDirectory + "/NTP"
	os.system("sed 's/_old_input_file_/%s/ <Cpp_Name >Cpp_Name" %(Old_NTP_Directory + "/" + Name + "_g4cuore.root"))
	os.system("sed 's/_new_input_file_/%s/ <Cpp_Name >Cpp_Name" %(New_NTP_Directory + "/" + Name + "_g4cuore.root"))
	
	# Change the output locations
	os.system("sed 's/_plot_output_location_/%s/ <Cpp_Name >Cpp_Name" %(Plot_Output_Location)
	
	# run the files
	os.system("root %s" %s(Cpp_Name))
	
# collect the outputs and check to see if anything is beyond the error values

# open the file
Data = loadtxt("%s" %(Residual_File_Name), delimiter = "\t") 
# read the values. Should be in format {value \t error}
Value = Data[:,0]
ValueError = Data[:,1]

# write output
Output_File = open("%s" %(Output_File_Name, "w")

#checks if values are beyond 2 sigma, if outside range, outputs a message
for i in (0, File_Names.len()):
	Sigma = (Value[i] - Value_Error[i]) / Value_Error[i]

	# write output
	Output_File.write("Simulation %s: Error = %s sigma" %(File_Names(i),Sigma))

	if Sigma >= 2:
		# Tell the problem to the user
		print "Change in simulation: %s, investigation needed" %File_Names(i)
	else:
		# write standard output
	
print "Benchmarking completed!"	