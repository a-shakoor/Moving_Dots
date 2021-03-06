function output(outputStructs, folderPath)

% outputStruct.coh 
% outputStruct.dir 
% outputStruct.apVel 
% outputStruct.response 
% outputStruct.correct
% outputStruct.singleDotInitialY 
% outputStruct.singleDotVelocity 
% outputStruct.decisionMaxTime 
% outputStruct.timeCoherentOn 
% outputStruct.timeCoherentOff 
% outputStruct.timeSingleDotOn 
% outputStruct.timeSingleDotOff 
% outputStruct.timeResponse

    disp(outputStructs)
    %% Array of Event Times
    % [Trial #, Coherent On, Coherent Off, Single Dot On, Single Dot Off,
    %  Reponse Time]
        timestamp = datestr(now);
        timestamp = strrep(timestamp,'/','-');
        timestamp = strrep(timestamp,' ','_');
        timestamp = strrep(timestamp,':','-');
        filename = strcat(folderPath, '\','EventTimes-',timestamp, '.csv');
        eventTimes = zeros(size(outputStructs,1),9);
    for i = 1:size(outputStructs,2)
        outputStruct = outputStructs(i);
        eventTimes(i,1) = i;
        eventTimes(i,2) = outputStruct.startTimeSystem;
        eventTimes(i,3) = outputStruct.startTimePupil;
        eventTimes(i,4) = outputStruct.originalTimeCoherentOn;
        eventTimes(i,5) = outputStruct.timeCoherentOn;
        eventTimes(i,6) = outputStruct.timeCoherentOff;
        eventTimes(i,7) = outputStruct.timeSingleDotOn;
        eventTimes(i,8) = outputStruct.timeSingleDotOff;
        eventTimes(i,9) = outputStruct.timeResponse;
    end
    try
        dlmwrite(filename, eventTimes,'precision',9)
    catch
        dlmwrite(strcat('backupfor','EventTimes-',timestamp, '.csv'), eventTimes,'precision',9)
    end
    %% Array of Trial Info
    % [Trail #, Coherence, Direction of Dots, Aperature Velocity, 
    %  User Response, Correct or Not, Single Dot's Initial Y, 
    %  Single Dot's Velocity, Maximum Time For Decision]
        timestamp = datestr(now);
        timestamp = strrep(timestamp,'/','-');
        timestamp = strrep(timestamp,' ','_');
        timestamp = strrep(timestamp,':','-');
        filename = strcat(folderPath, '\','TrialInfo-',timestamp, '.csv');
        trialInfos = zeros(size(outputStructs,1),11);
    for i = 1:size(outputStructs,2)
        outputStruct = outputStructs(i);
        trialInfos(i,1) = i;
        trialInfos(i,2) = outputStruct.cohDuration;
        trialInfos(i,3) = outputStruct.coh;
        trialInfos(i,4) = outputStruct.dir;
        trialInfos(i,5) = outputStruct.response;
        trialInfos(i,6) = outputStruct.correct;
        trialInfos(i,7) = outputStruct.singleDotVelocity;
        trialInfos(i,8) = outputStruct.cohSingleDotCongruent;
        trialInfos(i,9) = outputStruct.singleDotInitialY;
        trialInfos(i,10) = outputStruct.singleDotVelocity;
        trialInfos(i,11) = outputStruct.decisionMaxTime;
    end
    try
        dlmwrite(filename, trialInfos,'precision',9)
    catch
        dlmwrite(strcat('backupfor','TrialInfo-',timestamp, '.csv'), trialInfos,'precision',9)
    end


end