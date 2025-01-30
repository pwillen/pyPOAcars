# pyPOAcars
## Overview
An application to demodulate and decode Plain Ol` Acars

## About
- Last Stable Build: Never
- Current Build: None
- Last Release Candidate: None

## Features
- Demodulate ACARS from iq file: `src.acars.demod`
- Decode demodulated ACARS: `src.acars.parse_acars_message`
- libacars integration to be implemented
- An array of other DSP modules 

### Supported Protocols
- Plain Ol` ACARS i.e. MSK modulated 129 MHz - 137 MHz Frequencies

## Setup and Installation
### Pre-requisites
- Python 3.12.8
### Dependencies
poetry install

## Usage
So far I only have a basic python script `local_test.py` that reads an iq file and demodulates it.
I will look into creating a CLI for usage. Something like: `python3 -m poacars -i iq_file -o output_file`.
I will also look into making the project pip installable.

## Credits
- J.-M Friedt and https://sourceforge.net/projects/gr-acars/. This project is the python equivalent of the gr-acars c code
- Dr. Marc Lichtman and https://pysdr.org/ for insight into DSP with Python

## Contributing
### How to contribute
1. Clone the repository
2. install the dependencies by running `poetry install`

## Submitting Changes
1. Create and checkout a new branch `feature/your_feature`
2. Commit your changes with descriptive commit messages
3. Push your changes to your branch
4. Submit a pull request to the main branch of the repository

## Project Status
This is a for fun project. There is no guarantee on updates, the usage, correctness or stability of the project.
