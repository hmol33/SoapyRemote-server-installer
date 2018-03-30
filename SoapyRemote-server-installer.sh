#Compiling SoapySDR and SoapyRemote requires installing git, gcc, g++, make and cmake:
# Debian / Ubuntu:
sudo apt-get install git gcc g++ make cmake

# Red Hat / Fedora:
#dnf install git gcc gcc-c++ make cmake

#Compile and install SoapySDR library and utilities:
git clone https://github.com/pothosware/SoapySDR.git
cd SoapySDR
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig #needed on debian systems

#Install SDR hardware drivers for your SDR: (RTL-SDR in this example)
# Debian / Ubuntu:
sudo apt-get install rtl-sdr librtlsdr-dev

# Red Hat / Fedora:
dnf install rtl-sdr rtl-sdr-devel

#Compile and install SoapySDR adapter module for your SDR hardware: (RTL-SDR in this example, each module is in a separate repository, see the list of GitHub repositories for Pothosware)
#https://github.com/pothosware/
git clone https://github.com/pothosware/SoapyRTLSDR.git
cd SoapyRTLSDR
mkdir build
cd build
cmake ..
make
sudo make install

#Check that SoapySDR can find and access your SDR hardware:
SoapySDRUtil --probe

#Compile and install SoapyRemote:
git clone https://github.com/pothosware/SoapyRemote.git
cd SoapyRemote
mkdir build
cd build
cmake ..
make
sudo make install

#Start SoapyRemote server:
# Bind to all interfaces in default port 55132
SoapySDRServer --bind

# Bind to a specific IP address and port
#SoapySDRServer --bind="0.0.0.0:1234"
