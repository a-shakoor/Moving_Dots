function [initialY, velocity, singleDotOn, singleDotBackToCenter, singleDotOff] = ...
    singleDot(screenInfo, trialNum, duration, dispStepRamp, pauseBeforeMotion, singleDotOutput)
% duration = time to get from center to end of screen (AFTER STEPRAMP)

%% Parameter Setting
curWindow = screenInfo.curWindow;
screenRect = screenInfo.screenRect;
monRefresh = screenInfo.monRefresh;
distance = screenRect(3) / 2; % distance = length of monitor (screenRect(3))
%stepRampAngle = 1.5; % this determines how far out to put the stepramp
% distanceFromMonitor = 75; % in cm
singleDotBackToCenter = -1;
stepRampTimeBackToCenter = .150;
fixationCrossSize=40;
radius = 17.5;

%% Return value units
% 1 - present velocity in pixels/second
% 0 - present velocity in pixels/frame
presentVelocityInSeconds = 1;

%% y-coordinate bounds (for the jitter in y)
% note: lowerBound is actually the "top" bound on the screen b/c
% coordinates increase as you go down the screen
putJitterInY = 0; % 0 or 1
lowerBound = screenRect(2) + 1/4 * screenRect(4);
upperBound = screenRect(2) + 3/4 * screenRect(4);

%% Randomly select initial y coord and direction (+/-)
movingRight = randi(2)-1;
if putJitterInY
    initialY = rand() * (upperBound-lowerBound) + lowerBound;
else
    initialY = screenRect(4) / 2;
end
center = [screenRect(3)/2 initialY];
if movingRight
    v_pixsec = distance/duration;
else
    v_pixsec = distance/duration * -1;
end
v_pixframe = v_pixsec * 1/monRefresh;

%% Return Value
if presentVelocityInSeconds
    velocity = v_pixsec;
else
    velocity = v_pixframe;
end

%% Draw Fixation at Center
    fixationCross(pauseBeforeMotion, fixationCrossSize, screenInfo)
    originalCenter = center;

%% Actual drawing code
if dispStepRamp 
    rampDistance = (v_pixsec * -1 * stepRampTimeBackToCenter);
    %rampDistance = stepRampAngle * screenInfo.ppd * sign(v_pixsec) * -1 % in pixels
    duration = duration + abs(rampDistance / v_pixsec);
    
    %flash to step ramp
    center = [center(1) + rampDistance, center(2)];
    Screen('FillOval', curWindow, [255 255 255], ...
        [center(1)-radius, center(2)-radius, center(1)+radius, center(2)+radius]);    Screen('Flip', curWindow);
    singleDotOn = GetSecs;

    visualAngle = abs(rampDistance)/screenInfo.ppd;
end
numFrames = ceil(duration * monRefresh);
singleDotPositions = zeros([numFrames 3]);
currentRow = 1;
while numFrames
    center(1) = center(1) + v_pixframe;
    %Screen('DrawDots', curWindow, center, 20, [255 255 255], [0 0], 1);
    Screen('FillOval', curWindow, [255 255 255], ...
        [center(1)-radius, center(2)-radius, center(1)+radius, center(2)+radius]);
    Screen('Flip', curWindow);
    singleDotPositions(currentRow, 1:3) = [GetSecs center(1) center(2)];
    currentRow = currentRow + 1;
    numFrames = numFrames - 1;
end
Screen('Flip', curWindow);
singleDotOff = GetSecs;

%% Array of Event Times
    if singleDotOutput
    timestamp = datestr(now);
    timestamp = strrep(timestamp,'/','-');
    timestamp = strrep(timestamp,' ','_');
    timestamp = strrep(timestamp,':','-');
    filename = strcat(screenInfo.folderPath, '\','Trial-',num2str(trialNum),'-',timestamp, '.csv');
    dlmwrite(filename, singleDotPositions,'precision',14)
    end
end