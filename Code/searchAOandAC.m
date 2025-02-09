function [AO, AC] = searchAOandAC(LSM_LF, AOSearchWin, ACSearchWin, fps)
% searchAOandAC - Searches for the AO and AC within specified search windows
% in the low-frequency LSM signal (LSM_LF).
%
% Inputs:
%   LSM_LF - Low-frequency component of the Laser Speckle Motion.
%   AOSearchWin - Search window for AO, defined as a range [start, end].
%   ACSearchWin - Search window for AC, defined as a range [start, end].
%   fps - Frames per second (sampling rate of the LSM_LF signal).
%
% Outputs:
%   AO - Index of the detected AO within the search window.
%   AC - Index of the detected AC within the search window.

%% search AC
from = ACSearchWin(1);
to = ACSearchWin(2);
if to - from >= 3
    [~, peaks1] = findpeaks(LSM_LF(from:to));
    [~, peaks2] = findpeaks(-LSM_LF(from:to));
    peaks1 = peaks1  + from - 1;
    peaks2 = peaks2  + from - 1;
    peaks = [peaks1 peaks2 to];
    peaks = sort(peaks);
    AC = peaks(1);
    Max = - 1;
    for p = 1 : length(peaks) - 1
        val = LSM_LF(peaks(p)) - LSM_LF(peaks(p+1));
        if val > Max
            Max = val;
            AC = peaks(p);
        end
    end
else
    AC = (from + to) / 2;
end


%% search AO
step = 40;
from = AOSearchWin(1);
to = AOSearchWin(2);
[~, AO] = max(LSM_LF(from:to));
AO = AO + from - 1;
LVET = (AC - AO) * 1000 / fps;
while (LVET < 240 || LVET > 400) && to > from
    if LVET < 240
        to = max(to - step, from);
    else
        from = min(from + step, to);
    end
    [~, AO] = max(LSM_LF(from:to));
    AO = AO + from - 1;
    
    LVET = (AC - AO) * 1000 / fps;
end
end
