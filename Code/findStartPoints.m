function [sPoints_nearAO, sPoints_nearAC] = findStartPoints(envelope, fps, th)
% findStartPoints - Identifies the starting points near AO
% and AC from the envelope of the LSM-HF signal.
%
% Inputs:
%   envelope - The envelope of the LSM-HF signal, representing the amplitude modulation over time.
%   fps - Frames per second (sampling rate of the envelope signal).
%   th - Threshold value for detecting significant changes in the signal.
%
% Outputs:
%   sPoints_nearAO - Starting points near the AO detected based on threshold.
%   sPoints_nearAC - Starting points near the AC detected based on threshold.

staPoints = zeros(length(envelope), 1);
checkWindowLen = fps / 30;
pointCnt = 0;
j = 1;
flag = true;
cntGth = 0; % Count the number of consecutive points that exceed the threshold
cntLth = 0; % Count the number of consecutive points that below the threshold
fromGth = 0;
while j < length(envelope)
    windowStd = envelope(j);
    if windowStd >= th
        cntGth = cntGth + 1;
        cntLth = 0;
        if cntGth == 1
            fromGth = j;
        end
    else
        cntGth = 0;
        cntLth = cntLth + 1;
    end
    if flag && cntGth >= checkWindowLen
        pointCnt = pointCnt + 1;
        staPoints(pointCnt) = fromGth;
        flag = false;
    end
    if ~flag && cntLth >= checkWindowLen
        flag = true;
    end
    j = j + 1;
end
staPoints = staPoints(1:pointCnt);

%% Roughly estimate the heartbeat interval
tempR_Rs = staPoints;
cntBeats = 0;
for i = 3 : 2 : length(staPoints)
    cntBeats = cntBeats + 1;
    tempR_Rs(cntBeats) = staPoints(i) - staPoints(i-2);
end
tempR_Rs = tempR_Rs(1:cntBeats);
R_Rsum = 0;
R_Rcnt = 0;
Mean = mean(tempR_Rs);
Std = std(tempR_Rs);
for i = 1 : length(tempR_Rs)
    if abs(tempR_Rs(i) - Mean) < Std
        R_Rsum = R_Rsum + tempR_Rs(i);
        R_Rcnt = R_Rcnt + 1;
    end
end
R_R = R_Rsum / R_Rcnt;

sPoints_nearAO = zeros(length(staPoints), 1);
sPoints_nearAC = zeros(length(staPoints), 1);
cntBeats = 0;
for i = 2 : length(staPoints)
    % Determine whether it is the starting point near AO based on the interval between adjacent points
    if staPoints(i) - staPoints(i-1) < R_R / 2 && (cntBeats == 0 || staPoints(i-1) - sPoints_nearAC(cntBeats) > R_R / 2)
        cntBeats = cntBeats + 1;
        sPoints_nearAO(cntBeats) = staPoints(i-1);
        sPoints_nearAC(cntBeats) = staPoints(i);
        i = i + 2;
    end
end
sPoints_nearAO = sPoints_nearAO(1:cntBeats);
sPoints_nearAC = sPoints_nearAC(1:cntBeats);
end
