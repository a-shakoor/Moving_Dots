 function fixationCross(onDuration, crossSize, screenInfo)
    screenRect = screenInfo.screenRect;
    curWindow = screenInfo.curWindow;
    crossRect1 = [screenRect(3) / 2-crossSize/2,screenRect(4) / 2-crossSize/10,screenRect(3) / 2+crossSize/2,screenRect(4) / 2+crossSize/10];
    crossRect2 = [screenRect(3) / 2-crossSize/10,screenRect(4) / 2-crossSize/2,screenRect(3) / 2+crossSize/10,screenRect(4) / 2+crossSize/2];
    Screen('FillRect',curWindow,[255 255 255],crossRect1)
    Screen('FillRect',curWindow,[255 255 255],crossRect2)
    Screen('Flip', curWindow);
    pause(onDuration);
    Screen('Flip', curWindow);
 end