#!/bin/env python
#-*- encoding=utf8 -*-

import os
import sys
import traceback

def printDir(rootdir):
	nrootdir = rootdir.replace("src", "nsrc")
	if not os.path.exists(nrootdir):
		os.mkdir(nrootdir)
	list = os.listdir(rootdir)
	for x in range(1,len(list)):
		path = os.path.join(rootdir, list[x])
		try:
			if os.path.isfile(path):
				npath = path.replace("src", "nsrc") + ".txt"
				print(path)
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
		else:
			pass
		finally:
			pass


def main():
	rootdir = sys.path[0]
	printDir(rootdir + "\\src")
	
if __name__ == '__main__':
	main()
