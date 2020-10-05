function [] = graphgaze()

gazefilepath = 'C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Deandra/gaze_positions.csv';
eventtimesfilepath = 'C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Deandra/EventTimes-28-Feb-2020_Total.csv';
rawfile = csvread(gazefilepath, 1, 0); % Offsets to start at 2nd row (after headers)
eventtimes = csvread(eventtimesfilepath);

gscommand = 'C:/Program Files/gs/gs9.50/bin/gswin64.exe';
gsfontpath = 'C:/Program Files/gs/gs9.50/Resource/Font';
gslibpath = 'C:/Program Files/gs/gs9.50/lib';

sgfOrder = 3;
sgfFramelen = 5;

distanceToScreen = 75; %cm

%% Event Time CSV Indicies
trial = 1;
startSys = 2;
startPupil= 3;
cohOnSys = 4;	
cohOnAdj = 5;	
cohOffAdj = 6;	
singDotOnAdj = 7;	
singDotOffAdj = 8;
response = 9;

%% Gaze Positions CSV Indicies
conf_ind = 3;
gazetime_ind = 1;
posx_norm_ind = 4;
posy_norm_ind = 5;
posx_gaze3d_ind = 8;


%% Filter Confidence above certain level
rawfile = rawfile(rawfile(:,conf_ind) > 0.7, :);

%% Throw out first X trials
firstValidTrial = 1;
eventtimes = eventtimes(eventtimes(:, 1) >= firstValidTrial, :);

%% Run through each Trial
clf
hold off
hold on
trialsWithoutPupil = zeros(1, 1);
%tiledlayout(3,1)
for thistrial = 1:length(eventtimes(:,trial))
    %% Filter both csv's to just the trial time ranges
    thisTrialRow = eventtimes(thistrial,:);   
    trialNumber = thisTrialRow(1);
    
    if thisTrialRow(startPupil) == -1
        disp("----------------------------------------------------------------------------")
        disp("----------------------------------------------------------------------------")
        disp("WARNING: Pupil Data could not be recorded for trial number: " + trialNumber)
        disp("----------------------------------------------------------------------------")
        disp("----------------------------------------------------------------------------")
        trialsWithoutPupil(length(trialsWithoutPupil)+1) = trialNumber;
        continue
    end

    singDotOnPupil = ...
        (thisTrialRow(cohOnSys) ...
        + thisTrialRow(singDotOnAdj)) ...
        - thisTrialRow(startSys) ...
        + thisTrialRow(startPupil);
    singDotOffPupil = ...
        (thisTrialRow(singDotOffAdj) - thisTrialRow(singDotOnAdj)) ...
        + singDotOnPupil;
    trialGaze = rawfile(rawfile(:,gazetime_ind) > singDotOnPupil, :);             
    trialGaze = trialGaze(trialGaze(:,gazetime_ind) < singDotOffPupil, :);

    %% Throw out extraneous columns
    trialGaze = trialGaze(:, 1:9);
    
    %% Set variables to plot
    disp("-----------------------------------------")
    disp("trial number: " + trialNumber)
    disp("cohOnSys: " + thisTrialRow(cohOnSys))
        disp("singDotOnAdj: " + thisTrialRow(singDotOnAdj))
        disp("startSys: " + thisTrialRow(startSys))
        disp("startPupil: " + thisTrialRow(startPupil))
    disp("Starting Timestamp (Pupil): " + singDotOnPupil)
    disp("trial gaze length: " + length(trialGaze))
    x_gaze3d = trialGaze(:, posx_gaze3d_ind);
    disp("x gaze length: " + length(x_gaze3d))
    x_norm = trialGaze(:, posx_norm_ind);
    
    if length(x_gaze3d) < sgfFramelen
        disp("THIS TRIAL DID NOT HAVE ENOUGH DATA TO BE FILTERED")
        continue
    end
    
    t = trialGaze(:, gazetime_ind) - trialGaze(1,gazetime_ind); % set first frame to t = 0;
    disp("t length: " + length(t))

    %% Transform x to degrees
    % formula angle = arccos((p1 dot p2) / (norm(p1) * norm(p2))
    % No actually, angle = arctan(dx / distance to screen)
    x_gaze3d_ang = zeros(length(x_gaze3d), 1);
    for i = 1:length(x_gaze3d)
       x_gaze3d_ang(i) = x_gaze3d(i) / 10; % mm to cm
       x_gaze3d_ang(i) = x_gaze3d_ang(i) - x_gaze3d_ang(1); % make each one relative to start
       x_gaze3d_ang(i) = atand(x_gaze3d_ang(i) / distanceToScreen);
    end
    disp("x gaze ang length: " + length(x_gaze3d_ang))

    
    %% Position
    hold on
    plot(t, x_gaze3d_ang, '-o','MarkerIndices',1:length(x_gaze3d_ang));
    %sgf = sgolayfilt(t, sgfOrder, sgfFramelen);
    %plot(t, sgf, '-o','MarkerIndices',1:length(y))

    %% Filtering and Velocity
    %   Use sgolay to smooth a noisy sinusoid and find its first three
    %   derivatives via a fifth order polynomial and a frame length of
    %   25 samples.
    [b,g] = sgolay(sgfOrder,sgfFramelen);
    %position = conv(x_gaze3d_ang, factorial(0) * g(:,0+1), 'same');
    %velocity = conv(x_gaze3d_ang, factorial(1) * g(:,1+1) / .007, 'same');
    position_ext = savitzkyGolayFilt(x_gaze3d_ang, sgfOrder, 0, sgfFramelen);
    velocity_ext = savitzkyGolayFilt(x_gaze3d_ang, sgfOrder, 1, sgfFramelen) / -.008333;
    
    % Filtered Position on the left axis
    % plot(t, position, '-o','MarkerIndices',1:length(t))
    plot(t, position_ext, '-o','MarkerIndices',1:length(t))

    
    % Velocity on the right axis
    yyaxis right
    %plot(t, velocity, '-o','MarkerIndices',1:length(t))
    plot(t, velocity_ext, '-o','MarkerIndices',1:length(t))


    %% Figure Options
    legend('Raw Position', 'Filtered Position', 'Filtered Velocity', 'Location', 'southoutside')
    title(append("Filtered Eye Position/Velocity: Trial ", num2str(trialNumber)));
    %title(append('Gaze During Single Dot: Trial ' , num2str(trialNumber)));% num2str(thistrial)));
    xlabel('Time (s)');
    yyaxis left
    ylabel('Position (deg)');
    yyaxis right
    ylabel('Velocity (deg/s)');
     
    x0=50;
    y0=0;
    width=600*1.25;
    height=550*1.25;
    set(gcf,'position',[x0,y0,width,height])

   print('C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Deandra/plots129.ps', ...
       '-dpsc', '-append');           
   hold off
   clf    
end % for 

disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
disp("FINAL REPORT:")
disp("Number of Trials Initially Recorded: " + length(eventtimes(:,trial)))
disp("Analysis Started From Trial: " + firstValidTrial)
disp("Trials for which Pupil Data could not be Recorded: " + trialsWithoutPupil)
totalAnalyzed = length(eventtimes(:,trial)) - (firstValidTrial - 1) - trialsWithoutPupil;
disp("Total Number Trials Analyzed: " + totalAnalyzed)
disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")

ps2pdf('psfile','C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Deandra/plots129.ps', ...
                  'pdffile', 'C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Deandra/plots129.pdf', ...
                  'gscommand', gscommand, 'gsfontpath', gsfontpath, 'gslibpath', gslibpath);


end
