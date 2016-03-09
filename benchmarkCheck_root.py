#This script runs over the .cc file that takes in the benchmark .root files
# The output of the .cc file is collected here and the values are checked for consistency


# Written by Christopher Davis
# christopher.davis@yale.edu
# v0.1 8Mar2016

# Usage information:
# This script needs be run from the same directory in which the files were written


import os
from numpy import *
#from pylab import *

# Inputs Location
Residual_File_Name = "BenchmarkTestFiles/Output/Ratios.dat"
Residual_File_Name_temp = "BenchmarkTestFiles/Output/Ratios_temp.dat"

# Outputs Location, '\' for sed
Plot_Output_Location = "BenchmarkTestFiles\/Output\/Plots\/"
Output_File_Name = "BenchmarkTestFiles/Output/Output.txt"

# Generate output location and output plot locations
if not os.path.isdir("BenchmarkTestFiles/Output"):
	os.system("mkdir BenchmarkTestFiles/Output")
if not os.path.isdir("BenchmarkTestFiles/Output/Plots"):
	os.system("mkdir BenchmarkTestFiles/Output/Plots")

# Names of the volumes to be checked
Simulation_Names=["PbR_th232", "CuFrameSx_th232", "PTFESx_th232", "TeO2Sx_pb210", "TeO2_u238", "10mK_u238"]

# Number of bins depends on each file
PbR_th232_Bins = 3500
CuFrameSx_th232_Bins = 10000
PTFESx_th232_Bins = 10000
TeO2Sx_pb210_Bins = 6000
TeO2_u238_Bins = 12000
_10mK_u238_Bins = 3500

# Generate directory to place cpp files for ROOT
if not os.path.isdir("cpp_files"):
	os.system("mkdir cpp_files")
# Temp file for sed
tmpfile = "cpp_files/tmpfile.cc"

# Make sure output location is empty
if os.path.exists(Residual_File_Name):
	os.system("rm %s" %(Residual_File_Name))

# Loop over the filenames
for Name in Simulation_Names:
	Cpp_Name = "cpp_files/plot_energy_%s.cc" %(Name)
	
	# create new file to work on

	os.system("cp plot_energy_template.cc %s" %(Cpp_Name))
	
	# Change variable names in the file
			
	# Change void name and change volume names
	os.system("sed 's/_volume_/%s/' <%s >%s; mv %s %s" %(Name, Cpp_Name, tmpfile, tmpfile, Cpp_Name))
	
	# Change number of bins
	if "PbR_th232" in Name:
		os.system("sed 's/_number_of_bins_/%s/' <%s >%s; mv %s %s" %(PbR_th232_Bins, Cpp_Name, tmpfile, tmpfile, Cpp_Name))
	elif "CuFrameSx_th232" in Name:
		os.system("sed 's/_number_of_bins_/%s/' <%s >%s; mv %s %s" %(CuFrameSx_th232_Bins, Cpp_Name, tmpfile, tmpfile, Cpp_Name))
	elif "PTFESx_th232" in Name:
		os.system("sed 's/_number_of_bins_/%s/' <%s >%s; mv %s %s" %(PTFESx_th232_Bins, Cpp_Name, tmpfile, tmpfile, Cpp_Name))
	elif "TeO2Sx_pb210" in Name:
		os.system("sed 's/_number_of_bins_/%s/' <%s >%s; mv %s %s" %(TeO2Sx_pb210_Bins, Cpp_Name, tmpfile, tmpfile, Cpp_Name))
	elif "TeO2_u238" in Name:
		os.system("sed 's/_number_of_bins_/%s/' <%s >%s; mv %s %s" %(TeO2_u238_Bins, Cpp_Name, tmpfile, tmpfile, Cpp_Name))
	elif "10mK_u238" in Name:
		os.system("sed 's/_number_of_bins_/%s/' <%s >%s; mv %s %s" %(_10mK_u238_Bins, Cpp_Name, tmpfile, tmpfile, Cpp_Name))	
		
	# Change names of the ntp files to run on, use '\/' for sed
	WorkDirectory = "BenchmarkTestFiles"
	Old_NTP_Directory = WorkDirectory + "\/Old_Benchmark_Data\/ntp"
	New_NTP_Directory = WorkDirectory + "\/NTP"

	# g4cuore input files, use '\/' for sed
	Old_g4cuore_input = str(Old_NTP_Directory + "\/" + Name + "_g4cuore.root")
	New_g4cuore_input = str(New_NTP_Directory + "\/" + Name + "_Test_g4cuore.root")

	os.system("sed 's/_old_input_file_/%s/' <%s >%s; mv %s %s" %(Old_g4cuore_input, Cpp_Name, tmpfile, tmpfile, Cpp_Name))
	os.system("sed 's/_new_input_file_/%s/' <%s >%s; mv %s %s" %(New_g4cuore_input, Cpp_Name, tmpfile, tmpfile, Cpp_Name))

	# Change the output locations
	os.system("sed 's/_plot_output_location_/%s/' <%s >%s; mv %s %s" %(Plot_Output_Location, Cpp_Name, tmpfile, tmpfile, Cpp_Name))
	
	# run the files
	os.system("root %s -l -q -b" %(Cpp_Name))
	
	# collect the outputs
	os.system("cat %s >> %s" %(Residual_File_Name_temp, Residual_File_Name))

# open the file
Data = loadtxt(Residual_File_Name, delimiter = "\t", dtype = str) 
# read the values. Should be in format {value \t error}
Mall_Value = Data[:,0]
Mall_ValueError = Data[:,1]
M1_Value = Data[:,2]
M1_ValueError = Data[:,3]
M2_Value = Data[:,4]
M2_ValueError = Data[:,5]
Mmore2_Value = Data[:,6]
Mmore2_ValueError = Data[:,7]


# write output
Output_File = open("%s" %(Output_File_Name), "w")

# iterator for upcoming loop
i = 0

#checks if ratios are inconsistent with 1.0, if outside range, outputs a message
for Name in(Simulation_Names):
	Sigma = abs(float(Mall_Value[i]) - 1.0) / float(Mall_ValueError[i])

	# write output
	Output_File.write("Simulation %s: Error = %s sigma" %(Name, Sigma))

	if Sigma >= 2:
		# Tell the problem to the user
		print "Change in simulation: %s, investigation needed" %Name
		print "\t We see a ratio of %s which is %s sigma away from 1.0" %(Mall_Value[i], Sigma)
	else:
		# write standard output
		pass
	i = i + 1
	
print "Benchmarking completed!"	
