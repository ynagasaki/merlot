#!/bin/bash
python -m SimpleHTTPServer &
open -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome "http://0.0.0.0:8000/editor"
