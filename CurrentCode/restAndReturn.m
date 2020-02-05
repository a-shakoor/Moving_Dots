function restAndReturn(screenInfo, crossSize, restDuration, returnDuration)
    curWindow = screenInfo.curWindow;
    
    restMessage = append('Rest for ', num2str(restDuration), ' Seconds');

    Screen('TextFont',curWindow, 'Arial');
    Screen('TextSize',curWindow, 100);
    Screen('TextStyle', curWindow, 0);
    Screen('TextSize', curWindow, 100);
    Screen('DrawText', curWindow, restMessage, ...
        screenInfo.screenRect(3) / 4, screenInfo.screenRect(4) / 2, [255 0 0]);
    Screen('Flip',curWindow);

    pause(restDuration);

    Screen('DrawText', curWindow, 'Get Ready...', ...
    screenInfo.screenRect(3) / 2.8, screenInfo.screenRect(4) / 10, [255 0 0]);           
    crossRect1 = [screenInfo.screenRect(3) / 2-crossSize/2,screenInfo.screenRect(4) / 2-crossSize/10,screenInfo.screenRect(3) / 2+crossSize/2,screenInfo.screenRect(4) / 2+crossSize/10];
    crossRect2 = [screenInfo.screenRect(3) / 2-crossSize/10,screenInfo.screenRect(4) / 2-crossSize/2,screenInfo.screenRect(3) / 2+crossSize/10,screenInfo.screenRect(4) / 2+crossSize/2];
    Screen('FillRect',curWindow,[255 255 255],crossRect1)
    Screen('FillRect',curWindow,[255 255 255],crossRect2)
    Screen('Flip',curWindow);
    
    pause(returnDuration);
end