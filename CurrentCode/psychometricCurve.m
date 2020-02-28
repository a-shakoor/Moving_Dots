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

trialInfoFilePath = 'C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Sean/TrialInfo-11-Feb-2020_10-18-03.csv';
trialInfo = csvread(trialInfoFilePath);

%% Convert to %
trialInfo(:, coh_level) = trialInfo(:, coh_level) * 100;

%% Separate By Congruency
% incongruent = 0, congruent = 1
if separateByCongruency ~= -1
    trialInfo = trialInfo(trialInfo(:, congrunecy) == separateByCongrunecy, :);
end

%% Proportion Matrix

P = sum(A(:)<10)/sum(A;


%% Separate out by coherence duration
trialInfo100 = trialInfo(trialInfo(:, coh_duration) == .1, :);
trialInfo200 = trialInfo(trialInfo(:, coh_duration) == .2, :);
trialInfo400 = trialInfo(trialInfo(:, coh_duration) == .4, :);


%% Regress and plot each duration separately
clf;
hold off;
hold on;
%gscatter(trialInfo(:,coh_level), trialInfo(:,hit), trialInfo(:,coh_duration))
x100 = trialInfo100(:, coh_level);
b100 = glmfit(x100,trialInfo100(:,hit),'binomial','link','logit');
y100 = glmval(b100,x100,'logit');
plot(x100, y100)


x200 = trialInfo200(:, coh_level);
b200 = glmfit(x200,trialInfo200(:,hit),'binomial','link','logit');
y200 = glmval(b200,x200,'logit');
plot(x200, y200)


x400 = trialInfo400(:, coh_level);
b400 = glmfit(x400,trialInfo400(:,hit),'binomial','link','logit');
y400 = glmval(b400,x400,'logit');
plot(x400, y400)

%% Vertical Lines at Experimental Coherence Levels
xticks([6 12 18 24 30 36 42 48])
grid on

legend('100 ms', '200 ms', '400 ms', 'Location', 'southoutside')

switch separateByCongruency
    case -1
        title("Psychometric Curve");
    case 0
        title("Psychometric Curve (Incongruent Cases Only)");

%title(append('Gaze During Single Dot: Trial ' , num2str(trialNumber)));% num2str(thistrial)));
xlabel('Coherence Level (%)');
yyaxis left
ylabel('Accuracy Proportion');



%% Printing 
    x0=50;
    y0=0;
    width=600*1.25;
    height=550*1.25;
    set(gcf,'position',[x0,y0,width,height])

  print('C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Sean/psychometric.ps', ...
       '-dpsc', '-append'); 
   
   ps2pdf('psfile','C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Sean/psychometric.ps', ...
                  'pdffile', 'C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Sean/psychometric.pdf', ...
                  'gscommand', gscommand, 'gsfontpath', gsfontpath, 'gslibpath', gslibpath);

end