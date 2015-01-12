#!/bin/bash

# Script to find the perfect Preprocessing flags
# Add -in if you want to run this scipt only on the workoptionfiles (mostly if you call it from inside a script)

# Recreate file to save output in
logfile="output/run_preproflags.log"
printf "Logfile of run_preproflags.sh run on %s, at %s \n\n" "$(date +"%D")" "$(date +"%T")" > $logfile
echo "Create logfile in $logfile"
resultfile="output/preproflags_results.log"
printf "" > $resultfile
echo "Created Resultfile in $resultfile"
shortfile="output/preproflags_short.ascii"
printf "" > $shortfile
echo "Created short resultfile in $shortfile"

# Declare Variables
varoption="optionfiles/workvar.opt" 
if [[ $1 != "-in" ]]; then
    cp optionfiles/var2met.opt $varoption # Enter the chosen variablefile
    chmod a+w $varoption
fi
newvaroption="optionfiles/preprovar.opt"
stringoption="optionfiles/workstring.opt"
if [[ $1 != "-in" ]]; then
    cp optionfiles/string2.opt $stringoption # Enter the chosen stringgenerationfile
    chmod a+w $stringoption
fi
osed=`echo ./work_scripts/oversed.sh`
newstringoption="optionfiles/preprostring.opt"

# Global Preprocessing flag
printf "Figure of Merit for different Global Preprocessing flags\n" >> $resultfile
declare -i iarray=(0 1 2 ) jarray=(0 1 2)
tams=0

for i in ${iarray[*]}
do
    for j in ${jarray[*]}
     do
	$osed "/^Preprocessing/ c\
Preprocessing ${i}${j}" $stringoption
# Run sh_run.C and write stdout to logfile
	echo;echo Running sh_run.C for global preprocessing flag $i$j, output is written to $logfile
	time { root -l -q sh_run.C >> $logfile 2>&1; }
# Analyse outcome with TAMS
	echo Calculating Figure of Merit
	root -l -q TAMS/sh_tams.C\(\"histos/hist_NeuroBayes_train.root\",0\)
	root -l -q TAMS/sh_tams.C\(\"histos/hist_NeuroBayes_test.root\",1\)
	fom=`tail -n 1 output/tamsout.ascii`
# Write to resultfile
	printf "%2s  %7s\n" "$i$j" $fom >> $resultfile
	if [[ $(echo "$fom > $tams"|bc) == '1' ]]
	then
	    tams=$fom
	    preproflags[0]="$i$j"
	    cp $stringoption $newstringoption
	fi
    done
done
echo; echo "Results as presented in $resultfile:"
echo; cat $resultfile
echo; echo "The optionfile with the optimal settings is saved in $newstringoption"
echo "Using global Preproflag ${preproflags[0]}"

#$osed "/^Preprocessing/ c\
#Preprocessing ${i}${j}" $stringoption
#echo Using global Preproflag 22 # Decisison made after results in preproflags_results[567].log

# Individual Preprocessing flags
cp $newstringoption $stringoption # Using optimized global prepro settings
declare -i it=0 NVAR=`sed -n '5 p' $varoption` 
declare -i iarray=(1 2) jarray=(2 3 4 5)

while (( $it < $NVAR ))
do
    it+=1; tams=0
    if [[ `sed -n "${it}1 p" $varoption` == '0' ]]; then continue
    elif [[ `sed -n "${it}1 p" $varoption` != '1' ]]; then 
        echo "Error in $varoption line ${it}1: '0' or '1' expected"
        continue
    fi
    varname[$it]=`sed -n "${it}2 p" $varoption`
    echo; echo "Optimizing Individual Preprocessing flag for variable ${varname[$it]}"
    printf "\nIndividual Prepro Flag, %s\n" ${varname[$it]} >> $resultfile

    for i in ${iarray[*]}
    do
	for j in ${jarray[*]}
	do
            if (( j == 2 && i != 1 )); then continue
            elif (( j ==3 && i != 2 )); then continue; fi
	    $osed "${it}8 c\
${i}${j}" $varoption
# Run sh_run.C and write stdout to logfile
	    echo "Running sh_run.C for individual preprocessing flag $i$j of ${varname[$it]}, output is written to $logfile"
	    time { root -l -q sh_run.C >> $logfile 2>&1; }
# Analyse outcome with TAMS
	    echo "Calculating Figure of Merit"
	    root -l -q TAMS/sh_tams.C\(\"histos/hist_NeuroBayes_train.root\",0\)
	    root -l -q TAMS/sh_tams.C\(\"histos/hist_NeuroBayes_test.root\",1\)
	    fom=`tail -n 1 output/tamsout.ascii`
# Write to resultfile
	    printf "%2s  %7s\n" "$i$j" $fom >> $resultfile
	    if [[ $(echo "$fom > $tams"|bc) == '1' ]]
	    then
		tams=$fom
		preproflags[$it]="$i$j"
		cp $varoption $newvaroption
	    fi
	done
    done
    cp $newvaroption $varoption # Save optimized preproflag
    echo "Using Preprocessing Flag ${preproflags[$it]} for variable ${varname[$it]}"
done

# In short
it=0
while (( $it <= $NVAR ))
do 
    if (( $it == 0 )); then
	printf "%18s %2s" "global_prepro_flag" ${preproflags[$it]} >> $shortfile
    elif [[ `sed -n "${it}1 p" $varoption` == '1' ]]; then 
        printf "\n%18s %2s" "${varname[$it]}" ${preproflags[$it]} >> $shortfile
    fi
    it+=1
done
echo; echo "Brief results as saved in $shortfile:"
cat $shortfile; echo

# show that script has finished successfully
echo run_preproflags.sh finished