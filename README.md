# Server Log Analyzer

![Bash](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

A powerful Bash script for analyzing web server access logs with comprehensive reporting capabilities.

## Features

- 📊 Request statistics (GET/POST counts, totals)
- 🕵️ IP address analysis (unique IPs, most active users)
- ⚠️ Failure detection (4xx/5xx errors with percentages)
- 📅 Temporal analysis (daily averages, hourly patterns)
- 📝 Automatic report generation

## Usage

1. Place your `access.log` file in the same directory
2. Run the analyzer:
   ```bash
   chmod +x log_analysis.sh
   ./log_analysis.sh
