#!/bin/env python
#-*- encoding=utf8 -*-

import os
import sys
import traceback

def split_with_xlua(s):
	pos = s.find("XLua")
	prefix = s[0:pos]
	appdenix = s[pos:]
	return prefix, appdenix

def printDir(rootdir):
	prefix, appdenix = split_with_xlua(rootdir)
	nrootdir = prefix + "Assets\\Resources\\" + appdenix
	if not os.path.exists(nrootdir):
		os.mkdir(nrootdir)
		print("mkdir ==>" + nrootdir)
	list = os.listdir(rootdir)
	for x in range(0,len(list)):
		path = os.path.join(rootdir, list[x])
		try:
			if os.path.isfile(path):
				suffix = list[x].split(".")[-1]
				if suffix == 'lua' or suffix == 'sproto':
					npath = os.path.join(nrootdir, list[x] + ".txt")
					if sys.version_info[0] == 2 :
						rfd = open(path, "r")
						c = rfd.read()
						rfd.close()	
						wfd = open(npath, "w")
						wfd.write(c)
						wfd.flush()
						wfd.close()	
					else:
						rfd = open(path, "r", encoding="UTF-8")
						c = rfd.read()
						rfd.close()	
						wfd = open(npath, "w", encoding="UTF-8")
						wfd.write(c)
						wfd.flush()
						wfd.close()
			else:
				printDir(path)
		except Exception as e:
			print(traceback.print_exc())
			print(e)
		finally:
			pass


def main():
	rootdir = sys.path[0]
	printDir(rootdir)
	# os.system("pause")
	
if __name__ == '__main__':
	main()
