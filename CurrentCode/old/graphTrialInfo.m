function [detailedTrialInfo, summaryArray] = graphTrialInfo(trialInfo)
%each column in trialInfo = [trial#, coh, dir, apVel, response, correct, frames, response_time]
%columns of detailedTrialInfo = [trial#, coh, dir, apVel, response, correct, frames, response_time,
%                                isAnti, isProCorrect, isAntiCorrect]
% trialNum = trialInfo(1);
% coh = trialInfo(2);
% dir = trialInfo(3);
% apVel = trialInfo(4);
% response= trialInfo(5);
% correct = trialInfo(6);
% frames = trialInfo(7);
% response_time = trialInfo(8);

% summaryArray has columns [coh, numProCorrect, numProTotal, 
%                                numAntiCorrect, numAntiTotal
%                                numTotalCorrect, numTotalTotal]
% only one row for each unique coh level
summaryArray = zeros(0, 7);

if(~nargin)
    trialInfo = csvread('C:\Users\ashaq\Desktop\Moving Dots\Results\TimNonStaticTest20-Feb-2019_09-33-47.csv');
end


for i = 1:size(trialInfo,1)
    
    coh = trialInfo(i, 2);
    cohIndex = find(summaryArray(:,1)==coh, 1);
    if size(cohIndex, 1) == 0
        disp('if statement entered')
        cohIndex = size(summaryArray, 1) + 1;
        summaryArray(cohIndex, 1) = coh;
        summaryArray(cohIndex, 2:5) = 0;
    end
    
    
    dir = trialInfo(i, 3);
    apVel = trialInfo(i, 4);
    correct = trialInfo(i, 6);
    isPro =   ( dir  == 0 && apVel > 0 ) || ( dir == 180 && apVel < 0) ;
    isAnti = ~isPro;
    isProCorrect = correct && isPro;
    isAntiCorrect = correct && isAnti;
    
    summaryArray(cohIndex, 2) = summaryArray(cohIndex,2) + isProCorrect;
    summaryArray(cohIndex, 3) = summaryArray(cohIndex,3) + isPro;
    summaryArray(cohIndex, 4) = summaryArray(cohIndex,4) + isAntiCorrect;
    summaryArray(cohIndex, 5) = summaryArray(cohIndex,5) + isAnti;
    
%     trialInfo(i, 9) = isPro;
%     trialInfo(i, 10) = isProCorrect;
%     trialInfo(i, 11) = isAntiCorrect;       
end

for i = 1:size(summaryArray, 1)
    summaryArray(i, 6) = summaryArray(i,2) + summaryArray(i,4);
    summaryArray(i, 7) = summaryArray(i,3) + summaryArray(i,5);
end
disp(summaryArray)
detailedTrialInfo = trialInfo;

end