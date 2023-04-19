#!/usr/bin/env bash

jmeter_ns=$(kubectl get pods -A -l app=jmeter -o=jsonpath='{.items[].metadata.namespace}')

while getopts "t:" arg;
do	case "$arg" in
	t)	testfile="$OPTARG";;
	[?])	echo "Usage: $0 [-t <path to jmeter script>] [-<other jmeter test options>]"
		exit 1;;
	esac
done

shift $((OPTIND-1))

if [ ! -f "$testfile" ]
then
    echo "ERROR: Jmeter Test script was not found in PATH. Please input the correct file path"
    exit
fi

test_name=$(basename "$jmx")

jmeter_pod=$(kubectl get po -n ${jmeter_ns} -l app=jmeter)

#copy the script to jmeter pod
kubectl cp "$jmx" -n ${jmeter_ns} "${jmeter_pod}:/${test_name}

echo "starting jmeter load test"

kubectl exec -it -n ${jmeter_ns} ${jmeter_pod} -- /bin/bash /load_test "$@"

