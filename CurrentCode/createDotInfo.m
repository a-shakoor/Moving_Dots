function dotInfo = createDotInfo(rawDotInfo)
% CREATEDOTINFO creates the default dotInfo structure
%
% dotInfo = createDotInfo(inputtype, coh, dir, apVel)
%
% Passing in -1 for rawDotInfo.coh, rawDotInfo.dir, or rawDotInfo.apVel 
%   will randomly select these values from the sets defined below

%

% created June 2006 MKMK

screenInfo = rawDotInfo.screenInfo;
coh = rawDotInfo.coh;
dir = rawDotInfo.dir;
apVel = rawDotInfo.apVel;
dotInfo.isSingleDotTrial = rawDotInfo.isSingleDotTrial;
dotInfo.singleDotDuration = rawDotInfo.singleDotDuration;
dotInfo.cohDuration = rawDotInfo.cohDuration;


%% COHERENCE LEVEL (out of 1) DEFAULT SET
% THIS IS USED ONLY IF COH NOT SUPPLIED
dotInfo.cohSet = [.03, .255, .48, .705, .93];
%dotInfo.cohSet = ;

%% DIRECTION OF MOVING DOTS DEFAULT SET
% THIS IS USED ONLY IF DIR NOT SUPPLIED
% 0 moves right. 180 moves left
dotInfo.dirSet = [0 180];

%% APERATURE VELOCITY DEFAULT SET 
% THIS IS USED ONLY IF APVEL NOT SUPPLIED
% units: pixels / frame
% takes an integer. negative moves left. positive moves right. 0 is static.
% ex. a set [-10 0 10] would move left 1/3 time, right 1/3 time, static 1/3
% note: 10 is a good speed.
dotInfo.apVelSet = [-10 0 10];
%dotInfo.apVelSet = 0;


% 1 = both move right, 2 = both move left
% 3 = dots move right and aperture moves left
% 4 = dots move left and aperture moves right
% dotInfo.caseSet = [4];


%% Dot Field and Size
dotInfo.numDotField = 1;
dotInfo.apXYD = [0 0 200]; %% in degress * 10


%% If not supplied, pick each parameter from random set
if(coh >= 0)
    dotInfo.coh = coh * 1000;
else
    dotInfo.coh = dotInfo.cohSet(ceil(rand*length(dotInfo.cohSet)))*1000;
end

if(dir >= 0)
    dotInfo.dir = dir;
else
    dotInfo.dir = dotInfo.dirSet(ceil(rand*length(dotInfo.dirSet)));
end

if(apVel ~= -1)
    dotInfo.apVel = apVel;
else
    dotInfo.apVel = dotInfo.apVelSet(ceil(rand*length(dotInfo.apVelSet)));
end

% SPEED CODE %%%%%%%%%%%%%%%%%%%%%%%%%
% CURRENT CODE SHOULD EQUALIZE INDIV DOT SPEED AND APERATURE SPEED,
% MAKING THEM "CANCEL OUT" IN THE ANTI CONDITION - AKS 2/19/19
% speed should be in 10 deg / sec according to formulas in dotX.m
% 10deg / sec = 10 * pixel/frame * frame/sec * degree/pixel
%dotInfo.speed = 10 * abs(apVel) * screenInfo.monRefresh * (1/screenInfo.ppd);
dotInfo.speed = 100;
%dotInfo.speed = 10 * 10 * 59.9353 / 51.1236; % a little above 100
%dotInfo.speed = 300;

%units are in 10th degree/second
dotInfo.speed = 50;


% old: dotInfo.maxDotTime = 4; %%%%%%%standardize this
% dotInfo.maxDotTime = (distance from center to edge) / (velocity of aperature) in seconds
%       distance in pixels = screenInfo.screenRect(1) / 2 * radius
%       velocity in pixels/second = (pixels / frame) * (frame / second)
%                                 = (apVel) * (screenInfo.monRefresh)
%if apVel == 0
%    dotInfo.maxDotTime = 2;
%else
%    dotInfo.maxDotTime = (screenInfo.screenRect(3) / 2 * dotInfo.apXYD(:,3)/2/10*screenInfo.ppd) ...
%                         / (apVel * screenInfo.monRefresh)
%end
    

dotInfo.dotColor = [255 255 255]; % white dots default

% dot size in pixels
dotInfo.dotSize = 5;

% fixation x,y coordinates
dotInfo.fixXY = [0 -20];
% fixation diameter
dotInfo.fixDiam = 20;
% fixation color
dotInfo.fixColor = [255 0 0];



% trialInfo.auto
% column 1: how to determine position of dots (relative to what): 1 to set
% manually, 2 to use fixation as center point, 3 to use aperture as center
% column 2: 1 to set coherence manually (just use one coherence repeatedly
% or set somewhere else), 2 random
% column 3: 1 to set direction manually (just use one direction repeatedly
% or set somewhere else), 2 random, 3 correction mode 
dotInfo.auto = [3 2 2];

% array for timimg
% CURRENTLY THERE IS AN ALMOST ONE SECOND DELAY FROM THE TIME DOTSX IS
% CALLED UNTIL THE DOTS START ON THE SCREEN! THIS IS BECAUSE OF PRIORITY.
% NEED TO EVALUATE WHETHER PRIORITY IS REALLY NECESSARY.
%
% FOR KEYPRESS ROUTINES
% for reaction time task
% 1. fixation on until targets on - if this is zero, than targets come on
%       with fixation, if don't want to show targets, make length 2
% 2. fixation on until dots on
% 3. max duration dots on
%
%
% for fixed duration task
% 1. fixation on until targets on - if this is zero, than targets come on
%       with fixation, if it is greater then time to dots on, comes on
%       after dots off. if greater than fix off, will come on at same time
%       as fix off.
% 2. fixation on until dots on
% 3. duration dots on
% 4. dots off until fixation off
% 5. time limit for keypress after fixation off
%
%


% variables for making delay periods
% itype = 0 fixed delay, minNum is actual delay time (need minNum)
% itype = 1 uniform distribution (need minNum and maxNum)
% itype = 2 exponential distribution (need all three)
dotInfo.itype = 0;
% min - get directly from trialInfo
dotInfo.imax = [];
dotInfo.imean = [];

%%%%%%% BELOW HERE IS STUFF THAT SHOULD GENERALLY NOT BE CHANGED!

% make time distributions - only has affect if variable distribution

dotInfo.maxDotsPerFrame = 300;   % by trial and error.  Depends on graphics card
% Use test_dots7_noRex to find out when we miss frames.
% The dots routine tries to maintain a constant dot density, regardless of
% aperture size.  However, it respects MaxDotsPerFrame as an upper bound.
% The value of 53 was established for a 7100 with native graphics card.

% possible keys active during trial
KbName('UnifyKeyNames')
dotInfo.keyEscape = KbName('escape');
dotInfo.keySpace = KbName('space');
dotInfo.keyReturn = KbName('return');


dotInfo.keyLeft = KbName('leftarrow');
dotInfo.keyRight = KbName('rightarrow');


if nargout < 1
save keyDotInfoMatrix dotInfo
end
end