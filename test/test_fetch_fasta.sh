#!/bin/bash
#
# Settings
verbose=yes
#
test_dir=$(mktemp --directory --tmpdir=. --suffix=.$(basename $0))
cd $test_dir
#
export TMPDIR=$(pwd)
GENOMES="Creinhardtii169 \
  dictyostelium \
  dm3_het_chrM_chrU \
  e_coli \
  hg18_random_chrM \
  hg19_GRCh37_random_chrM \
  mm10_random_chrM_chrUn \
  mm9_random_chrM_chrUn \
  Ncrassa \
  PhiX \
  rn4 \
  sacBay \
  sacCer1 \
  sacCer2 \
  sacCer3 \
  SpR6 \
  UniVec \
  ws200 \
  ws201"
tested=0
failed=0
for genome in $GENOMES ; do
    tested=$(($tested + 1))
    if [ ! -z "$verbose" ] ; then
	echo -n "$genome..."
    fi
    mkdir $genome
    cd $genome
    log=../${genome%.*}.log
    fetch_fasta.sh $genome >$log 2>&1
    status=$?
    if [ $status -ne 0 ] ; then
	# Report failure and capture tail of log file
	failed=$(($failed + 1))
	if [ ! -z "$verbose" ] ; then
	    echo FAIL
	else
	    echo -n F
	fi
	cat >>../error_report.log <<EOF
=======================================================
FAIL: $genome
-------------------------------------------------------
Tail from captured output:
EOF
	tail $log >>../error_report.log
	cat >>../error_report.log <<EOF
-------------------------------------------------------
EOF
    else
	if [ ! -z "$verbose" ] ; then
	    echo ok
	else
	    echo -n .
	fi
    fi
    cd ..
done
if [ -z "$verbose" ] ; then
    echo
fi
# Finished downloads
if [ $failed -gt 0 ] ; then
  echo $failed failures:
  cat error_report.log
  status=1
else
  status=0
fi
echo Ran $tested downloads
echo 
if [ $status -eq 0 ] ; then
  echo OK
else
  echo "FAILED (failures=$failed)"
fi
exit $status
##
#
