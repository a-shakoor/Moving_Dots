 function calibrationCircle(onDuration, radius, screenInfo)
    screenRect = screenInfo.screenRect;
    curWindow = screenInfo.curWindow;
    rect = [screenRect(3)/2-radius,screenRect(4)/10-radius,screenRect(3)/2+radius,screenRect(4)/10+radius];
    Screen('FillOval',screenInfo.curWindow,[255 255 255],rect)
    Screen('Flip', curWindow);
    pause(onDuration);
    Screen('Flip', curWindow);
 end