#!/bin/bash

if [ -z "`ps aux | grep -i python | grep -v grep`"  ]; then
	python -m SimpleHTTPServer 1>/dev/null &
	ps aux | grep -i python | grep -v grep
	sleep 1
	open -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome "http://0.0.0.0:8000/editor"
else
	echo "meditr running:"
	ps aux | grep -i python | grep -v grep
fi
