function outputStruct = dotsX(screenInfo,dotInfo)
% DOTSX display dots on screen
%
% [dir, apVel, frames,rseed,start_time,end_time,response,response_time] = dotsX(screenInfo,dotInfo)
%
% For information on minimum fields of screenInfo and dotInfo arguments, see
% also openExperiment and createDotInfo. Since rex only likes integers, 
% almost everything is in visual degrees * 10.
% 
%% Table of Contents
% Section 1: Assigning Paramters from dotInfo/screenInfo
% Section 2: Unit Changing/Calculations
% Section 3: Create matrix of dot locations for entire trial
% Section 3.5: Optional White Flash signal. Toggle this using parameter in
%              Section 1
% Section 4: Loop of "Moving" the Dots on Each Frame
%   4a: Calculations to "move" dots before drawing
%   4b: Actual Drawing Commands
% Section 5: Single Dot motion (if applicable)
% Section 6: End of Trial. Present Feedback and Write Output. 

%   dotInfo.numDotField     number of dot patches that will be shown on screen
%   dotInfo.coh             vertical vectors, dots coherence (0...999) for each 
%                           dot patch
%   dotInfo.speed           vertical vectors, dots speed (10th deg/sec) for each 
%                           dot patch
%   dotInfo.dir             dots direction (degrees) for each
%   dotInfo.apVel           aperature direction (+/- = right/left) and speed
%                           added 1/22/19 AKS
%   dotInfo.isSingleDotTrialIf set to 1, single dot will traverse screen
%                           after coherent dot motion
%                           added 4/23/19 AKS
%   dotInfo.dotSize         size of dots in pixels, same for all patches
%   dotInfo.dotColor        color of dots in RGB, same for all patches
%   dotInfo.maxDotsPerFrame determined by testing video card
%   dotInfo.apXYD           x, y coordinates, and diameter of aperture(s) in 
%                           visual degrees          
%   dotInfo.maxDotTime      optional to set maximum duration (sec). If not provided, 
%                           dot presentation is terminated only by user response
%   dotInfo.trialtype       1 fixed duration, 2 reaction time
%   dotInfo.keys            a set of keyboard buttons that can terminate the 
%                           presentation of dots (optional)
%   dotInfo.mouse           a set of mouse buttons that can terminate the 
%                           presentation of dots (optional)
%
%   screenInfo.curWindow    window pointer on which to plot dots
%   screenInfo.center       x,y center of the screen in pixels
%   screenInfo.screenRect   example [0 0 1920 1080]
%   screenInfo.ppd          pixels per visual degree
%   screenInfo.monRefresh   monitor refresh value
%   screenInfo.dontclear    If set to 1, flip will not clear the framebuffer 
%                           after Flip - this allows incremental drawing of 
%                           stimuli. Needs to be zero for dots to be erased.
%   screenInfo.rseed        random # seed, can be empty set[] 
%

% Algorithm:
%   All calculations take place within a square aperture in which the dots are 
% shown. The dots are constructed in 3 sets that are plotted in sequence.  For 
% each set, the probability that a dot is replotted in motion -- as opposed to 
% randomly replaced -- is given by the dotInfo.coh value. This routine generates 
% a set of dots as an (ndots,2) matrix of locations, and then plots them.  In 
% plotting the next set of dots (e.g., set 2), it prepends the preceding set 
% (e.g., set 1).
%

% created by MKMK July 2006, based on ShadlenDots by MNS, JIG and others
% edited by AKS, University of Georgia, April 2019

% Structures are not altered in this function, so should not have memory
% problems from matlab creating new structures.

% CURRENTLY THERE IS AN ALMOST ONE SECOND DELAY FROM THE TIME DOTSX IS
% CALLED UNTIL THE DOTS START ON THE SCREEN! THIS IS BECAUSE OF PRIORITY.
% NEED TO EVALUATE WHETHER PRIORITY IS REALLY NECESSARY.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Section 1: Assigning Paramters from dotInfo/screenInfo

% Code is executed in Section 3.5
showWhiteSquareFlash = 0; %set equal to one to flash a sq
flashDuration = .1; %in secs

% Code is executed in Section 5
isSingleDotTrial = dotInfo.isSingleDotTrial;
dispStepRamp = dotInfo.dispStepRamp;
singleDotDuration = dotInfo.singleDotDuration;
dotInfo.maxDotTime = dotInfo.cohDuration;
decisionMaxTime = dotInfo.decisionMaxTime; % time to make a decision in seconds

drawCenter = 0; %set equal to one to put red dot in center of aperature


