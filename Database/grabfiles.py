# -*- coding: utf-8 -*-

import xmlrpclib, os, sys, getopt, datetime, urllib2, urllib
import ConfigParser

OBLIGATION = 'http://rod.eionet.europa.eu/obligations/9'
XML_SCHEMA = 'http://dd.eionet.europa.eu/schemas/lcp/LCPQuestionnaire.xsd'
XSL = 'lcp-sql.xsl'

def usage():
    sys.stderr.write("""Usage: Obligation is not specified!\n""" % sys.argv[0])

def set_authentication(cdrserver, cdruser, cdrpass):
    auth_handler = urllib2.HTTPBasicAuthHandler()
    auth_handler.add_password("Zope", cdrserver, cdruser, cdrpass)
    opener = urllib2.build_opener(auth_handler)
    urllib2.install_opener(opener)

def downloadfile(fileurl, tmpfile):
    tempFd = open(tmpfile, 'wb')
    conn = urllib2.urlopen(urllib.quote(fileurl, '/:'), None, 10)
    data = conn.read(8192)
    while data:
        tempFd.write(data)
        data = conn.read(8192)
    conn.close()
    tempFd.close()

if __name__ == '__main__':
    config = ConfigParser.SafeConfigParser()
    config.read('accounts.conf')

    cdrserver = config.get('cdr', 'server')
    cdruser = config.get('cdr', 'username')
    cdrpass = config.get('cdr', 'password')
    released = config.getboolean('cdr', 'released')
    #obligation = config.get('cdr', 'obligation')
    testdata = 0

    try:
        opts, args = getopt.getopt(sys.argv[1:], "rdt", ["--released","--draft","--testdata" ])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for o, a in opts:
        if o in ("-r", "--released"):
            released = 1
        if o in ("-d", "--draft"):
            released = 0
        if o in ("-t", "--testdata"):
            testdata = 1

    if len(args) == 0:
        usage()
        sys.exit(2)
            
    obligation = args[0]

    sys.stdout.write("""DELETE FROM BasicData;
""")

    tmpfilename = 'downloadtmp-lcp.xml'
        
    sys.stdout.flush()

    server = xmlrpclib.ServerProxy(cdrserver)

    # Create auth handler
    set_authentication(cdrserver, cdruser, cdrpass)

    for envelope in server.xmlrpc_search_envelopes(obligation, released):

        reportingdate = envelope['released']
        envelopeurl = envelope['url']
        
        if reportingdate[:4] not in ('2015'):
            continue


        print >>sys.stderr, "-- ++++++++++++++++++++++ Envelope %s ++++++++++++++++++++" % envelope['url']

        #check if feedback contains "Data delivery was not acceptable"
        hasBlockerFeedback = False
        try:
            hasBlockerFeedback = xmlrpclib.ServerProxy(envelopeurl).has_blocker_feedback()
        except:
            print >>sys.stderr, "-- Failed to call has_blocker_feedback --"
            
        if hasBlockerFeedback:
            print >>sys.stderr, "-- HAS BLOCKER FEEDBACK --"
            continue

        files = envelope['files']
        
        for f in files:
    
            scriptargs = {
                            'cdruser': cdruser,
                            'cdrpass': cdrpass,
                            'fileurl': "%s/%s" % (envelope['url'], f[0]),
                            'countrycode': envelope['country_code'],
                            'envelopeurl': envelope['url'],
                            'isreleased': envelope['isreleased'],
                            'filename': f[0],
                            'uploadtime': f[4],
                            'accepttime': f[5],
                            'reportingtime': envelope['released'],
                            'xsl': XSL,
                            'tmpfile': 'tmp' + os.sep + tmpfilename
                            
                        }
            try:
                if (f[2] == XML_SCHEMA and obligation == OBLIGATION):
                    fileurl = "%s/%s" % (envelope['url'], f[0])
                    tmpfile = 'tmp' + os.sep + tmpfilename
                    downloadfile(fileurl, tmpfile)
                    os.system("""xsltproc --stringparam envelopeurl '%(envelopeurl)s' --stringparam filename '%(filename)s' --stringparam releasetime '%(reportingtime)s' --stringparam isreleased '%(isreleased)s' --stringparam countrycode '%(countrycode)s' --param commandline 'true' %(xsl)s %(tmpfile)s """ % scriptargs )
                    os.unlink(tmpfile)
            except:
                print >>sys.stderr, "-- Failed to parse XML: %s " % fileurl


    sys.stdout.write("""
UPDATE tbl_db_sys SET generated='%s'; """ %  (datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
    sys.stdout.flush()
