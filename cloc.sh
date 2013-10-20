#!/bin/sh

if [[ $# > 0 && $1 = '-v' ]]; then
	find source -name *.hx | xargs wc -l;
elif [[ $# == 0 ]]; then
	find source -name *.hx | xargs wc -l | grep total | sed 's/ //g' | sed 's/total/ lines of code./g';
else
	echo "usage: cloc.sh [-v]";
fi