%%%%%% NOTE: These aren't changed normally %%%%%%%%%5
curWindow = screenInfo.curWindow;
dotColor = dotInfo.dotColor;
rseed = screenInfo.rseed;
dotInfo.keyLeft = KbName('leftarrow');
dotInfo.keyRight = KbName('rightarrow');
keys = [dotInfo.keyLeft dotInfo.keyRight];
abort = [dotInfo.keySpace];
%if isfield(dotInfo, 'keyLeft')
%    keys = [dotInfo.keyLeft dotInfo.keyRight];
%elseif isfield(dotInfo, 'keySpace')
%    abort = nan;
%end
dir = dotInfo.dir;
apVel = dotInfo.apVel;

% In order to find out if using keypress or mouse, all trials should have spacekey
% for abort, unless its a demo. Spacekey means end experiment after this trial - 
% sends abort message to experiment.

% Default Values
timeCoherentOn = NaN;
timeCoherentOff = NaN;
timeSingleDotOn = NaN;
timeSingleDotOff = NaN;
timeResponse = NaN;
response = -1; 
correct = -1;

% Seed the random number generator. If "[]" is given, reset the seed "randomly".
% This is for VAR/NOVAR conditions.
if ~isempty(rseed) && length(rseed) == 1    
    rng(rseed,'v5uniform');
elseif ~isempty(rseed) && length(rseed) == 2
    rng(rseed(1)*rseed(2),'v5uniform');
else
    rseed = sum(100*clock);
    rng(rseed,'v5uniform');
end


%% Section 2: Unit Changing/Calculations
% Create the aperture square
%apRect = floor(createTRect(dotInfo.apXYD, screenInfo));

% Variables sent to rex have been multiplied by a factor of 10 to make sure 
% they are integers. Now convert them back so that they are correct for plotting.
coh = dotInfo.coh/1000;	% dotInfo.coh is specified in range 0..1000 (because of
                        % rex need integers), but we want in range 0..1
apD = dotInfo.apXYD(:,3); % diameter of aperture
center = repmat(screenInfo.center,size(dotInfo.apXYD(:,1)));

% Change x,y coordinates to pixels (y is inverted - pos on bottom, neg. on top)
center = [center(:,1) + dotInfo.apXYD(:,1)/10*screenInfo.ppd ...
         center(:,2) - dotInfo.apXYD(:,2)/10*screenInfo.ppd]; 
         % where you want the center of the aperture
center(:,3) = dotInfo.apXYD(:,3)/2/10*screenInfo.ppd; % add diameter
d_ppd = floor(apD/10 * screenInfo.ppd);	% size of aperture in pixels
dotSize = dotInfo.dotSize; % probably better to leave this in pixels, but not sure

% ndots is the number of dots shown per video frame. Dots will be placed in a 
% square of the size of aperture.
% - Size of aperture = Apd*Apd/100  sq deg
% - Number of dots per video frame = 16.7 dots per sq deg/sec,
% When rounding up, do not exceed the number of dots that can be plotted in a 
% video frame (dotInfo.maxDotsPerFrame). maxDotsPerFrame was originally in 
% setupScreen as a field in screenInfo, but makes more sense in createDotInfo as 
% a field in dotInfo.
ndots = min(dotInfo.maxDotsPerFrame, ...
    ceil(16.7 * apD .* apD * 0.01 / screenInfo.monRefresh));


%% Section 3: Create matrix of dot locations for entire trial
% Don't worry about pre-allocating, the number of dot fields should never be 
% large enough to cause memory problems.
for df = 1 : dotInfo.numDotField
    % dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
    %   deg/sec * ap-unit/deg * sec/jump = ap-unit/jump
    dxdy{df} = repmat((dotInfo.speed(df)/10) * (10/apD(df)) * ...
        (3/screenInfo.monRefresh) * [cos(pi*dotInfo.dir(df)/180.0), ...
        -sin(pi*dotInfo.dir(df)/180.0)], ndots(df),1);
    ss{df} = rand(ndots(df)*3, 2); % array of dot positions raw [x,y]
    % Divide dots into three sets
    Ls{df} = cumsum(ones(ndots(df),3)) + repmat([0 ndots(df) ndots(df)*2], ... 
        ndots(df), 1);
    loopi(df) = 1; % loops through the three sets of dots
    
end

% Loop length is determined by the field "dotInfo.maxDotTime". If none is given, 
% loop until "continue_show=0" is set by other means (eg. user response), 
% otherwise loop until dotInfo.maxDotTime. Always one video frame per loop.

