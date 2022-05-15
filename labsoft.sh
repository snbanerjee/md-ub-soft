#******************* README ************************#
#This script is used to install MD related software #
#This script to be run in root account without any  # 
#options unless specified or needed                 #
#Version: 1.0			                    #
#First Release: 14-May-2022		            #
#Author: Mr. S N Banerjee                           #
#How to run: ./<script file name>		    #
#Where to run: IITGN Computer Lab | Ubuntu System   #
#Logs: /tmp/script.log				    #
#For any error: report to helpdesk.istf@iitgn.ac.in #
#***************** End of README *******************#

#!/bin/bash

### Log will be written in script.log under /tmp directory###
touch /tmp/script.log
Loc=/tmp/script.log

### Declaration of Global Variables ###
Date=`date`
echo Machine date is $Date > $Loc
echo " " >> $Loc
mast=`hostname`
echo Machine hostname is $mast >> $Loc
echo " " >> $Loc
Proc=`cat /proc/cpuinfo | grep processor | wc -l`
np=`expr $Proc - 2` ### reducing overhead on resources
echo Number of Processors in the system is $Proc >> $Loc
echo " " >> $Loc
echo Number of Cores to be used during Compilation is $np >> $Loc
INSTALL_USER=`whoami`
ENV_USER=`cat /etc/passwd | grep bash | awk '(NR>1)' |  sed s/:/\\n/ | awk '{print $1; exit}'`
ENV_USER_PATH=/home/$ENV_USER/.bashrc
OS=`lsb_release -d | awk '{print $2}'`
echo " " >> $Loc
echo Machine OS is $OS >> $Loc
echo " " >> $Loc
cd /opt
rm -rf apps
mkdir -p /opt/apps
chmod -R 777 /opt/apps
DIR=/opt/apps
cd /opt/apps



### Checking whether 32 or 64 bit Arch ###
march=`getconf LONG_BIT`
if [ "$march" == "64" ]
then
        {
                echo Machine Arch is $march bit >> $Loc
        }
else
        {
                echo Machine Arch is 32 bit >> $Loc
        }
fi

echo " " >> $Loc

sleep 1



### Checking whether running from Root account or not ###
ID=`id | grep root`
ver1=`echo $?`
if [ "$ver1" != "0" ]
then
	{
		echo Warning: Please Login to root account and proceed >> $Loc;exit 1;
	}
else
	{
		echo Super admin account is used...Good to go...please wait.. >> $Loc
	}
fi

echo " " >> $Loc

sleep 1

### Checking whether system has Internet Connection with 4 packets ###
ping google.com -c 2 | grep icmp
ver2=`echo $?`
if [ "$ver2" -eq "0" ]
then
	{
		echo Internet Connection is Detected.. may proceed >> $Loc
	}
else
	{
		echo Please check your Internet Connection >> $Loc;exit 1;
	}
fi

echo " " >> $Loc

sleep 1

IPADDR=`ifconfig | grep broadcast | awk {'print $2'}`  # capturing IP Address of the system
echo The IP address of the system is $IPADDR >> $Loc
echo " " >> $Loc

sleep 1



### Updating the Ubuntu System ###
apt-get update -y
ver0=`echo $?`

if [ "$ver0" -eq "0" ]
then
        {
                echo System Updated OK.. may proceed >> $Loc
        }
else
        {
                echo System Update Failed... Please check /var/log/syslog >> $Loc;exit 1;
        }
fi

echo " " >> $Loc

sleep 1



### Checking of existance of GCC Gfortran G++ compilers ###
Gcc_version=`gcc --version`
ver3=`echo $?`
if ["$ver3" -eq "0"]
then
        {
                echo GCC version is $Gcc_version >> $Loc
        }
else
        {
                echo "Error: GCC not found in system or not declared in the environment Path. 
		Installing Gcc by issuing the command sudo apt install gcc g++ gfortran" >> $Loc
		apt install gcc g++ gfortran -y
        }
fi
ver4=`which gcc`
echo Installation of GCC done at $ver4 >> $Loc

sleep 1

echo " " >> $Loc

sleep 1

echo " " >> $Loc

### Installation of OpenSSL-Dev package ###
apt-get install -y libssl-dev

sleep 1

echo " " >> $Loc

### Checking of existance CMAKE ###
Cmake_version=`cmake --version`
ver5=`echo $?`
if ["$ver5" -eq "0"]
then
        {
                echo CMAKE version is $Cmake_version >> $Loc
        }
else
        {
                echo "Error: Cmake not found in system or not declared in the environment Path. Please install Cmake by issuing the command 
apt-get install build-essential
mkdir -p $DIR/CMAKE
cd $DIR/CMAKE
wget https://github.com/Kitware/CMake/releases/download/v3.22.4/cmake-3.22.4.tar.gz .
tar zxvf cmake-3.22.4.tar.gz
cd cmake-3.22.4
./bootstrap
make -j 4
" >> $Loc
apt-get install build-essential -y
mkdir -p $DIR/CMAKE
cd $DIR/CMAKE
wget https://github.com/Kitware/CMake/releases/download/v3.22.4/cmake-3.22.4.tar.gz .
tar zxvf cmake-3.22.4.tar.gz
cd cmake-3.22.4
./bootstrap
make -j $np
make install
        }
