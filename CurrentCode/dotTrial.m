% Universal script for running a dot trial

function success = dotTrial()

try 
    
   %% Paramaters
    
    % Put all possible parameters in the following 3 sets
    cohSet = [.03 .06 .12 .24 48];    % dot coherence on interval [0,1]
    dirSet = [0 180];              % possible direction of coherently moving dots
                               % 0 or 180. 0 is right, 180 is left
    apVelSet = [0];            % velocity of aperature. 0 for static aperature.
    
    trialsPerCondition = 1;
    pauseBetweenTrials = 1;
    isSingleDotTrial = 1;      % when set to 1, a single dot will traverse the 
                               % screen following the coherent dots
    singleDotDuration = 0.5;   % time for single dot to traverse screen (secs)
                               % This is irrelevant if not a single dot trial.
    decisionMaxTime = 0.8;     % Maximum time allowed to make a decision
    
    pauseAfterFixation = .200;
    
   %% Create dotInfo for each trial and store in dotInfos matrix
    numberOfTrials = length(cohSet) * length(dirSet) * length(apVelSet) * trialsPerCondition;  
    dotInfos = zeros(0,5);
    for h = 1:trialsPerCondition
        for i = 1:length(cohSet)
            for j = 1: length(dirSet)
                for k = 1:length(apVelSet)
                    % dotInfo parameters: (coh as a decimal, dir, apvel,singleDot)
                    dotInfos(size(dotInfos, 1) + 1, :) = ...
                    [cohSet(i), dirSet(j), apVelSet(k), isSingleDotTrial, singleDotDuration];
                end
            end
        end
    end
    shuffledDotInfos = dotInfos(randperm(size(dotInfos,1)),:);
    
    
    %% Loop through shuffledDotInfos matrix to run each trial 
    % Output saved in trialInfo
   
    % Initialize the screen and pupil network
    % touchscreen is 34, laptop is 32, viewsonic is 38
    screenInfo = openExperiment(34,50,0);
    %[hUDP, eyeProperties] = startPupilNetwork();
    
    % Run through each trial
    for i = 1:size(shuffledDotInfos)
        
        %pre-Step 1: Construct a rawDotInfo struct and open pupil network
        rawDotInfo.screenInfo = screenInfo;
        rawDotInfo.coh = shuffledDotInfos(i, 1);
        rawDotInfo.dir = shuffledDotInfos(i, 2);
        rawDotInfo.apVel = shuffledDotInfos(i, 3);
        rawDotInfo.isSingleDotTrial = shuffledDotInfos(i, 4);
        rawDotInfo.singleDotDuration = shuffledDotInfos(i, 5);
        
        
        %Step 1 of 2:   Create dotInfo struct by passing rawDotInfo to
        %               createDotInfo
        dotInfo = createDotInfo(rawDotInfo);
        dotInfo.decisionMaxTime = decisionMaxTime;
        
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


