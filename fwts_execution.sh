#!/bin/bash

# install required packages to compile and build fwts tool
sudo apt-get install -y autoconf automake libglib2.0-dev libtool libpcre3-dev libjson* flex bison dkms libfdt-dev device-tree-compiler python-pip
if [ $? == 0 ]; then
        echo "Required packages are installed";
else
	echo "Required packages installation failed";
        exit $?;
fi

pip install pyparsing
if [ $? == 0 ]; then
        echo "python package pyparsing installed";
else
        exit $?;
fi

WORKDIR="/tmp"
# clone FWTS source into working directroy
if [ -d $WORKDIR"/fwts" ]; then
	rm -rf $WORKDIR/fwts
fi

git clone git://kernel.ubuntu.com/hwe/fwts.git $WORKDIR/fwts
if [ $? == 0 ]; then
	echo "FWTS Source is cloned";
else
	echo "Cloning FWTS source is failed";
	exit $?;
fi

# Clone skiboot source to generate olog.json file
if [ -d $WORKDIR"/skiboot" ]; then
        rm -rf $WORKDIR"/skiboot"
fi

git clone https://github.com/open-power/skiboot $WORKDIR/skiboot
if [ $? == 0 ]; then
        echo "skiboot Source is cloned";
else
	echo "Cloning Skiboot is failed";
        exit $?;
fi

# Generate olog json file
mkdir -p /usr/local/share/fwts/
$WORKDIR/skiboot/external/fwts/generate-fwts-olog $WORKDIR/skiboot/ -o /usr/local/share/fwts/olog.json 
if [ $? == 0 ]; then
        echo "Generated the olog.json file for OLOG test";
else
        echo "Generation of olog.json file from skiboot is failed";
        exit $?;
fi

cd $WORKDIR/fwts
autoreconf -ivf
./configure
if [ $? == 0 ]; then
        echo "Configuration is finished successfully";
else
	echo "Configuration is failed"
        exit $?;
fi

make
if [ $? == 0 ]; then
        echo "Compilation finished successfully";
else
	echo "Compilation is failed"
        exit $?;
fi
cd $WORKDIR/fwts/src
./fwts
if [ $? == 0 ]; then
	cat results.log
	echo "All the FWTS tests are passed";
else
	echo "one or more FWTS tests are failed"
	cat results.log
	exit $?;
fi
