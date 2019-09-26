function [initialY, velocity] = singleDot(screenInfo, duration)

%% Parameter Setting

% distance = length of monitor (screenRect(3))
curWindow = screenInfo.curWindow;
screenRect = screenInfo.screenRect;
monRefresh = screenInfo.monRefresh;
distance = screenRect(3);

% Return value units
% 1 - present velocity in pixels/second
% 0 - present velocity in pixels/frame
presentVelocityInSeconds = 1;

% y-coordinate bounds (for the jitter in y)
% note: lowerBound is actually the "top" bound on the screen b/c
% coordinates increase as you go down the screen
lowerBound = screenRect(2) + 1/4 * screenRect(4);
upperBound = screenRect(2) + 3/4 * screenRect(4);


%% Parameter: duration - time to traverse entire screen.
% velocity dependent on this
numFrames = round(duration * monRefresh);

%% Randomly select initial y coord and direction (+/-)
movingRight = randi(2)-1;
initialY = rand() * (upperBound-lowerBound) + lowerBound;
if movingRight
    center = [0 initialY];
    v_pixsec = distance/duration;
else
    center = [screenRect(3) initialY];
    v_pixsec = distance/duration * -1;
end
v_pixframe = v_pixsec * 1/monRefresh;

%% Return Value
if presentVelocityInSeconds
    velocity = v_pixsec;
else
    velocity = v_pixframe;
end

%% Actual drawing code
while numFrames
    center(1) = center(1) + v_pixframe;
    Screen('DrawDots', curWindow, center, 20, [255 255 255], [0 0], 1);
    Screen('Flip', curWindow);
    numFrames = numFrames - 1;
    
end
Screen('Flip', curWindow);


    
end