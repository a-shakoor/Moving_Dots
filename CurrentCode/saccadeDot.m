function [initialY] = ...
    saccadeDot(screenInfo, degrees, duration, pauseBeforeMotion)
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
radius = 10;


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
saccadeDirection = -1;
if randi(2)-1 == 1
    saccadeDirection = 1;
end
if putJitterInY
    initialY = rand() * (upperBound-lowerBound) + lowerBound;
else
    initialY = screenRect(4) / 2;
end
center = [screenRect(3)/2 initialY];

%% Set offset distance for saccade
saccadeOffset = degrees * screenInfo.ppd * saccadeDirection;

%% Draw Fixation at Center
fixationCross(pauseBeforeMotion, fixationCrossSize, screenInfo)


%% Actual drawing code
numFrames = ceil(duration * monRefresh);
% currentRow = 1;
center(1) = center(1) + saccadeOffset;
Screen('FillOval', curWindow, [255 255 255], ...
    [center(1)-radius, center(2)-radius, center(1)+radius, center(2)+radius]);
Screen('Flip', curWindow);
Screen('WaitBlanking', curWindow, numFrames) % stay on
Screen(curWindow,'FillRect', [0 0 0])
Screen('FillOval', curWindow, [0 100 255], ...
    [center(1)-radius, center(2)-radius, center(1)+radius, center(2)+radius]);
Screen('Flip', curWindow);
singleDotOff = GetSecs;


end