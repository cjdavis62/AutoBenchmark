These scripts will automatically benchmark a test release of qshields with the previous tagged version

To run, first open an interactive session on your server (walltime 48 hours) and run in the location you wish to generate files.
> . benchmarkCheck.sh

This will run for approximately 30-40 hours and perform the following:
1. Create output directories
2. SVN old data from ROMA cluster to local host. (~10 GB)
3. Generates spectra using same parameters as the old spectra (with fewer events) with the "new" qshields
4. Runs the "new" g4cuore on the new spectra with the same parameters as the old spectra


After this is completed, run the next script:
> python benchmarkCheck_root.py

This will perform the following:
1. Create final output directories
2. Use plot_energy_template.cc to generate specific code to open the ROOT files from g4cuore
3. Runs the code on the ROOT files
4. The code generates comparison plots for benchmarking
5. Runs a simple check to determine if the total number of events has changed significantly