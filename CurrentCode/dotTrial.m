% Universal script for running a dot trial

function success = dotTrial()

try 
    
   %% Paramaters
    
    % Put all possible parameters in the following 3 sets
    cohSet = [.03 .06 .12 .24 .48];    % dot coherence on interval [0,1]
    dirSet = [0 180];              % possible direction of coherently moving dots
                                   % 0 or 180. 0 is right, 180 is left
    apVelSet = [0];            % velocity of aperature. 0 for static aperature.
    cohDurationSet = [.100, .200, .400];
                               
    trialsPerCondition = 1;
    pauseBetweenTrials = 1;
    isSingleDotTrial = 1;      % when set to 1, a single dot will traverse the 
                               % screen following the coherent dots
    presentFeedback = 0;       % 1 or 0
    dispStepRamp = 1;          % time for single dot to traverse screen (secs)
                               % This is irrelevant if not a single dot trial.
    singleDotDuration = 0.5;   % time for single dot to traverse screen (secs)
                               % This is irrelevant if not a single dot trial.
    decisionMaxTime = 3;     % Maximum time allowed to make a decision. -1 if unlimited time
    
    pauseAfterFixation = .200;
    
    % ScreenInfo Parameters
    monWidth = 30.4;
    viewDist = 75;
    screenNum = 0;
    pupilNetworkOn = 0;
    
   %% Create dotInfo for each trial and store in dotInfos matrix
    numberOfTrials = length(cohSet) * length(dirSet) * length(apVelSet) * length(cohDurationSet) * trialsPerCondition;
    rowIndices = 1:numberOfTrials;
    shuffledRowIndices = rowIndices(randperm(length(rowIndices)));
    rowCounter = 1;
    for h = 1:trialsPerCondition
        for i = 1:length(cohSet)
            for j = 1: length(dirSet)
                for k = 1:length(apVelSet)
                    for l = 1:length(cohDurationSet)
                        % dotInfo parameters: (coh as a decimal, dir, apvel,singleDot)
                        thisIndex = shuffledRowIndices(rowCounter);
                        dotInfos(thisIndex).coh = cohSet(i);
                        dotInfos(thisIndex).dir = dirSet(j);
                        dotInfos(thisIndex).apVel = apVelSet(k);
                        dotInfos(thisIndex).cohDuration = cohDurationSet(l);
                        dotInfos(thisIndex).isSingleDotTrial = isSingleDotTrial;
                        dotInfos(thisIndex).singleDotDuration = singleDotDuration;
                        rowCounter = rowCounter + 1;
                    end
                end
            end
        end
    end    
    
    %% Loop through shuffledDotInfos matrix to run each trial 
    % Output saved in trialInfo
   
    % Initialize the screen and pupil network
    screenInfo = openExperiment(monWidth,viewDist,screenNum);
    if pupilNetworkOn
        [hUDP, eyeProperties] = startPupilNetwork();
    end
    
    % Run through each trial
    for i = 1:numberOfTrials
        rawDotInfo = dotInfos(i);
        
        %pre-Step 1: Construct a rawDotInfo struct and open pupil network
        rawDotInfo.screenInfo = screenInfo;       
        
        %Step 1 of 2:   Create dotInfo struct by passing rawDotInfo to
        %               createDotInfo
        dotInfo = createDotInfo(rawDotInfo);
        dotInfo.decisionMaxTime = decisionMaxTime;
        dotInfo.presentFeedback = presentFeedback;
        dotInfo.dispStepRamp = dispStepRamp;
        
        %Step 2 of 2: Pass in dotinfo struct to dotsX to run trial
        % THIS STARTS THE ACTUAL TRIAL
        %startTimeSystem = GetSecs;
        %startTimePupil = pupilGetCurrentTime(hUDP, eyeProperties);
        fixationCircle(.200, 30, screenInfo); % fixationCircle(duration, radius, screenInfo)
        fixationCross(.200, 60, screenInfo);  % fixationCross(duration, size, screenInfo)
        pause(pauseAfterFixation);
        outputStruct = dotsX(screenInfo, dotInfo);
        outputStructs(i) = outputStruct;
        pause(pauseBetweenTrials);
    end
    
    %% Output Formatting/Writing to CSV
    output(outputStructs);
    
    
    %% Clear the screen and exit
    closePupilNetwork(hUDP);
    closeExperiment;
    
catch
    disp('caught error');
    lasterr
    closeExperiment;
success = true; 
end
end


