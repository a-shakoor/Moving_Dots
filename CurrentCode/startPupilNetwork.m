function [hUDP, eyeProperties] = startPupilNetwork()

% construct the pupil UDP
hUDP = udp('127.0.0.1','LocalPort',8821,'Timeout',0.5);
eyeProperties.timerPeriod = 100; % in seconds 0.05 = 50 ms
fopen(hUDP);
eyeProperties.isOpen = true;

tic; fread(hUDP); elapsed=toc;
if elapsed>=eyeProperties.timerPeriod
    sprintf('Timeout for PupilNetwork UDP (%.2f sec): Check UDP connection ',elapsed);
    fclose(hUDP);
    eyeProperties.isOpen = false;
else
    eyeProperties.isConnected = true;
end


for i = 1:10
    pupil_val = pupilRead(hUDP, eyeProperties);
    pupil_vals(i) = pupil_val;
end

%  folderPath = 'C:\Users\ashaq\Google Drive\New Dropbox\Moving Dots\Results';
%  timestamp = datestr(now);
%  timestamp = strrep(timestamp,'/','-');
%  timestamp = strrep(timestamp,' ','_');
%  timestamp = strrep(timestamp,':','-');
%  filename = strcat(folderPath, '\','TrialInfo-',timestamp, '.csv');
%  
%  for i = 1:size(pupil_valss, 2)
%         this_pupil_val = pupil_valss(i);
%         trialInfos(i,1) = this_pupil_val.gazeTime;
%         trialInfos(i,2) = this_pupil_val.gazePosition(1);
%         trialInfos(i,3) = this_pupil_val.gazePosition(2);
%         trialInfos(i,4) = this_pupil_val.gazeConfidence;
%  end
% csvwrite(filename, trialInfos)    
end