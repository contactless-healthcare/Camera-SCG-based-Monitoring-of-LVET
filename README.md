# Camera Seismocardiogram based Monitoring of Left Ventricular Ejection Time

This repository contains the code and data associated with the paper "**Camera Seismocardiogram based Monitoring of Left Ventricular Ejection Time**."

## Overview

This study introduces a novel method to extract the Left Ventricular Ejection Time (LVET) from laser speckle videos recorded using a remote camera. The approach is based on the principle of defocused speckle imaging, allowing for non-contact monitoring of LVET. 

The code provided in this repository enables the extraction of both low-frequency components of laser speckle motion (LSM-LF), which are considered SCG signals, and high-frequency components of laser speckle motion (LSM-HF). These components are used for detecting the AO (Aortic Valve Opening) and AC (Aortic Valve Closure) markers within LSM-LF.

## Data Description

The dataset consists of data collected from 21 subjects, with each subject’s data acquisition session lasting approximately 8 minutes. The **Camera-SCG** dataset includes data from these 21 subjects, resulting in a total of 9616 entries. Each entry contains the following components:

- **LSM-LF**: Low-frequency component of laser speckle motion, representing SCG signals.
- **LSM-HF**: High-frequency component of laser speckle motion.
- **AO**: Aortic Valve Opening marker.
- **AC**: Aortic Valve Closure marker.
- **LVET**: Left Ventricular Ejection Time.
- **Subject ID**: Identifier for each subject.

You can [download the Camera-SCG Dataset here](https://drive.google.com/drive/folders/1VhCjseavQeNnNFAyH8BwM35IAeQz8zg4?usp=drive_link).



## Code Description

Running the `main.m` script allows you to extract the LVET curve from laser speckle videos, along with the corresponding LSM-HF, LSM-LF components, and their starting points, as well as the AO and AC markers. To analyze a different video, you can modify the `videoPath` variable in the script to point to the desired video file.  

We have provided three test videos that you can download and use for testing the script. Click the link below to download the test videos: [Download Test Videos](https://drive.google.com/drive/folders/1czBqZRZB97kIS8KjLWM5tkY_uvVdwBn-?usp=drive_link)

