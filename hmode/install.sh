#!/bin/bash
# ---------------------------------------------------------------
# Install and configure 
#   1.apache server
#   2.tomcat
# ---------------------------------------------------------------

#

/root/mode/modelog "$0 $*"

# check gcc utilities

if [ ! -f /usr/bin/gcc ]; then
   /root/mode/modemsg install.sh "The gcc has not been installed!" more && exit 1 
elif [ `rpm -qa | grep -E "^(lib)?gcc-" | wc -l` -lt 4 ]; then
   /root/mode/modemsg install.sh "The gcc utilities have not been installed adequately!" more && exit 1 
fi

# apache instance (at most 8 instances)

HAPACHENO="$1"
if [ -f /etc/mclustermode ]; then
   if ! echo "$HAPACHENO" | grep -E "^[1-7]?$" >/dev/null; then
      exit 1
   fi 
else
   if ! echo "$HAPACHENO" | grep -E "^[1-2]?$" >/dev/null; then
      exit 1
   fi 
fi

# confirmation part 

if ! /root/mode/confirm "Do you really want to install gcserver$HAPACHENO"; then
   exit 1
fi
echo -n "Password:"
read -s Hhrypassword
echo 
if [ "$HAPACHENO" = "" ]; then
   HhRyP=dangeR
elif [ "$HAPACHENO" = "1" ]; then
   HhRyP=dangEr
elif [ "$HAPACHENO" = "2" ]; then
   HhRyP=dangER
else
   HhRyP=dAnger$HAPACHENO
fi
if [ "$Hhrypassword" != "$HhRyP" ]; then
   echo "Installation aborted!!" && exit 1
fi

# install common parts 

/root/mode/inst_com

# mkdir tmp directory

Hhrytmpdir="/root/mode/hhrytmpdir$$"

mkdir -p $Hhrytmpdir
cd $Hhrytmpdir
rm -fR *

# -------------------------------------------------------------------
# Tomcat part
# -------------------------------------------------------------------
# Java jdk6 and tomcat
# -------------------------------------------------------------------

# Install jdk6

/root/mode/inst_java

# Install tomcat
export Hinst_Ctom=1
/root/mode/inst_tomcat apache$HAPACHENO && /root/mode/inst_tomcat apache$HAPACHENO

# -------------------------------------------------------------------
# Apache part
# -------------------------------------------------------------------
# Apache main,mod_jk and mod_bw
# -------------------------------------------------------------------

# Install Apache

