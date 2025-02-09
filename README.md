# Camera Seismocardiogram based Monitoring of Left Ventricular Ejection Time

This repository contains the code and data associated with the paper "**Camera Seismocardiogram based Monitoring of Left Ventricular Ejection Time**."

## Overview

This study introduces a novel method to extract the Left Ventricular Ejection Time (LVET) from laser speckle videos recorded using a remote camera. The approach is based on the principle of defocused speckle imaging, allowing for non-contact monitoring of LVET. The code provided in this repository enables the extraction of both low-frequency components of laser speckle motion (LSM-LF), which are considered SCG signals, and high-frequency components of laser speckle motion (LSM-HF). These components are used for detecting the AO (Aortic Valve Opening) and AC (Aortic Valve Closure) markers within LSM-LF.

## Data Description

The dataset consists of data collected from 21 subjects, with each subject’s data acquisition session lasting approximately 8 minutes. The **Camera-SCG** dataset includes data from these 21 subjects, resulting in a total of 9616 entries. Each entry contains the following components:

- **LSM-LF**: Low-frequency component of  laser speckle motion, representing SCG signals.
- **LSM-HF**: High-frequency component of laser speckle motion.
- **AO**: Aortic Valve Opening marker.
- **AC**: Aortic Valve Closure marker.
- **LVET**: Left Ventricular Ejection Time.
- **Subject ID**: Identifier for each subject.



## Note

The code we provide can extract LVET from laser speckle video. However, the video file is too large to upload to GitHub. Instead, we have uploaded the extracted LSM signals, which are stored in the **LSM** folder. If you need the original laser speckle video, please feel free to contact us.
