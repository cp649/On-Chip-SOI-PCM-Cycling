# On-Chip-SOI-PCM-Cycling

This is a set of MATLAB scripts to control a Keithley 2200-60-2 and an Agilent function generator 33250 A via USB along with data collection from a Thorlabs DCC1645C-HQ or an AmScope autofocus camera AF205 (via taking screenshots). The file Waveform_main can be used to collect data from an osciloscope (testd on DPO 2014 Tektronix).
The control of the instruments using SCPI code is likely to be easily adaptable to other SCPI controlled instruments. All these scripts serve as an initial point for automating a setup used to test on-chip phase change material electro-thermal (Joule heating) cycling. This code is offered with no guarantees. Additionally, an LTSpice file with the circuit diagram of the system to send large voltage pulses (e.g. > 30 V but below 60 V) is attached. 

Initial attempts to control the Thorlabs camera were based on the code from mdaddysman "https://github.com/mdaddysman/Thorlabs-CMOS-USB-cameras-in-Matlab" but subsequent attempts were based on the from the manual provided by Thorslab (https://www.thorlabs.com/thorProduct.cfm?partNumber=DCC1645C) Thorlab control files are from the link above. Latest version of the main file v2p1.  

Initial building blocks for the control of the Agilent function generator were obtained from the published code by Justinas Lialys on 2 Aug 2020 (https://www.mathworks.com/matlabcentral/answers/574126-agilent-33250a-function-generator-how-to-get-the-waveform-via-serial-port)
