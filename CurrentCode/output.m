function output(outputStructs)

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
        folderPath = 'C:\Users\ashaq\Google Drive\New Dropbox\Moving Dots\Results';
        timestamp = datestr(now);
        timestamp = strrep(timestamp,'/','-');
        timestamp = strrep(timestamp,' ','_');
        timestamp = strrep(timestamp,':','-');
        filename = strcat(folderPath, '\','EventTimes-',timestamp, '.csv');
        eventTimes = zeros(size(outputStructs,1),6);
    for i = 1:size(outputStructs,2)
        outputStruct = outputStructs(i);
        eventTimes(i,1) = i;
        eventTimes(i,2) = outputStruct.timeCoherentOn;
        eventTimes(i,3) = outputStruct.timeCoherentOff;
        eventTimes(i,4) = outputStruct.timeSingleDotOn;
        eventTimes(i,5) = outputStruct.timeSingleDotOff;
        eventTimes(i,6) = outputStruct.timeResponse;
    end
    csvwrite(filename, eventTimes)

    %% Array of Trial Info
    % [Trail #, Coherence, Direction of Dots, Aperature Velocity, 
    %  User Response, Correct or Not, Single Dot's Initial Y, 
    %  Single Dot's Velocity, Maximum Time For Decision]
        folderPath = 'C:\Users\ashaq\Google Drive\New Dropbox\Moving Dots\Results';
        timestamp = datestr(now);
        timestamp = strrep(timestamp,'/','-');
        timestamp = strrep(timestamp,' ','_');
        timestamp = strrep(timestamp,':','-');
        filename = strcat(folderPath, '\','TrialInfo-',timestamp, '.csv');
        trialInfos = zeros(size(outputStructs,1),9);
    for i = 1:size(outputStructs,2)
        outputStruct = outputStructs(i);
        trialInfos(i,1) = i;
        trialInfos(i,2) = outputStruct.coh;
        trialInfos(i,3) = outputStruct.dir;
        trialInfos(i,4) = outputStruct.apVel;
        trialInfos(i,5) = outputStruct.response;
        trialInfos(i,6) = outputStruct.correct;
        trialInfos(i,7) = outputStruct.singleDotInitialY;
        trialInfos(i,8) = outputStruct.singleDotVelocity;
        trialInfos(i,9) = outputStruct.decisionMaxTime;
    end
    csvwrite(filename, trialInfos)    
    


end