#!/bin/bash

# Script to find the perfect Learning speed and Limit

# Recreate file to save output in
logfile="output/run_learnspeed.log"
printf "Logfile of run_learnspeed.sh run on %s, at %s \n\n" "$(date +"%D")" "$(date +"%T")" > $logfile
echo "Create logfile in $logfile"
# resultfile="output/learnspeed_results.log"
# printf "" > $resultfile
# echo "Created Resultfile in $resultfile"
shortfile="output/learnspeed_short.ascii"
printf "" > $shortfile
echo "Created short resultfile in $shortfile"

# Declare Variables
varoption="optionfiles/workvar.opt" 
cp optionfiles/variables3.opt $varoption # Enter the chosen variablefile
chmod a+w $varoption
stringoption="optionfiles/workstring.opt"
cp optionfiles/string4.opt $stringoption # Enter the chosen stringgenerationfile
chmod a+w $stringoption
osed=`echo ./work_scripts/oversed.sh`

speed=( 0.1 0.4 0.6 0.8 1 1.2 1.5 2 3 4 5  )
limit=( 0.128 0.254 0.512 1.024 2.048 4.096 8 16 32 64 128 256 512 1000 )

# Write first line, which serves as legend for the horizontal variable
printf 'lim\spe  ' > $shortfile # Every column should be eight characters long +1space
for sp in ${speed[*]}
do
    printf "%8s " $sp >> $shortfile
done
printf "\n" >> $shortfile

for lim in ${limit[*]}
do
    printf "%-8s " $lim >> $shortfile
    $osed "/^LimitLearningSpeed/ c\
LimitLearningSpeed $lim" $stringoption

    for sp in ${speed[*]}
    do
	$osed "/^LearningSpeed/ c\
LearningSpeed $sp" $stringoption
# Run sh_run.C and write stdout to logfile
	echo; echo "Running sh_run.C for Learn Speed multiplied by $sp and limited by $lim, output is written to $logfile"
	time { root -l -q sh_run.C >> $logfile; }
# Analyse outcome with TAMS
	echo "Calculating Figure of Merit"
	root -l -q TAMS/sh_tams.C\(\"histos/hist_NeuroBayes_train.root\",0\)
	root -l -q TAMS/sh_tams.C\(\"histos/hist_NeuroBayes_test.root\",1\)
	fom=`tail -n 1 output/tamsout.ascii`
# Write to shortfile
	printf "%8s " $fom >> $shortfile
    done
    printf "\n" >> $shortfile
done

echo; echo "Analysis finished, results as shown in $shortfile:"
cat $shortfile; echo

# Make plot
root -q -l work_scripts/plot_2D.C+\(\"learnspeed_short\",\"\",\""Learning Speed"\",\""Speed Limit"\",0,1\)

# show that script has finished successfully
echo run_learnspeed.sh finished