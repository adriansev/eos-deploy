###########################################################
set MGM=$EOS_MGM_ALIAS
###########################################################

###########################################################
set myName = ALICE::ISS::EOS
all.sitename $myName

xrootd.fslib -2 libXrdEosFst.so
xrootd.async off nosf
xrd.network keepalive
xrootd.redirect $(MGM):1094 chksum

# Specify when threads are created, how many can be created, and when they should be destroyed.
# http://xrootd.org/doc/dev48/xrd_config.htm#_Toc496911324
xrd.sched mint 16 avlt 24 idle 60 maxt 512

# Set timeout parameters for incoming connections
# http://xrootd.org/doc/dev48/xrd_config.htm#_Toc496911326
xrd.timeout hail 30 kill 10 read 20 idle 600

###########################################################
xrootd.seclib libXrdSec.so
sec.protocol unix
sec.protocol sss -c /etc/eos.keytab -s /etc/eos.keytab
sec.protbind * only unix sss

###########################################################
all.export / nolock
all.trace none
all.manager localhost 2131
#ofs.trace open

###########################################################
xrd.port 1095
ofs.persist off
ofs.osslib libEosFstOss.so
ofs.tpc pgm /opt/eos/xrootd/bin/xrdcp

###########################################################
# this URL can be overwritten by EOS_BROKER_URL defined /etc/sysconfig/xrd
fstofs.broker root://mgm.spacescience.ro:1097//eos/
fstofs.autoboot true
fstofs.quotainterval 10
fstofs.metalog /var/eos/md/
#fstofs.authdir /var/eos/auth/
#fstofs.trace client
###########################################################

# QuarkDB cluster info needed by FSCK to perform the namespace scan
fstofs.qdbcluster mgm1.spacescience.ro:7000 mgm2.spacescience.ro:7000 mgm3.spacescience.ro:7000
fstofs.qdbpassword_file /etc/quarkdb.pass

fstofs.filemd_handler attr

#-------------------------------------------------------------------------------
# Configuration for XrdHttp http(s) service on port 8000
#-------------------------------------------------------------------------------
if exec xrootd
    xrd.protocol XrdHttp:8000 libXrdHttp.so
    http.trace  false
    http.exthandler EosFstHttp /usr/lib64/libEosFstHttp.so none

    # HOST CERTS REQUIRED
    http.exthandler  xrdtpc libXrdHttpTPC.so
    xrd.tls  /etc/grid-security/hostcert.pem /etc/grid-security/hostkey.pem
    xrd.tlsca  certdir /etc/grid-security/certificates/
fi

xrootd.monitor all flush 60s window 30s dest files info user alien.spacescience.ro:9930