fi

ver6=`cmake --version`
echo Cmake version is $ver6 >> $Loc

sleep 1

echo " " >> $Loc



### Checking of existance of MAKE ###
Make_version=`make --version`
ver12=`echo $?`
if ["$ver12" -eq "0"]
then
        {
                echo MAKE version is $Make_version >> $Loc
        }
else
        {
                echo "Error: Make not found in system or not declared in the environment Path. Installing Make by issuing the command 
apt-get install make -y
" >> $Loc
        }
fi
apt install make -y

ver13=`make --version | grep Make`
echo Make version is $ver13 >> $Loc

sleep 1

echo " " >> $Loc



### Download and Install MPI ###
apt install -y openmpi-bin
ver15=`mpirun --version`
echo MPIRUN version is $ver15 >> $Loc

sleep 1

echo " " >> $Loc


### Download and Install NAMD-2.14 ###
mkdir -p $DIR/NAMD
cd $DIR/NAMD
wget https://istf.iitgn.ac.in/sites/default/files/Software/labsoft/tarballs/NAMD_2.14_Linux-x86_64-multicore.tar.gz --no-check-certificate
tar xvf NAMD_2.14_Linux-x86_64-multicore.tar.gz
cd NAMD_2.14_Linux-x86_64-multicore
export PATH=$PATH:"$DIR/NAMD/NAMD_2.14_Linux-x86_64-multicore" >> $ENV_USER_PATH
source $ENV_USER_PATH
ver7=`which namd2`
echo NAMD is installed at $ver7 >> $Loc

sleep 1

echo " " >> $Loc
cd ~



### Download and Install LAMMPS ###
mkdir -p $DIR/LAMMPS
cd $DIR/LAMMPS
wget https://download.lammps.org/tars/lammps-stable.tar.gz .
tar zxvf lammps-stable.tar.gz
cd lammps-29Sep2021
mkdir build
cd build
cmake ../cmake
cmake --build .
make install
export PATH=$PATH:"$DIR/LAMMPS/lammps-29Sep2021/build" >> $ENV_USER_PATH
source $ENV_USER_PATH

ver14=`which lmp`
echo Lammps is installed at $ver14 >> $Loc

sleep 1

echo " " >> $Loc



### Download and Install XmGRACE ###
apt install grace -y
ver8=`which xmgrace`
echo Xmgrace is installed at $ver8 >> $Loc

sleep 1

echo " " >> $Loc

cd ~



### Download and Install PACKMOL ###
apt install -y packmol
ver11=`which packmol`
echo Packmol is installed at $ver11 >> $Loc

sleep 1

echo " " >> $Loc

cd ~



### Download and Install Gromacs ###
mkdir -p $DIR/GROMACS
cd $DIR/GROMACS
wget https://ftp.gromacs.org/regressiontests/regressiontests-2021.2.tar.gz
tar xvzf regressiontests-2021.2.tar.gz
apt-get install libfftw3-dev -y
wget ftp://ftp.gromacs.org/gromacs/gromacs-2021.2.tar.gz
tar xvzf gromacs-2021.2.tar.gz
cd gromacs-2021.2
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_C_COMPILER=gcc
make -j $np
make install
export PATH=$PATH:"$DIR/GROMACS/gromacs-2021.2/build/bin" >> $ENV_USER_PATH
source $ENV_USER_PATH

ver9=`which gmx`
echo Gromacs is installed at $ver9 >> $Loc


sleep 1

echo " " >> $Loc

cd ~



### Download and Install VMD-1.9.3 ###
apt install -y tcsh
mkdir -p $DIR/VMD
cd $DIR/VMD
wget https://istf.iitgn.ac.in/sites/default/files/Software/labsoft/tarballs/vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz --no-check-certificate
tar zxvf vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz
cd vmd-1.9.3
./configure
cd src
make install
export PATH=$PATH:"$DIR/VMD/vmd-1.9.3/bin" >> $ENV_USER_PATH
source $ENV_USER_PATH
ver7=`which vmd`
echo VMD is installed at $ver7 >> $Loc

sleep 1

echo " " >> $Loc

cd ~



### Download and Install CHARMM ###
mkdir -p $DIR/CHARMM
cd $DIR/CHARMM
wget https://istf.iitgn.ac.in/sites/default/files/Software/labsoft/tarballs/charmm.tar.gz --no-check-certificate
tar zxvf charmm.tar.gz
cd charmm
./configure
make -C build/cmake install
export PATH=$PATH:"$DIR/CHARMM/charmm/bin" >> $ENV_USER_PATH
source $ENV_USER_PATH

ver10=`which charmm`
echo Charmm is installed at $ver10 >> $Loc


sleep 1

echo " " >> $Loc

cd ~



### Executing the ENV_USER_PATH ####
source $ENV_USER_PATH


### Reboot the Machine ###
#/usr/sbin/reboot

### Sending of Logs to Reviewer ###
#ps2pdf /tmp/script.log
#mutt -s "Logs for $INSTALL_USER in $mast" 
