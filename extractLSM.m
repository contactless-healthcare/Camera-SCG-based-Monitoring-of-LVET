function LSM = extractLSM(video, fps)
% extractLSM - Extracts Laser Speckle Motion (LSM) signal from a video.
%
% Inputs:
%   video - VideoReader object containing the video to be processed.
%   fps - Frames per second of the video.
%
% Outputs:
%   LSM - Extracted Laser Speckle Motion (LSM) signal.

Dx = [];
Dy = [];

duration = video.Duration;
time = floor(duration);    % signal length

time_start = 0;


iframe = fps*time_start+1;
nframe = fps*time-1;
% read the first frame
frame = read(video, 1);
frame = frame(:, :, 2);


%% automatically select ROI
% Using edge detection to find ROI
edges = edge(frame, 'Canny');
se = strel('square', 3); 
filledEdges = imdilate(edges, se); 
filledEdges = imfill(filledEdges, 'holes'); 
filledEdges = imerode(filledEdges, se); 
[labels, ~] = bwlabel(filledEdges);
largestBlob = bwareafilt(logical(labels), 1, 'largest');

% Obtain the bounding box of ROI
stats = regionprops(largestBlob, 'BoundingBox');
roi = stats.BoundingBox;

% %% manually select ROI
% imshow(frame);
% title('Please select ROI')
% roi = drawrectangle('Color', [1 0.1 0.1]);
% roi = floor(roi.Position);
% close(gcf);

%% optical flow
opticFlow = opticalFlowFarneback("NumPyramidLevels",5);

h = waitbar(0, 'please wait ...');
for idx = iframe : iframe+nframe
    % select ROI
    frame = read(video, idx);
    frame = frame(:, :, 2);
    frame = frame(ceil(roi(2)):floor(roi(2))+floor(roi(4)), ceil(roi(1)):floor(roi(1))+floor(roi(3)),:);

    % Estimate the optical flow of two video frames
    flow = estimateFlow(opticFlow,frame);

    % calculate (dx, dy)
    dx = mean2(double(flow.Vx));
    dy = mean2(double(flow.Vy));

    Dx = [Dx, dx];
    Dy = [Dy, dy];
    waitbar((idx - iframe + 1) / nframe, h, sprintf("Progress of optical flow: %d/%d", idx - iframe + 1, nframe));
end
close(h)
%% motion synthesis
LSM = motion_synthesis(Dx, Dy, time, fps);
end