#!/bin/python
# -*- coding: utf-8 -*-

import sys, getopt, ConfigParser

def usage():
    sys.stderr.write("""Usage: %s [-f configfile] {section}\n""" % sys.argv[0])

if __name__ == '__main__':
    configfile = 'accounts.conf'
    try:
        opts, args = getopt.getopt(sys.argv[1:], "f:", ["file="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for o, a in opts:
        if o in ("-f", "--file"):
            configfile = a

    if len(args) == 0:
        usage()
        sys.exit(2)

    section = args[0]

    config = ConfigParser.SafeConfigParser()
    config.read(configfile)
    for name, value in config.items(section):
        print "%s='%s'" % (name, value)

