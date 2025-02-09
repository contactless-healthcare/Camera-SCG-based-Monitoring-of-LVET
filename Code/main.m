
clc
clear
close all

%% Parameter Initialization
low_fps = 250; % Video frame rate
high_fps = 1000; % Upsampling frequency
startPointTh = 0.02; % Threshold for detecting start points
envelopeWinLen = 20; % Window length for envelope calculation
AOSearchWinLen = 200; % Search window length for AO detection
ACSearchWinLen = 76; % Search window length for AC detection
videoPath = "..\video\laser_speckle_1.avi";
video = VideoReader(videoPath);
duration = video.Duration;

%% Extract LSM-LF and LSM-HF from LSM
LSM = extractLSM(video, low_fps); % Extract LSM signal from video
LSM_LF_250 = getLSM_LF(LSM, low_fps); % Extract low-frequency LSM at 250 Hz
LSM_HF_250 = getLSM_HF(LSM, low_fps); % Extract high-frequency LSM at 250 Hz
[p, q] = rat(high_fps / low_fps);
LSM_LF_1000 = resample(LSM_LF_250, p, q); % Resample to 1000 Hz
LSM_HF_1000 = resample(LSM_HF_250, p, q); % Resample to 1000 Hz

%% Search Window Localization
envelope = movstd(LSM_HF_1000, envelopeWinLen); % Envelope calculation
[sPoints_nearAO, sPoints_nearAC] = findStartPoints(envelope, high_fps, startPointTh);  % Find start points


%% plot LSM-LF、LSM-HF、and starting points.
figure
subplot(2, 1, 1)
plot(LSM_HF_1000)
hold on
plot(LSM_LF_1000 + 1)
hold on
scatter(sPoints_nearAO, LSM_HF_1000(sPoints_nearAO), 30, [1 0.5 0.5], "filled")
hold on
scatter(sPoints_nearAC, LSM_HF_1000(sPoints_nearAC), 30, [0.5 1 0.5], "filled")

%% Extract LVET
startPointsNum = length(sPoints_nearAO);
LVETnum = startPointsNum;
LVETs = zeros(startPointsNum, 1);
timestamps = zeros(startPointsNum, 1);
for i = 1 : startPointsNum
    left = max(1, sPoints_nearAO(i) - AOSearchWinLen); % Left boundary of the beat
    right = min(left + round(high_fps / 3 * 2), length(LSM_LF_1000)); % Right boundary of the beat
    AOSearchWin = [max(left, sPoints_nearAO(i) - AOSearchWinLen / 2), ...
        min(right, sPoints_nearAO(i) + AOSearchWinLen / 2)]; % Define AO search window

    ACSearchWin = [max(left, sPoints_nearAC(i) - ACSearchWinLen / 2), ...
        min(right, sPoints_nearAC(i) + ACSearchWinLen / 2)]; % Define AC search window
    beats = LSM_LF_1000(left:right);  % Extract segment for beat analysis
    % Adjust search window index
    AOSearchWin = AOSearchWin - left + 1;
    ACSearchWin = ACSearchWin - left + 1;
    [AO, AC] = searchAOandAC(beats, AOSearchWin, ACSearchWin, high_fps);
    hold on
    scatter(AO + left - 1, LSM_LF_1000(AO + left - 1) + 1, 30, [1 0.5 0.5], "filled") % Mark AO
    hold on
    scatter(AC + left - 1, LSM_LF_1000(AC + left - 1) + 1, 30, [0.5 1 0.5], "filled") % Mark AC

    LVETs(i) = (AC - AO) * (1000 / high_fps);  % Compute LVET in milliseconds
    timestamps(i) = (AC + left - 1) / high_fps;
end

%% Remove outliers
meanLVET = mean(LVETs);
stdLVET = std(LVETs);
validLVETnum = 0;
validLVET = zeros(startPointsNum, 1);
validLVETTimestamp = zeros(startPointsNum, 1);
for i = 1 : LVETnum
    if abs(LVETs(i) - meanLVET) < 3 * stdLVET  % Check if within 3-sigma range
        validLVETnum = validLVETnum + 1;
        validLVET(validLVETnum) = LVETs(i);
        validLVETTimestamp(validLVETnum) = timestamps(i);
    end
end
validLVET = validLVET(1:validLVETnum);
validLVETTimestamp = validLVETTimestamp(1:validLVETnum);
validLVET = [validLVET(1), validLVET', validLVET(validLVETnum)];  % Interpolation preparation
validLVETTimestamp = [0, validLVETTimestamp', duration];
t = 0:0.1:duration;
finalLVETs = interp1(validLVETTimestamp, validLVET, t, 'spline'); % Interpolate LVET values

%% Plot final LVET curve
subplot(2, 1, 2)
plot(t, finalLVETs, "Color", [30, 144, 255] / 255, 'LineWidth', 2)
title("LVET Mintoring")
ylabel("LVET (ms)")
xlabel("t (s)")
