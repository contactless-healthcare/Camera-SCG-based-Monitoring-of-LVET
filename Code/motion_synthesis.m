function LSM = motion_synthesis(Dx, Dy, time, fps)
% motion_synthesis - Synthesizes the Laser Speckle Motion (LSM) signal
% using the motion data from Dx and Dy, based on the time and fps.
%
% Inputs:
%   Dx - Horizontal motion data (difference in X direction).
%   Dy - Vertical motion data (difference in Y direction).
%   time - Duration of the motion signal (same length as Dx and Dy, corresponds to video duration) in seconds.
%   fps - Frames per second (sampling rate of the motion data).
%
% Outputs:
%   LSM - Synthesized Laser Speckle Motion (LSM) signal based on the motion data.

time_angle = time;
%% Record the quadrant of signal dominant offset
amp_1 = 0;
amp_2 = 0;
amp_3 = 0;
amp_4 = 0;
ANGLE = [];
angle = [];

for t = 1 : time
    % Calculate the amplitude of each quadrant
    for idx = 1 : fps   %  t*fps+idx
        number = (t-1)*fps+idx;
        if Dx(number)>0 && Dy(number)>0
            amp_1 = amp_1 + sqrt(Dx(number)*Dx(number)+Dy(number)*Dy(number));
        elseif Dx(number)<0 && Dy(number)>0
            amp_2 = amp_2 + sqrt(Dx(number)*Dx(number)+Dy(number)*Dy(number));
        elseif Dx(number)<0 && Dy(number)
            amp_3 = amp_3 + sqrt(Dx(number)*Dx(number)+Dy(number)*Dy(number));
        elseif Dx(number)>0 && Dy(number)
            amp_4 = amp_4 + sqrt(Dx(number)*Dx(number)+Dy(number)*Dy(number));
        end
    end
    [~, amp] = max([amp_1 amp_2 amp_3 amp_4]);

    % Calculate the angles of all vibration angles within the dominant quadrant
    if amp==1
        for idx = 1 : fps
            number = (t-1)*fps+idx;
            if Dx(number)>0 && Dy(number)>0
                angle = [angle, atan(Dy(number)/Dx(number))*180/pi];
            end
        end
    elseif amp==2
        for idx = 1 : fps
            number = (t-1)*fps+idx;
            if Dx(number)<0 && Dy(number)>0
                angle = [angle, (180+atan(Dy(number)/Dx(number))*180/pi)];
            end
        end
    elseif amp==3
        for idx = 1 : fps
            number = (t-1)*fps+idx;
            if Dx(number)<0 && Dy(number)<0
                angle = [angle, atan(Dy(number)/Dx(number))*180/pi-180];
            end
        end
    elseif amp==4
        for idx = 1 : fps
            number = (t-1)*fps+idx;
            if Dx(number)>0 && Dy(number)<0
                angle = [angle, atan(Dy(number)/Dx(number))*180/pi];
            end
        end
    end
    if time_angle == 1
        ANGLE = [ANGLE, median(angle)];
        angle = [];
    else
        if mod(t,time_angle)==0 && (t>0)
            ANGLE = [ANGLE, median(angle)];
            angle = [];
        end
    end
end

%% calculate the total displacement
LSM = [];
for t = 1 : time
    if time_angle == 1
        ang = ANGLE(t);
    else
        if mod(t,time_angle)==1
            ang = ANGLE(floor(t/time_angle)+1);
        end
    end

    for idx = 1 : fps
        number = (t-1)*fps+idx;
        LSM = [LSM, Dx(number)*cos(ang)+Dy(number)*sin(ang)];
    end
end

end
