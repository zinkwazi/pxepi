# pxepi  
Script to enable PXE boot on Raspberry Pi 4  
  
Tested on Raspberry Pi 4 Model B Rev 1.1 running Raspbian GNU/Linux 10 (buster)  
  
Run updates first:  
sudo apt update  
sudo apt full-upgrade -y

Install Git:  
sudo apt install git
  
Usage:  
git clone https://github.com/zinkwazi/pxepi.git  
cd pxepi  
sudo ./pxepi.sh  

Now your Raspberry Pi 4 will PXE boot if there is no SD card present!
