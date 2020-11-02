% Universal script for running a dot trial
% python C:\Users\KinArmLab\Documents\MATLAB\Aly\Moving_Dots\CurrentCode\pythonPupil.py
function success = dotTrial()

try 
    
   %% Paramaters
    
    % Put all possible parameters in the following 3 sets
    %cohSet = [.1, .2, .4];
    cohSet = [.03, .06] %%, .12, .24, .48];    % dot coherence on interval [0,1]
    dirSet = [-1];              % possible direction of coherently moving dots
                                   % 0 or 180. 0 is right, 180 is left. -1 is random 
    apVelSet = [0];            % velocity of aperature. 0 for static aperature.
    cohDurationSet = [.100, .200, .400];
                               


    trialBlocks = 2;

    pauseBetweenTrials = 1;
    isSingleDotTrial = 1;      % if == 1, a single dot will traverse the 
                               % screen following the coherent dots
                               % if == 2, saccade instead of single dot
    presentFeedback = 0;       % 1 or 0
    dispStepRamp = 1;          % Should a stepramp be displayed
    pauseBeforeSingleDotMotion = 0.5; % in seconds
    singleDotDuration = 0.5;   % time for single dot to traverse screen (secs)
                               % This is irrelevant if not a single dot trial.
    singleDotOutput = 0;
    decisionMaxTime = 100;     % Maximum time allowed to make a decision. -1 if unlimited time
    
    dispFixationCircle = 1;
    fixationCrossSize = 60;
    fixationCrossDuration = .400;
    pauseAfterFixation = .200;
    
    % ScreenInfo Parameters
    monWidth = 54; % 30.4 for xps, 51.56 for lab monitor in cm, 54 for benq
    viewDist = 60; % in cm

    screenNum = 0; % 0 for xps, 1 for lab monitor
    pupilNetworkOn = 0;
    startTimePupil = 1;
    runOutput = 1; %%% MAKE SURE THIS IS ON IF YOU NEED DATAq
    
    folderPath = 'C:\Users\ashaq\Documents\GitHub\Moving_Dots\Results';
    
    % Rest
    restEveryXTrials = 2000;
    restDuration = 6000;
    returnDuration = 3;
    
   %% Create dotInfo for each trial and store in dotInfos matrix

    for h = 1:trialBlocks
        rowIndices = 1:trialsPerBlock;
        shuffledRowIndices = rowIndices(randperm(length(rowIndices))) + trialsPerBlock*(h-1)
        rowCounter = 1;
        for i = 1:length(cohSet)
            for j = 1: length(dirSet)
                for k = 1:length(apVelSet)
                    for l = 1:length(cohDurationSet)
                        %% dotInfo parameters: (coh as a decimal, dir, apvel,singleDot)
                        thisIndex = shuffledRowIndices(rowCounter);
                        dotInfos(thisIndex).coh = cohSet(i);
                        disp(thisIndex + " " + dotInfos(thisIndex).coh)
                        %dotInfos(thisIndex).dir = dirSet(j);
                        dotInfos(thisIndex).dir = (randi(2)-1) * 180; %random 0 or 180                        
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
    screenInfo.folderPath = folderPath;
    
    restAndReturn(screenInfo, fixationCrossSize, restDuration, returnDuration) % restAndReturn(restDuration, returnDuration)

    if pupilNetworkOn
        [hUDP, eyeProperties] = startPupilNetwork();
    end
    % Run through each trial
    for i = 1:length(dotInfos)

        
        if checkForEsc() == 1
            disp(strcat("User escaped loop during trial ", num2str(i-1)))
            break;
        end 
        if mod(i, restEveryXTrials) == 0
            restAndReturn(screenInfo, fixationCrossSize, restDuration, returnDuration) % restAndReturn(restDuration, returnDuration)
        end
        rawDotInfo = dotInfos(i);
        
        %pre-Step 1: Construct a rawDotInfo struct and open pupil network
        rawDotInfo.screenInfo = screenInfo;       
         
        %Step 1 of 2:   Create dotInfo struct by passing rawDotInfo to
        %               createDotInfo
        dotInfo = createDotInfo(rawDotInfo);
        dotInfo.decisionMaxTime = decisionMaxTime;
        dotInfo.presentFeedback = presentFeedback;
        dotInfo.dispStepRamp = dispStepRamp;
        dotInfo.pauseBeforeSingleDotMotion = pauseBeforeSingleDotMotion;
        dotInfo.singleDotOutput = singleDotOutput;
        dotInfo.dispFixationCircle = dispFixationCircle;
        dotInfo.trialNum = i;
        
        %Step 2 of 2: Pass in dotinfo struct to dotsX to run trial
        % THIS STARTS THE ACTUAL TRIAL
        startTimeSystem = GetSecs;
        startTimePupil = -1;
        if pupilNetworkOn
            startTimePupil = pupilGetCurrentTime(hUDP, eyeProperties);
        end
        fixationCross(fixationCrossDuration, fixationCrossSize, screenInfo);  % fixationCross(duration, size, screenInfo)
        pause(pauseAfterFixation);
        outputStruct = dotsX(screenInfo, dotInfo, startTimeSystem, startTimePupil);
        outputStructs(i) = outputStruct;
        pause(pauseBetweenTrials);
    end
    
    %% Output Formatting/Writing to CSV
    if runOutput
        output(outputStructs, folderPath);
    end
    
    %% Clear the screen and exit
    if pupilNetworkOn
        closePupilNetwork(hUDP);
    end
    closeExperiment;
    
catch
    disp('caught error');
    lasterr
    closeExperiment;
success = true; 
end
end

 
