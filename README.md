# Gigabyte Grove – GOES Processor (Linux)

<!-- GIGABYTE GROVE REPOSITORY BADGES START -->
<p align="center">
  <a href="https://github.com/gigabytegrove/goes-processor-linux"><img alt="GitHub repository" src="https://img.shields.io/badge/GitHub-Repository-181717?logo=github&logoColor=white"></a>
  <a href="https://github.com/gigabytegrove/goes-processor-linux/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/gigabytegrove/goes-processor-linux?style=flat&label=Stars&logo=github"></a>
  <a href="https://github.com/gigabytegrove/goes-processor-linux/issues"><img alt="Issues" src="https://img.shields.io/badge/Issues-View-555555?logo=github"></a>
  <a href="https://github.com/gigabytegrove/goes-processor-linux/releases"><img alt="Releases" src="https://img.shields.io/badge/Releases-View-555555?logo=github"></a>
  <a href="https://paypal.me/gigabytegrove"><img alt="Donate via PayPal" src="https://img.shields.io/badge/Donate-PayPal-0070BA?logo=paypal&logoColor=white"></a>
</p>
<p align="center">
  <a href="https://github.com/gigabytegrove/goes-processor-linux">Repository</a> · <a href="https://github.com/gigabytegrove/goes-processor-linux/stargazers">Stars</a> · <a href="https://github.com/gigabytegrove/goes-processor-linux/issues">Issues</a> · <a href="https://github.com/gigabytegrove/goes-processor-linux/releases">Releases</a> · <a href="https://paypal.me/gigabytegrove">Donate via PayPal</a>
</p>
<!-- GIGABYTE GROVE REPOSITORY BADGES END -->

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

## Support Gigabyte Grove

If this project is useful to you, you can support ongoing Gigabyte Grove development with an optional [PayPal donation](https://paypal.me/gigabytegrove). Donations are appreciated but never required to use this repository.
