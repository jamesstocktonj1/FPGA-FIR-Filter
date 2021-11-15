close all;


%input configuration
numTaps = 15;                   %number of taps on the filter (buffer size)
valueResolution = 15;           %the resolution of the ADC / DAC (bits)
sampleFrequency = 40000;        %sample frequency of the ADC / DAC (Hz)
cutoffFrequency = 11000;         %desired cutoff frequency (Hz)
filterType = 'low';            %low, high, bandpass, stop, DC-0, DC-1
%input configuration

%notch filter configuration
bandwidth = 5;
%notch filter configuration

cutoffConstant = cutoffFrequency / (sampleFrequency / 2);
f = fir1(numTaps - 1, cutoffConstant, filterType);


lowFreq = (cutoffFrequency - (bandwidth / 2)) / (sampleFrequency / 2);
highFreq = (cutoffFrequency + (bandwidth / 2)) / (sampleFrequency / 2);
n = fir1(numTaps - 1, [ 0.00001, 0.249, 0.251]);

disp(sprintf('%d, ', round(n * (2 ^ valueResolution))))

figure
freqz(n, 2, 1024);
grid