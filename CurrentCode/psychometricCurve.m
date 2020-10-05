function psychometricCurve(separateByCongruency) 

% separateByCongruency = 0 if incongruent, 1 if congruent, -1 if don't separate
if nargin
    separateByCongruency = -1;
end

gscommand = 'C:/Program Files/gs/gs9.50/bin/gswin64.exe';
gsfontpath = 'C:/Program Files/gs/gs9.50/Resource/Font';
gslibpath = 'C:/Program Files/gs/gs9.50/lib';


%% TrialInfo Positions CSV Indicies
coh_duration = 2;
coh_level = 3;
congruency = 6;
hit = 8;

trialInfoFilePath = ...
    'C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/TrialInfo-13-Apr-2020_21-56-39.csv';
trialInfo = csvread(trialInfoFilePath);

trialsPerCondition = 28;

%% Convert to %
trialInfo(:, coh_level) = trialInfo(:, coh_level) * 100;

%% Separate By Congruency
% incongruent = 0, congruent = 1
if separateByCongruency ~= -1
    trialInfo = trialInfo(trialInfo(:, congrunecy) == separateByCongrunecy, :);
end

%% Proportion Matrix

%P = sum(A(:)<10)/sum(A;


%% Collapse

% Sort twice
original = trialInfo;
trialInfo = sortrows(sortrows(trialInfo, coh_duration), coh_level);
rowsToKeep = [];
for row = 2:length(trialInfo)
    if trialInfo(row, coh_duration) == trialInfo(row - 1, coh_duration) ...
        && trialInfo(row, coh_level) == trialInfo(row - 1, coh_level)
        trialInfo(row, hit) = trialInfo(row, hit) + trialInfo(row - 1, hit);
    else
        rowsToKeep = [rowsToKeep, row - 1];
    end
end

rowsToKeep = [rowsToKeep, length(trialInfo)]; % Keep the last row
trialInfo = trialInfo(rowsToKeep, :);


%% Put hit in terms of proportion

trialInfo(:, hit) = trialInfo(:, hit) / trialsPerCondition;


%% Scatterplot
hold off
clf
hold on
% gscatter(x, y, group)
gscatter(trialInfo(:, coh_level), trialInfo(:, hit), trialInfo(:, coh_duration))



%% Separate out by coherence duration
trialInfo100 = trialInfo(trialInfo(:, coh_duration) == .1, :);
trialInfo200 = trialInfo(trialInfo(:, coh_duration) == .2, :);
trialInfo400 = trialInfo(trialInfo(:, coh_duration) == .4, :);


%% Plot 
% Fit psychometirc functions
targets = [0.25, 0.5, 0.75] % 25%, 50% and 75% performance
weights = ones(1,size(trialInfo100, 1)) % No weighting
% Fit for neutral background
[coeffs100, ~, curve100, thresholdNeutralBg] = ...
    FitPsycheCurveLogit(trialInfo100(:,coh_level), trialInfo100(:,hit), weights, targets);
% Fit for dark background
[coeffs200, ~, curve200, thresholdDarkBg] = ...
    FitPsycheCurveLogit(trialInfo200(:,coh_level), trialInfo200(:,hit), weights, targets);
% Fit for obscured target
[coeffs400, ~, curve400, thresholdObscured] = ...
    FitPsycheCurveLogit(trialInfo400(:,coh_level), trialInfo400(:,hit), weights, targets);

% Plot psychometic curves
plot(curve100(:,1), curve100(:,2), '--r')
plot(curve200(:,1), curve200(:,2), '--g')
plot(curve400(:,1), curve400(:,2), '--b')
legend('.1 sec', '.2 sec', '.4 sec');
xlabel('Coherence Level %');
ylabel('Proportion Correct');
title('Psychometric Curve')

%% Regress and plot each duration separately
% clf;
% hold off;
% hold on;
% %gscatter(trialInfo(:,coh_level), trialInfo(:,hit), trialInfo(:,coh_duration))
% x100 = trialInfo100(:, coh_level);
% b100 = glmfit(x100,trialInfo100(:,hit),'binomial','link','logit');
% y100 = glmval(b100,x100,'logit');
% plot(x100, y100)
% 
% 
% x200 = trialInfo200(:, coh_level);
% b200 = glmfit(x200,trialInfo200(:,hit),'binomial','link','logit');
% y200 = glmval(b200,x200,'logit');
% plot(x200, y200)
% 
% 
% x400 = trialInfo400(:, coh_level);
% b400 = glmfit(x400,trialInfo400(:,hit),'binomial','link','logit');
% y400 = glmval(b400,x400,'logit');
% plot(x400, y400)
% 
% %% Vertical Lines at Experimental Coherence Levels
% xticks([6 12 18 24 30 36 42 48])
% grid on
% 
% legend('100 ms', '200 ms', '400 ms', 'Location', 'southoutside')
% 
% switch separateByCongruency
%     case -1
%         title("Psychometric Curve");
%     case 0
%         title("Psychometric Curve (Incongruent Cases Only)");
% 
% %title(append('Gaze During Single Dot: Trial ' , num2str(trialNumber)));% num2str(thistrial)));
% xlabel('Coherence Level (%)');
% yyaxis left
% ylabel('Accuracy Proportion');



%% Printing 
%     x0=50;
%     y0=0;
%     width=600*1.25;
%     height=550*1.25;
%     set(gcf,'position',[x0,y0,width,height])
% 
%   print('C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Sean/psychometric.ps', ...
%        '-dpsc', '-append'); 
%    
%    ps2pdf('psfile','C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Sean/psychometric.ps', ...
%                   'pdffile', 'C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Sean/psychometric.pdf', ...
%                   'gscommand', gscommand, 'gsfontpath', gsfontpath, 'gslibpath', gslibpath);

end