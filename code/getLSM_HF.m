function LSM_HF = getLSM_HF(LSM, fps)
% getLSM_HF - Extracts the high-frequency component of the Laser Speckle Motion (LSM) signal.
%
% Inputs:
%   LSM - Laser Speckle Motion signal (typically containing both low and high-frequency components).
%   fps - Frames per second (sampling rate of the motion data).
%
% Outputs:
%   LSM_HF - Denoised High-frequency component of the LSM signal.

% highpass filtering
lowwidth = 50;
[ne, de] = butter(4, lowwidth/(fps/2), 'low');
LSM_low = filtfilt(ne, de, LSM')';
LSM_detrend = LSM - LSM_low;

% denoise
level = floor(log(length(LSM_detrend)) / log(2));
LSM_HF = wdenoise(LSM_detrend, level, 'DenoisingMethod', 'FDR', 'Wavelet', 'sym4');

LSM_HF = LSM_HF / max(LSM_HF);
end