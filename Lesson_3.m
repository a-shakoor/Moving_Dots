%% Lesson 3: A 2AFC trial
%
% The goal in this lesson is to generate code to run a two-alternative
% forced-choice trial on a field of partially coherent moving dots.  The
% subject will decide after a stimulus whether the overall motion of the
% dots was upward or downward.

%%  the 'movingDots' function
%
% Just like on a TV cooking show, I've written a useful function based on
% some of the ideas in Lesson 2 that we can pull out of the oven that
% animates moving dot stimuli.  You can see how to use it by typing:

help movingDots

%%
% movingDots.m can put up multiple fields of moving dots along with a
% fixation spot. Each field can have its own speed, direction, color,
% lifetime, aperture size and location, size of dots and 'coherence' (more
% on coherence later).
%
% Here's an example of two fields of overlapping dots on one side of the
% screen - one red moving upward and one green moving downward.
%

clear display dots
% Set display parameters
display.dist = 50;  %cm
display.width = 30; %cm
display.skipChecks = 1; %avoid Screen's timing checks and verbosity

% Field 1: Upward moving red dots
dots(1).nDots = 100;
dots(1).speed = 5;
dots(1).direction = 0;
dots(1).lifetime = 5;
dots(1).apertureSize = [6,6];
dots(1).center = [-7.5,0];
dots(1).color = [255,0,0];
dots(1).size = 5;
dots(1).coherence = 1;

% Field 2: Downward moving green dots
dots(2).nDots = 100;
dots(2).speed = 5;
dots(2).direction = 180;
dots(2).lifetime = 5;
dots(2).apertureSize = [6,6];
dots(2).center = [-7.5,0];
dots(2).color = [0,255,0];
dots(2).size = 5;
dots(2).coherence = 1;

duration = 5; %seconds
try
    display = OpenWindow(display);
    movingDots(display,dots,duration);
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');



%% Motion coherence
%
% The 'strength' of a moving dot stimulus is typically manipulated by
% changing the 'coherence' of the field, which is the proportion of dots
% moving in a particular direction.  If there are 100 dots with direction 0
% (up)0 and the coherence is set to 0.25, then 25 of the dots will move
% upward and the other 75 will be given random directions uniformly
% distributed from 0-360 degrees.
%
% Here's an example of a single field of 15% coherent white dots in the
% center of the screen.

clear dots
dots.nDots = 200;
dots.speed = 5;
dots.direction = 0;
dots.lifetime = 12;
dots.apertureSize = [12,12];
dots.center = [0,0];
dots.color = [255,255,255];
dots.size = 8;
dots.coherence = .15;

duration = 5; %seconds
try
    display = OpenWindow(display);
    movingDots(display,dots,duration);
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%%
% Did you see the weak upward motion?  15% coherence should be near your
% threshold for detecting motion.

%% The 'drawFixation' function
%
% Notice the fixation spot.  This was drawn by my function
% 'drawFixation.m'.  It draws a box-shaped fixation point on top of a
% circular mask on every frame at the center of the screen. You can see how
% to use it by getting help:

help drawFixation

%%
% The default values were used in the demo above.  You can change them by
% changing values the display structure like this:

display.fixation.size = .25;  %default is .5 degrees
display.fixation.color = {[255,0,0],[0,0,255]};  %default is white and black
display.fixation.mask = 1;  %default is 2 degrees

try
    display = OpenWindow(display);
    movingDots(display,dots,duration);
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%% Getting key press information
%
% In order to get a subject's response, we need to read the keyboard.  The
% best way to do this is with the PsychToolbox's 'KbCheck' function and its
% related friends.
%
% KbCheck returns three arguments:
%[ keyIsDown, timeSecs, keyCode ] = KbCheck;
%
% The first argument is a binary (or 'logical') variable that is 'true' if
% a key is currently being pressed.  The second is a value related to the
% time the key was first pressed, and the third is an integer that is a
% code for the key that was pressed. To decode the key code, use the
% function 'keyCode' which translates the integer into a string.
%
% Typically, KbCheck isn't used all by itself - it needs to be placed in a
% loop that keeps calling KbCheck and then handles the output.  This may
% seem like a hassle, but it's very useful because it gives you a lot of
% flexibility about how you handle subject responses.
%
% Here's a simple example using KbCheck to wait for the user to press a key
% and then displays the key that was pressed and how long the subject took
% to respond.

%disable output to the command window
ListenChar(2);

keyIsDown = 0;
startTime = GetSecs;  %read the current time on the clock
disp('Please press a key.');
while ~keyIsDown  %if the key is not down, go into the loop
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;  %read the keyboard
end
%enable output to the command window
ListenChar(0);

%determine which key was pressed
key = KbName(keyCode);
%calculate the reaction time
RT = timeSecs-startTime;
%display the result
disp(sprintf('You pressed the "%s" key after %5.2f seconds',key,RT));

%%
% How does this work?  The program goes into the 'while' loop and spins
% around until the variable 'keyIsDown' changes to anything but zero as the
% result of a key press.  When this happens, the control flows out of the
% loop where the key is decoded and RT is calculated.  The PsychToolbox
% function 'GetSecs' returns a high-precision clock time, where zero is
% arbitrary - it's values are useful only with respect to other calls to
% GetSecs.
%
% Here's a somewhat silly example using GetSecs.  The clock is first read
% and stored as variable 'a'.  The program then pauses for one second using
% Matlab's 'pause' function, and the clock is read again but stored into
% the variable 'b'.  The values of a and b are basically meaningless on
% their own, but their difference reflects the time between calls to
% GetSecs:

