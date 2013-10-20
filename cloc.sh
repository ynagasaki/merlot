#!/bin/sh
find source -name *.hx | xargs wc -l | grep total | sed 's/ //g' | sed 's/total/ lines of code./g'