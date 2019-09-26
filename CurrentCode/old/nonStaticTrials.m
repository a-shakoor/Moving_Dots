% dotsOnlyDemo
%
% Simple script for testing dots (dotsX)
%
function success = nonStaticTrials()

try 
    
    %%%% These are the parameters to change %%%%
    cohSet = [.03 .12 .24 .33];
    dirSet = [0 180];   % 0 or 180. 0 is right, 180 is left
    apVelSet = [0];  % 10 or -10. 0 is static.
    trialsPerCondition = 1;
    
    
    numberOfTrials = length(cohSet) * length(dirSet) * length(apVelSet) * trialsPerCondition;
    
    % Initialize the screen
    % touchscreen is 34, laptop is 32, viewsonic is 38
    screenInfo = openExperiment(34,50,0);
    
    trialInfo = zeros(numberOfTrials, 8);
    dotInfos = zeros(0,4);
    
    for h = 1:trialsPerCondition
        for i = 1:length(cohSet)
            for j = 1: length(dirSet)
                for k = 1:length(apVelSet)
                    % dotInfo = createDotInfo(inputtype, coh percentage as a decimal, dir, apvel, singleDot)
                    dotInfos(size(dotInfos, 1) + 1, :) = [1, cohSet(i), dirSet(j), apVelSet(k), isSingleDotTrial];
                end
            end
        end
    end
    
    shuffledDotInfos = dotInfos(randperm(size(dotInfos,1)),:);
    
    for i = 1:size(shuffledDotInfos)
        inputtype = shuffledDotInfos(i, 1);
        coh = shuffledDotInfos(i, 2);
        dir = shuffledDotInfos(i, 3);
        apVel = shuffledDotInfos(i, 4);
        dotInfo = createDotInfo(screenInfo,inputtype,coh, dir, apVel);
        
        %[coh, dir, apVel, response, correct, frames, response_time]
        %headerRow = ["Trial", "Dot Dir", "Aperature Velocity", "Response", "Correct", "Frames", "Response Time"];
        outputArray = dotsX(screenInfo, dotInfo);
        trialInfo(i, 1) = i;
        trialInfo(i, 2:8) = outputArray;
    end
    disp(trialInfo)
    
    timestamp = datestr(now);
    timestamp = strrep(timestamp,'/','-');
    timestamp = strrep(timestamp,' ','_');
    timestamp = strrep(timestamp,':','-');
    filename = strcat('C:\Users\ashaq\Desktop\Moving Dots\Results\NonStaticTest', timestamp, '.csv');

    %[detailedTrialInfo, summaryArray] = graphTrialInfo();
    %dlmwrite(filename, summaryArray, '-append');
    %dlmwrite(filename, detailedTrialInfo, 'roffset', 1, '-append');

    % Clear the screen and exit
    closeExperiment;
    
catch
    disp('caught error');
    lasterr
    closeExperiment;
success = true; 
end
end