[ -d /usr/local/apache$HAPACHENO -a -z "$HAPACHE_OVERRIDE" ] || 
{
Hhttp_package=`ls -1 /root/packages/httpd-2.*.tar.bz2 | tail -n 1`
if echo $Hhttp_package | grep -E 'httpd-2\.2' >/dev/null; then 
   tar xvf $Hhttp_package
   cd `ls -d httpd-2.*`
   /root/mode/rep_config ./server/mpm/prefork/prefork.c "#define DEFAULT_SERVER_LIMIT" 5000
   ./configure --prefix=/usr/local/apache$HAPACHENO --enable-so --with-included-apr
   make
   make install
   HAPACHEIND=${HAPACHENO:-0}
   /root/mode/mod_config /usr/local/apache$HAPACHENO/conf/httpd.conf "Listen $[8090+$HAPACHEIND]"
elif echo $Hhttp_package | grep -E 'httpd-2\.4' >/dev/null; then
   # install pcre
   if [ ! -d /usr/local/pcre ]; then
      cd $Hhrytmpdir
      unzip -o /root/packages/pcre-8.39.zip
      cd pcre-8.39
      ./configure --prefix=/usr/local/pcre
      make
      make install
      cd $Hhrytmpdir
      rm -fR *
   fi
   cd $Hhrytmpdir
   tar xvf $Hhttp_package
   cd `ls -d httpd-2.*`
   cd srclib
   tar xzvf /root/packages/apr-1.5.2.tar.gz
   mv `ls -1d apr*`  apr
   tar xzvf /root/packages/apr-util-1.5.4.tar.gz
   mv `ls -1d apr-*` apr-util
   cd ..
   #
   /root/mode/rep_config ./server/mpm/prefork/prefork.c "#define DEFAULT_SERVER_LIMIT" 5000
   /root/mode/rep_config ./server/mpm/worker/worker.c   "#define DEFAULT_SERVER_LIMIT" 32
   /root/mode/rep_config ./server/mpm/event/event.c     "#define DEFAULT_SERVER_LIMIT" 32
   #
   /root/mode/rep_config ./server/mpm/worker/worker.c   "#define DEFAULT_THREAD_LIMIT" 128
   /root/mode/rep_config ./server/mpm/event/event.c     "#define DEFAULT_THREAD_LIMIT" 128
   #
   if ! rpm -qa | grep -E openssl-devel >/dev/null; then
      if /root/mode/.netok; then
         yum -y install openssl-devel
      fi
   fi
   #
   if rpm -qa | grep -E openssl-devel >/dev/null; then
      ./configure --prefix=/usr/local/apache$HAPACHENO --enable-so --enable-ssl --with-included-apr --with-pcre=/usr/local/pcre --enable-mods-shared=all --enable-mpms-shared=all --with-mpm=event
   else
      ./configure --prefix=/usr/local/apache$HAPACHENO --enable-so --with-included-apr --with-pcre=/usr/local/pcre --enable-mods-shared=all --enable-mpms-shared=all --with-mpm=event
   fi
   make
   make install
   HAPACHEIND=${HAPACHENO:-0}
   /root/mode/mod_config /usr/local/apache$HAPACHENO/conf/httpd.conf "Listen $[8090+$HAPACHEIND]"
else
   :
fi
cd $Hhrytmpdir
rm -fR *
}

# Install mod_jk

[ -f /usr/local/apache$HAPACHENO/modules/mod_jk.so -a -z "$HAPACHE_OVERRIDE" ] ||
{
tar xzvf `ls -1 /root/packages/tomcat-connectors-1.2.* | tail -n 1`
cd `ls -d tom*src`/native
./configure -with-apxs=/usr/local/apache$HAPACHENO/bin/apxs
make
cp -f ./apache-2.0/mod_jk.so /usr/local/apache$HAPACHENO/modules
cd $Hhrytmpdir
rm -fR *
}

# Install mod_bw

[ -f /usr/local/apache$HAPACHENO/modules/mod_bw.so -a -z "$HAPACHE_OVERRIDE" ] ||
{
tar xzvf /root/packages/mod_bw-0.92.tgz
if /root/mode/apachectl apache$HAPACHENO -v | grep -E 'Apache/2\.4' >/dev/null; then
   cat mod_bw.c | sed -re "s/remote_addr/client_addr/g" | sed -re "s/remote_ip/client_ip/g" > /root/mode/tmp/Hmod_bw$$.tmp
   mv -f /root/mode/tmp/Hmod_bw$$.tmp mod_bw.c
fi
/usr/local/apache$HAPACHENO/bin/apxs -i -a -c mod_bw.c
cd $Hhrytmpdir
rm -fR *
}

# Install Apache-ant

[ -d /usr/local/ant ] ||
{
unzip -o /root/packages/apache-ant-1.8.2.zip
mv `ls -d apache-*` ant
mv ant /usr/local
rm -fR *
unzip -o /root/packages/svnant-1.3.0.zip
mv `ls` svnant
cp -fR svnant/lib/ /usr/local/ant
cd $Hhrytmpdir
rm -fR *
}

# ---------------------------------------
# set PATH               -- 2012-12-21 --
# ---------------------------------------

/root/mode/setpath

# configure apaches etc.

/root/mode/config_apache apache$HAPACHENO

# configure tomcats

/root/mode/config_tomcat

# antdep

[ -d /root/antDep ] ||
{
cd /
tar xzvf /root/packages/antdep.tar.gz
cd $Hhrytmpdir
rm -fR *
}

# install gcserver 

/root/mode/inst_gcserver

# delete tmp file and directory

cd /root/mode
rm -fR $Hhrytmpdir

# end

echo "Installation completed successfully!!"
 

