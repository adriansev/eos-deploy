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
xrd.sched mint 8 avlt 16 idle 60 maxt 160

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
ofs.tpc pgm /usr/bin/xrdcp

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
fstofs.qdbcluster mgm.spacescience.ro:7001 mgm.spacescience.ro:7002 mgm.spacescience.ro:7003
fstofs.qdbpassword REDACTED

#-------------------------------------------------------------------------------
# Configuration for XrdHttp http(s) service on port 11000
#-------------------------------------------------------------------------------
#if exec xrootd
#   xrd.protocol XrdHttp:11000 /usr/lib64/libXrdHttp-4.so
#   http.exthandler EosFstHttp /usr/lib64/libEosFstHttp.so none
#   http.cert /etc/grid-security/daemon/host.cert
#   http.key /etc/grid-security/daemon/privkey.pem
#   http.cafile /etc/grid-security/daemon/ca.cert
#fi

xrootd.monitor all flush 60s window 30s dest files info user alien.spacescience.ro:9930

