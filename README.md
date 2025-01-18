# ADS-B Signal Processing and Real-Time Aircraft Tracking

![Tache_6_trajectoire](https://github.com/user-attachments/assets/93fc45bd-3bb7-43b8-b4b3-6170ed562239)
<img width="1011" alt="msg_pos_vol" src="https://github.com/user-attachments/assets/d591b058-747a-4f2b-ae63-fe93d928c47c" />


## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [System Architecture](#system-architecture)
- [ADS-B Overview](#ads-b-overview)
- [Objectives](#objectives)
- [Implementation Details](#implementation-details)
  - [Signal Modulation and Simulation](#signal-modulation-and-simulation)
  - [Synchronization and Decoding](#synchronization-and-decoding)
  - [Real Signal Processing](#real-signal-processing)
- [Project Setup](#project-setup)
- [Results and Visualizations](#results-and-visualizations)
- [Future Enhancements](#future-enhancements)
- [Contributors](#contributors)

---

## Overview

This project implements an **Automatic Dependent Surveillance-Broadcast (ADS-B)** receiver system for decoding aircraft signals in the **1090 ES (Extended Squitter)** mode. Through MATLAB, the system simulates ADS-B signal transmission and reception, ensuring real-time decoding of aircraft trajectories, velocities, and identifiers.

ADS-B plays a critical role in modern aviation, enabling real-time tracking of aircraft and enhancing airspace safety by broadcasting precise position and velocity information.

---

## Features

- **ADS-B Transmitter/Receiver Simulation**:
  - Full ADS-B signal generation and decoding within MATLAB.
- **Message Decoding**:
  - Extraction of aircraft position, velocity, altitude, and OACI (ICAO) identifiers.
- **Synchronization Algorithms**:
  - Robust handling of time and frequency synchronization.
- **Error Detection and Correction**:
  - CRC-24 integration for ADS-B message verification.
- **Real Signal Processing**:
  - Decoding of real-world ADS-B messages captured via software-defined radio (SDR) systems.
- **Trajectory Visualization**:
  - Dynamic visualization of aircraft movements in real-time.

---

## Technologies Used

### **Software**
- MATLAB: Signal simulation, synchronization, and decoding.
- Welch Periodogram: Used for estimating Power Spectral Density (PSD).

### **Communication Standards**
- ADS-B 1090 ES protocol as defined by the ICAO (International Civil Aviation Organization).

### **Signal Processing**
- **Pulse Position Modulation (PPM)**: Core modulation technique for ADS-B.
- **Synchronization Algorithms**:
  - Cross-correlation for preamble detection.
  - Doppler correction for frequency shifts.

---

## System Architecture

The ADS-B system architecture is divided into the following layers:

1. **Signal Modulation and Transmission**:
   - Encodes ADS-B messages using Pulse Position Modulation (PPM).
   - Simulates the transmission over noisy channels.

2. **Receiver and Synchronization**:
   - Detects ADS-B preamble using cross-correlation.
   - Applies time and frequency synchronization.

3. **Message Decoding**:
   - Extracts aircraft metadata (e.g., position, velocity, altitude) from received signals.

4. **Visualization and Analysis**:
   - Displays real-time aircraft trajectories and other data.

---

## ADS-B Overview

ADS-B is an air traffic surveillance technology where aircraft broadcast their position, altitude, and velocity using radio waves. The 1090 MHz frequency band (1090 ES) is widely used for long-range communication.

**Advantages**:
- Improved air traffic management.
- Enhanced situational awareness for pilots.
- Real-time position sharing among aircraft.

---

## Objectives

1. Simulate the ADS-B signal generation and decoding process in MATLAB.
2. Develop robust algorithms for:
   - Time synchronization.
   - Frequency synchronization (Doppler correction).
3. Decode real-world ADS-B messages captured using SDR systems.
4. Visualize aircraft trajectories in real-time.

---

## Implementation Details

### Signal Modulation and Simulation
- **Pulse Position Modulation (PPM)**:
  - Encoded ADS-B signals using PPM.
  - Simulated signal transmission through noisy channels.
- **Power Spectral Density (PSD)**:
  - Used Welch Periodogram to compare theoretical and simulated PSDs.

### Synchronization and Decoding
- **Preamble Detection**:
  - Detected ADS-B messages using cross-correlation.
- **Error Detection**:
  - Implemented CRC-24 checksum for message validation.
- **Message Decoding**:
  - Extracted ICAO address, position, and velocity from ADS-B signals.

### Real Signal Processing
- Applied the developed system to real ADS-B data.
- Decoded and plotted aircraft trajectories.

---

## Project Setup

### Prerequisites
- MATLAB (R2021a or later)
- ADS-B signal datasets (`adsb_msgs.mat` and `buffers.mat`)

### Steps
1. Load the provided `.mat` files into MATLAB.
2. Open the MATLAB scripts (`Tache_1.m`, `Tache_4.m`, etc.).
3. Run the scripts in sequence to simulate and decode ADS-B signals.

---

## Results and Visualizations

### Power Spectral Density (PSD)
- The Welch Periodogram showed excellent alignment between theoretical and experimental PSD.

### Trajectory Visualization
- The system dynamically visualized aircraft positions and movements in 2D space.

---

## Future Enhancements

- **Machine Learning Integration**:
  - Use ML algorithms to improve error correction.
- **3D Visualization**:
  - Implement 3D plotting for aircraft trajectories.
- **Real-Time Implementation**:
  - Deploy the system on SDR platforms for live tracking.

---

## Contributors

- **Mehdi Khabouze**: Developer

---

## Screenshots
### Time synchronisation
![synchro_tempo](https://github.com/user-attachments/assets/52b014ae-ad44-4ade-8994-bf3ac983c064)
### Power Spectral Density
![DSP](https://github.com/user-attachments/assets/8751fbc1-2224-4aa5-bf91-9d6d7edb180f)
### Trajectories
![Tache_6_trajectoire](https://github.com/user-attachments/assets/93fc45bd-3bb7-43b8-b4b3-6170ed562239)
### Some Decoded ADSB messages
<img width="1011" alt="msg_pos_vol" src="https://github.com/user-attachments/assets/d591b058-747a-4f2b-ae63-fe93d928c47c" />
<img width="1021" alt="pos_sol" src="https://github.com/user-attachments/assets/6d0ab4b2-abb5-43cb-bf9a-5e76ed95ae02" />
<img width="1020" alt="msg_id" src="https://github.com/user-attachments/assets/31dd23b5-a4d2-4b05-9f3e-037444cba3e4" />





