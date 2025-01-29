# ACARS SPECIFICATIONS
from https://www.wavecom.ch/content/ext/DecoderOnlineHelp/default.htm#!worddocuments/acars.htm
- FREQUENCY RANGE (Transmit Frequency): VHF ~ 130 MHz
- NRZI ENCODING
- AM, MSK MODULATION
- SYMBOL RATE: 2400 baud
- CENTER FREQUENCY: 1800 Hz
- FREQUENCY SHIFT: 1200 Hz
For MSK modulation the modulating frequencies are fc +/- bd/4
For ACARS the modulating frequencies are 1800 +/- 600 Hz i.e. 1200 Hz and 2400 Hz
- BW 3kHz
BW is likely 3Kz because fh is 2400Hz or (fh - fl) * 2 = 2400Hz
# ACARS MESSAGE STRUCTURE
First bit is parity. In practice, we pack 7 bits and ignore the parity bit, so we want to look for these hex values or their ASCII representation
PREKEY = 1111111111111111

`+` = 0|0101011 = 0x2b

`*` = 0|0101010 = 0x2a

SYN = 0|0010110 = 0x16

SYN = 0|0010110 = 0x16

SOH = 0|0000001 = 0x01

DEL = 0|1111111 = x7f

ETX = 0|0000011 = x03 

PREKEY is supposedly 35ms of 2400Hz

Maximum PREKEY length is 85ms or 200 SYMBOLS according to ARNIC 618

TODO include maximum message length

Visual representation of NRZI encoding. Where the frequency indicates bit change. The high frequency means the bit stays the same and the low frequency means the bit changes

```
___________     ______
11111111111\010/000000
            ---
```
Where the top line is fh and lower line is fl.