a = GetSecs
pause(1)
b = GetSecs
disp(sprintf('Time Elapsed: %5.4f seconds',b-a));

%%
% You might notice that the time, b-a, is not exactly equal to 1.00
% seconds.  This discrepancy is due to inaccuracy with 'pause', not
% 'GetSecs'.

%% The 'waitTill' function
%
% I've written a simple keyboard reading function using 'KbCheck' that
% aborts the wait after a predetermined amount of time.  This is useful for
% experiments where the timing of the trials is important - such as in fMRI
% experiments where you have to get on with things if the subject doesn't
% respond in time.  Here's an example of how to use it.
%
% Run the next line of code and type stuff into the keyboard for the next
% few seconds:

disp('Please press some keys over the next five seconds');
tic
[keys,RTs] = waitTill(5);
toc
for i=1:length(keys)
    disp(sprintf('You pressed the "%s" key after %5.2f seconds',keys{i},RTs(i)));
end

%%
% 'waitTill' can take in a second argument that holds the current time on
% the clock, as defined by the function GetSecs. This will be useful later
% when we're dealing with trial sequences and want to pause the program
% until the clock reaches a certain time.


%% Drawing text in real-world coordinates
%
% Often in experiments we put up text strings for instructions to the
% observer.  We'll do that in a bit to instruct the observer to press a key
% to begin, and to tell the observer which keys to press for a response.
%
% We used the 'DrawText' function in Screen back in Lession 1.  This
% draws a text string in a specified color with the upper-left corner at a
% specified location in pixel coordinates.  Text parameters can be set
% using Screen functions like 'TextSize'.  
%
% I find this a bit clumsy, especially because I can't center the text.
% I've written a program 'drawText' that uses Screen's 'DrawText' but
% centers the text in real-world coordinates centered at the desired
% location.  Here's some help on that function:

help drawText

%%
%Here's an example of how it works:

clear display

% Set display parameters
display.dist = 50;  %cm
display.width = 30; %cm
display.skipChecks = 1; %avoid Screen's timing checks and verbosity

% display.text.size = 40;
 display.text.color = [255,255,0];
% display.text.style =2; display.text.font = 'Helvetica';

try
    display = OpenWindow(display);
    display = drawText(display,[0,0],'Don''t you love this Matlab class?');
    Screen(display.windowPtr,'Flip');
    waitTill(2);
    Screen(display.windowPtr,'Flip');
    waitTill(.25);
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%% A 2AFC trial with feedback
%
% We're ready to present a partially correlated moving stimulus that could
% be either moving upward or downward, get the subject's response, and
% provide feedback by flashing the fixation green (correct) or red
% (incorrect).

%%
% First, we'll define the display and dot stimulus from scratch

clear display dots

% Set display parameters
display.dist = 50;  %cm
display.width = 30; %cm
display.skipChecks = 1; %avoid Screen's timing checks and verbosity

% Set up dot parameters
dots.nDots = 200;
dots.speed = 5;
dots.lifetime = 12;
dots.apertureSize = [12,12];
dots.center = [0,0];
dots.color = [255,255,255];
dots.size = 8;
dots.coherence = .5;

duration = 1; %seconds

%choose either up or down for the dot direction
trialDirection = ceil(rand(1)+.5);  %50/50 chance of a 1 (up) or a 2 (down)
dots.direction = (trialDirection-1)*180; %1 -> 0 degrees, 2 -> 180 degrees

%Start the trial

try
    display = OpenWindow(display);

    drawText(display,[0,6],'Press "u" for up and "d" for down',[255,255,255]);
    drawText(display,[0,5],'Press Any Key to Begin.',[255,255,255]);

    display = drawFixation(display);

    %while KbCheck; end
    KbWait;

    %Show the stimulus d
    movingDots(display,dots,duration);

    %Get the response within the first second after the stimulus
    keys = waitTill(1);

    %Interpret the response provide feedback
    if isempty(keys)  %No key was pressed, yellow fixation
        correct = NaN;
        display.fixation.color{1} = [255,255,0];
    else
        %Correct response, green fixation
        if (keys{end}(1)=='u' && dots.direction == 0) || (keys{end}(1)=='d' && dots.direction == 180)
            correct = 1;
            display.fixation.color{1} = [0,255,0];
            %Incorrect response, red fixation
        elseif (keys{end}(1)=='d' && dots.direction == 0) || (keys{end}(1)=='u' && dots.direction == 180)
            correct = 0;
            display.fixation.color{1} = [255,0,0];
            %Wrong key was pressed, blue fixation
        else
            correct = NaN;
            display.fixation.color{1} = [0,0,255];
        end
    end

    %Flash the fixation with color
    drawFixation(display);
    waitTill(.5);
    display.fixation.color{1} = [255,255,255];
    drawFixation(display);
    waitTill(.5);

catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%% Exercises
%
% # Edit the program above to loop through 10 trials of the 2AFC motion
% experiment and calculate your percent correct.
% # Repeat this for the following coherence levels: .1,.2,.3,.4,.5.  Then
% plot the percent correct on the y-axis as function of the coherence on
% the x-axis.  This is a 'psychometric function'
% # Use the 'drawText' and 'waitTill' to measure the response times on a
% Stroop task:  Put up, for example, the word 'GREEN' in red text and have
% the subject type the first letter of the written word.  Compare the RT's
% for this compared to when the color of the text matches the word.  











