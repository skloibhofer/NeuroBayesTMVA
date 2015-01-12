# NeuroBayesTMVA

Presented here is the framework for the use of NeuroBayes for analyzing the Higgs to two tau leptons decay. It is based on the TMVA implementation of ROOT. The TMVA implementation of NeuroBayes can be installed from the repository https://github.com/sroecker/tmva-neurobayes. 

In the directory *work_scripts* the C++ scripts, which are run by ROOT are stored. Those are the three scripts *nb_train.C*, *nb_test.C* and *optionstring.C* required for the basic run and some plot scripts.
In *shell_scripts* the bash scripts are stored, which have to be run from the main directory, to start the analyzis of different options.
In *optionfiles* different string and variable option files are stored, which are used to pass options between the user, the shell scripts and the C++ scripts.
*TAMS* contains files to calculate the figure of merit.
All output files are stored in *output*.
The files in the main directory are *sh_run.sh* which is used by the shellscripts to start the NeuroBayes analysis and *run_plot.C* which can be started with root to plot the output distribution of an analysis.

Before running the analysis, the input files have to be specified directly in the *nb_train.C* and *nb_test.C* files. Then in the shell script the two option files to use have to be specified and then the script is started by typing 
`$ shell_scripts/run_iter.sh`
in the main director. *run_iter.sh* is for example a file that tests Neurobayes for different numbers of iterations.

