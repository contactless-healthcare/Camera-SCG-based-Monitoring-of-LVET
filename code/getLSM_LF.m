function LSM_LF = getLSM_LF(LSM, fps)
% getLSM_LF - Extracts the low-frequency component of the Laser Speckle Motion (LSM) signal.
%
% Inputs:
%   LSM - Laser Speckle Motion signal.
%   fps - Frames per second (sampling rate of the motion data).
%
% Outputs:
%   LSM_LF - Denoised low-frequency component of the LSM signal.

lowwidth = 0.8;
[ne, de] = butter(4, lowwidth/(fps/2), 'low');
LSM_low = filtfilt(ne, de, LSM')';
LSM_detrend = LSM - LSM_low;

% bandpass filtering
bandwidth = [0.8, 35];
[n, d] = butter(2, bandwidth/(fps/2), 'bandpass');
LSM_band = filtfilt(n, d, LSM_detrend')';

% denoise
level = floor(log(length(LSM_band)) / log(2));
LSM_LF = wdenoise(LSM_band, level, 'DenoisingMethod', 'FDR', 'Wavelet', 'sym4');

LSM_LF = LSM_LF / max(LSM_LF);

%% Adjust the polarity of denoisedLSM
[~, posPeakLocs] = findpeaks(LSM_LF);
[~, negPeakLocs] = findpeaks(-LSM_LF);
peakLocs = sort([posPeakLocs negPeakLocs]);
posMaxDiff = 0;
negMaxDiff = 0;
for i = 1 : length(peakLocs) - 1
    if LSM_LF(peakLocs(i)) < LSM_LF(peakLocs(i + 1))
        value = LSM_LF(peakLocs(i+1)) - LSM_LF(peakLocs(i));
        if value > posMaxDiff
            posMaxDiff = value;
        end
    else
        value = LSM_LF(peakLocs(i)) - LSM_LF(peakLocs(i+1));
        if value > negMaxDiff
            negMaxDiff = value;
        end
    end
end
if negMaxDiff < posMaxDiff
    LSM_LF = -LSM_LF;
end
end