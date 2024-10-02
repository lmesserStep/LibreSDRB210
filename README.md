# LibreSDRB210 - USRP B210 Setup Guide

This repository contains essential files and instructions for setting up the USRP B210 with custom firmware on Linux. Follow the steps below to install the required drivers and replace the default B210 image with the custom one from this repository.

## Prerequisites

- Ubuntu Linux or another Debian-based distribution
- A USRP B210 LibreSDR clone (XC7A100T+AD9361 ONLY)
- Git installed on your machine

## Installation Steps

### 1. Install USRP Hardware Drivers (UHD)

First, you'll need to install the USRP Hardware Drivers (UHD) for your device.

Open a terminal and run the following commands:

```bash
$ sudo add-apt-repository ppa:ettusresearch/uhd
$ sudo apt update
$ sudo apt install libuhd-dev uhd-host
```
### Install Python3 (If not already installed)
```bash
$ sudo apt install python3
```


## Download UHD Images
Next, you need to download the UHD images used by the USRP devices. Run the following command to install the images:
```bash
sudo /usr/lib/uhd/utils/uhd_images_downloader.py
```
The images will be downloaded to:
/opt/local/share/uhd/images

## Replace the B210 Image

Replace the default B210 image in /opt/local/share/uhd/images with the custom image provided in this repository.
```bash
Clone this repository to your local machine:
git clone git@github.com:lmesserStep/LibreSDRB210.git
sudo cp <path_to_repo>/custom_b210_image.bin /opt/local/share/uhd/images/
```

## Verify

```bash
$ uhd_usrp_probe
[INFO] [UHD] Mac OS; Clang version 15.0.0 (clang-1500.1.0.2.5); Boost_107100; UHD_3.15.0.0-MacPorts-Release
[INFO] [B200] Detected Device: B210
[INFO] [B200] Loading FPGA image: /opt/local/share/uhd/images/usrp_b210_fpga.bin...
[INFO] [B200] Operating over USB 3.
[INFO] [B200] Detecting internal GPSDO.... 
[INFO] [GPS] No GPSDO found
[INFO] [B200] Initialize CODEC control...
[INFO] [B200] Initialize Radio control...
[INFO] [B200] Performing register loopback test... 
[INFO] [B200] Register loopback test passed
[INFO] [B200] Performing register loopback test... 
[INFO] [B200] Register loopback test passed
[INFO] [B200] Setting master clock rate selection to 'automatic'.
[INFO] [B200] Asking for clock rate 16.000000 MHz... 
[INFO] [B200] Actually got clock rate 16.000000 MHz.
```

Any of the changes needed will require Vivado, this is a working bin. Please note, this has been tested on versions 4.0-7.0 UHD from Ettus Labs. 


