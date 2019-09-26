% dotsOnlyDemo
%
% Simple script for testing dots (dotsX)
%
function success = dotsOnlyDemo()

try 
    numberOfTrials = 5;
    
    % Initialize the screen
    % touchscreen is 34, laptop is 32, viewsonic is 38
    screenInfo = openExperiment(34,50,0);
    
    trialInfo = zeros(numberOfTrials, 8);
    
    for i = 1:numberOfTrials
        
        % Initialize dots
        % Check createMinDotInfo to change parameters
        % dotInfo = createDotInfo(inputtype, coh percentage as a decimal, dir, apvel)
        % possible values
        %   cohSet = any value in [0,1];
        %   dirSet = [0 180];
        %   apVelSet = [-10 0 10];
        dotInfo = createDotInfo(screenInfo, 1, 0, 180, 0);
       
        
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
    filename = strcat('C:\Users\ashaq\Desktop\Moving Dots\Results\Test', timestamp, '.csv');
    
    [detailedTrialInfo, summaryArray] = graphTrialInfo();
    dlmwrite(filename, summaryArray, '-append');
    dlmwrite(filename, detailedTrialInfo, 'roffset', 1, '-append');
    
    % Clear the screen and exit
    closeExperiment;
    
catch
    disp('caught error');
    lasterr
    closeExperiment;
success = true; 
end
end


