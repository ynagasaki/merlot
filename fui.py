#!/usr/bin/python

import os, re
import os.path

def processfile(filename):
	fin = open(filename, "r")
	lines = fin.readlines()
	fin.close()

	imported = [];

	for line in lines:
		line = line.strip()
		if len(line) == 0:
			continue
		elif "import" in line:
			imported.append(line.strip(";").strip().split(".")[-1])
		else:
			line_words = re.split('\W+', line);
			for item in imported:
				for line_word in line_words:
					if item == line_word and item in imported:
						imported.remove(item)
					if len(imported) == 0:
						return imported
	return imported

for dirpath, dirnames, filenames in os.walk("./source/"):
	for filename in [f for f in filenames if f.endswith(".hx")]:
		fname = os.path.join(dirpath, filename)
		print "checking", fname
		unused = processfile(fname)
		for item in unused:
			print " ~", item