if ~isfield(dotInfo,'maxDotTime') || (isempty(dotInfo.maxDotTime) && ndots>0)
    continue_show = -1;
elseif ndots > 0
    continue_show = round(dotInfo.maxDotTime*screenInfo.monRefresh);
    disp("continue show: " + continue_show)
    disp("monrefresh: " + screenInfo.monRefresh)
else
    continue_show = 0;
end

dontclear = screenInfo.dontclear;

% The main loop
frames = 0;
priorityLevel = MaxPriority(curWindow,'KbCheck');
Priority(priorityLevel);


Screen('DrawingFinished',curWindow,dontclear);

%% Section 3.5:  Optional White Flash signal. 
% Toggle this using parameter in Section 1

if showWhiteSquareFlash
   whiteSquareFlash(screenInfo, flashDuration);
end

%% Section 4: Loop of "Moving" the Dots on Each Frame

% How dots are presented: 1st group of dots are shown in the first frame, a 2nd 
% group are shown in the second frame, a 3rd group shown in the third frame.
% Then in the next (4th) frame, some percentage of the dots from the 1st frame 
% are replotted according to the speed/direction and coherence. Similarly, the 
% same is done for the 2nd group, etc.
initVal = continue_show;
while continue_show
    %% Section 4a: Calculations to "move" dots before drawing
    for df = 1 : dotInfo.numDotField    
        
        % ss is the matrix with 3 sets of dot positions, dots from the last 2 
        %   positions and current dot positions
        % Ls picks out the set (e.g., with 5 dots on the screen at a time, 1:5, 
        %   6:10, or 11:15)
        
        % Lthis has the dot positions from 3 frames ago, which is what is then
        Lthis{df}  = Ls{df}(:,loopi(df));
        
        % Moved in the current loop. This is a matrix of random numbers - starting 
        % positions of dots not moving coherently.
        this_s{df} = ss{df}(Lthis{df},:);
        
        % Update the loop pointer
        loopi(df) = loopi(df)+1;
        
        if loopi(df) == 4,
            loopi(df) = 1;
        end
        
        % Compute new locations, how many dots move coherently
        L = rand(ndots(df),1) < coh(df);
        % Offset the selected dots
        this_s{df}(L,:) = bsxfun(@plus,this_s{df}(L,:),dxdy{df}(L,:));
        
        if sum(~L) > 0
            this_s{df}(~L,:) = rand(sum(~L),2);	% get new random locations for the rest
        end
        
        % Check to see if any positions are greater than 1 or less than 0 which 
        % is out of the square aperture, and replace with a dot along one of the
        % edges opposite from the direction of motion.
        N = sum((this_s{df} > 1 | this_s{df} < 0)')' ~= 0;
        if sum(N) > 0
            xdir = sin(pi*dotInfo.dir(df)/180.0);
            ydir = cos(pi*dotInfo.dir(df)/180.0);
            % Flip a weighted coin to see which edge to put the replaced dots
            if rand < abs(xdir)/(abs(xdir) + abs(ydir))
                this_s{df}(find(N==1),:) = [rand(sum(N),1),(xdir > 0)*ones(sum(N),1)];
            else
                this_s{df}(find(N==1),:) = [(ydir < 0)*ones(sum(N),1),rand(sum(N),1)];
            end
        end
        
        % Convert for plot
        this_x{df} = floor(d_ppd(df) * this_s{df});	% pix/ApUnit
        
        % It assumes that 0 is at the top left, but we want it to be in the 
        % center, so shift the dots up and left, which means adding half of the 
        % aperture size to both the x and y directions.
        dot_show{df} = (this_x{df} - d_ppd(df)/2)';
    end
    
    % After all computations, flip to draws dots from the previous loop. For the
    % first time, this doesn't draw anything.
    if continue_show == initVal - 1 % because first dots on drawn on the second iteration
        timeCoherentOn = GetSecs;
    end
    Screen('Flip', curWindow,0,dontclear);
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%% This code moves the center on each iteration %%%%%%%%%%%%%%
   %%%%%%%%%%%% if apVel is negative it will move left  %%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%% if apVel is positive it will move right %%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%% - AKS                                   %%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    center(df, 1) = center(df, 1) + apVel;
   
    
    %% Section 4b: Actual Drawing Commands
    % Now do the actual drawing commands, although nothing is drawn until next  
   
    %Remove dots that are out of circle before drawing
    for df = 1:dotInfo.numDotField
        % NaN out-of-circle dots                
        xyDis = dot_show{df};
        outCircle = sqrt(xyDis(1,:).^2 + xyDis(2,:).^2) + dotInfo.dotSize/2 > center(df,3);        
        dots2Display = dot_show{df};
        dots2Display(:,outCircle) = NaN;
        
        Screen('DrawDots',curWindow,dots2Display,dotSize,dotColor,center(df,1:2));
        if(drawCenter == 1)
            Screen('DrawDots', curWindow, [0 0], dotSize * 2, [255 0 0], center(df, 1:2));
        end
    end
    
 
    % Tell PTB to get ready while doing computations for next dots presentation
    Screen('DrawingFinished',curWindow,dontclear);
    %Screen('BlendFunction', curWindow, GL_ONE, GL_ZERO);
    
    frames = frames + 1;
    
       
    for df = 1 : dotInfo.numDotField
        % Update the dot position array for the next loop
        ss{df}(Lthis{df}, :) = this_s{df};
    end
    
    % Check for the end of loop
    continue_show = continue_show - 1;
    
    % This code checks for a response. Will only run if this is not a
    % singleDot trial.
    % User may terminate the dots by pressing certain keyboard keys defined by
    % "keys". Pressing the space bar will cause a signal to be sent so that the 
    % experiment will end after this trial.
    if ~isempty(keys) && ~isSingleDotTrial
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown
            % Send abort signal
            %if keyCode(abort)
            %    response(1) = find(keyCode(abort));
            %end
            % End trial, have response
            if any(keyCode(keys))
                response_index = find(keyCode(keys));
                if(keys(response_index) == dotInfo.keyRight)
                    response = 0;
                elseif(keys(response_index) == dotInfo.keyLeft)
                    response = 180;
                end
            
                continue_show = 0;
                % response_time = secs; %%% this don't work
                response_time = frames * (1 / screenInfo.monRefresh);
                if(response == dir)
                    correct = 1;
                else
                    correct = 0;
                end
            end
        end
        KbQueueRelease();

    end
    
end
% Present the last frame of dots
Screen('Flip',curWindow,0,dontclear);
Screen('Flip', curWindow);
timeCoherentOff = GetSecs;

%% Section 5: Single Dot

if isSingleDotTrial
    timeSingleDotOn = GetSecs;
    [singleDotInitialY, singleDotVelocity] = singleDot(screenInfo, singleDotDuration, dispStepRamp);
    timeSingleDotOff = GetSecs;
    KbQueueRelease();
    % Checks for code after singleDot ends
    initDecisionTimeFrames = round(decisionMaxTime * screenInfo.monRefresh);
    decisionTimeFrames = initDecisionTimeFrames;
    answered = 0;
    while (decisionTimeFrames > 0 || decisionTimeFrames < 0) && ~answered
        decisionTimeFrames = decisionTimeFrames - 1;
        if ~isempty(keys)
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyIsDown
                % Send abort signal
                %if keyCode(abort)
                %    response(1) = find(keyCode(abort));
                %end
                % End trial, have response
                if any(keyCode(keys))
                    response_index = find(keyCode(keys));
                    if(keys(response_index) == dotInfo.keyRight)
                        response = 0;
                    elseif(keys(response_index) == dotInfo.keyLeft)
                        response = 180;
                    end

                    timeResponse = GetSecs; %%% this don't work
                    %responseTime = decisionTimeFrames * (1 / screenInfo.monRefresh);
                    if(response == dir)
                        correct = 1;
                    else
                        correct = 0;
                    end
                    answered = 1;
                end
             end
        KbQueueRelease();
        end
        Screen('WaitBlanking', screenInfo.curWindow);
    end %while
    

end %if



%% Section 6: End of Trial. Feedback and Output.
if dotInfo.presentFeedback
    if coh == 0 %% present random feedback if coherence is 0
         presentFeedback(screenInfo, randi(2) - 1);
    elseif correct >= 0
         presentFeedback(screenInfo, correct);
    end
end

outputStruct.coh = coh;
outputStruct.dir = dir;
outputStruct.apVel = apVel;
outputStruct.response = response;
outputStruct.correct = correct;
outputStruct.singleDotInitialY = singleDotInitialY;
outputStruct.singleDotVelocity = singleDotVelocity;
outputStruct.decisionMaxTime = decisionMaxTime;
outputStruct.timeCoherentOn = timeCoherentOn - timeCoherentOn;
outputStruct.timeCoherentOff = timeCoherentOff - timeCoherentOn;
outputStruct.timeSingleDotOn = timeSingleDotOn - timeCoherentOn;
outputStruct.timeSingleDotOff = timeSingleDotOff - timeCoherentOn;
outputStruct.timeResponse = timeResponse - timeCoherentOn;


Priority(0);
end


