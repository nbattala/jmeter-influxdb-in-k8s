#!/usr/bin/env bash

jmeter_ns=$(kubectl get pods -A -l app=jmeter -o=jsonpath='{.items[].metadata.namespace}')

while getopts "t:J:l:h" opt;
do	case "$opt" in
	t)	
		testFile="$OPTARG"
		;;
	J)
		echo "reading Jproperties - $OPTARG"
		;;
	l)
		echo "reading Log file paramater"
		;;
	?|h)	echo "Usage: $0 [-t <path to jmeter script>] [-J<property> ...]" 
		exit 1;;
	esac
done

if [ ! -f "$testFile" ]
then
    echo "ERROR: Jmeter Test script was not found in PATH. Please input the correct file path"
    exit
fi

testName=$(basename "$testFile")

jmeter_pod=$(kubectl get po -n ${jmeter_ns} -l app=jmeter -o=jsonpath='{.items[].metadata.name}')

#copy the script to jmeter pod
kubectl cp "$testFile" -n ${jmeter_ns} "${jmeter_pod}:/${testName}"

echo "starting jmeter load test"

kubectl -n ${jmeter_ns} exec -it ${jmeter_pod} -- /bin/bash /load_test $@

