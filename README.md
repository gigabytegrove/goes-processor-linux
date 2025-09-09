# Gigabyte Grove – GOES Processor (Linux)

Welcome to **Gigabyte Grove's GOES Processor for Linux**! This repository contains a collection of scripts and tools for receiving, decoding, and processing NOAA GOES satellite data. These scripts are designed for hobbyists, amateur radio enthusiasts, and weather monitoring projects.

**Repository URL:** [https://github.com/Gigabyte-Grove/goes-processor-linux](https://github.com/Gigabyte-Grove/goes-processor-linux)

## Features

- **GOES Satellite Data Reception**  
  Receive live data directly from NOAA GOES satellites using SDR devices (RTL-SDR, PlutoSDR, etc.).

- **Realtime and Scheduled Decoding**  
  Supports both live reception and scheduled batch decoding of satellite signals.

- **Multiple Input Sources**  
  Supports local files, network sources, and compatible SDR servers.

- **Image and Data Extraction**  
  Convert raw satellite signals into images, or extract telemetry for analysis and alerts.

- **Integration Ready**  
  Easily integrates with weather dashboards, alert systems, or other home automation projects.

## Requirements

- Linux-based OS (tested on Ubuntu 22.04 / Raspberry Pi OS)
- Python 3.10+
- SDR hardware (RTL-SDR, PlutoSDR, etc.)
- Dependencies (install via `apt` or `pip`):
  - `numpy`, `scipy`, `matplotlib`, `pillow`
  - `rtl-sdr` tools for SDR input
  - `ffmpeg` (optional, for video compilation)
  - `sox` (optional, for audio alerts)

## Installation

Clone the repository:

```bash
git clone https://github.com/Gigabyte-Grove/goes-processor-linux.git
cd goes-processor-linux
