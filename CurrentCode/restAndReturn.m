function restAndReturn(screenInfo, crossSize, restDuration, returnDuration)
    curWindow = screenInfo.curWindow;
    maxWaitTime = restDuration;

    
    %% Rest Message
    restMessage1 = 'Rest your eyes.';
    restMessage2 = 'Press space bar when ready.';
    Screen('TextFont',curWindow, 'Arial');
    Screen('TextSize',curWindow, 100);
    Screen('TextStyle', curWindow, 0);
    Screen('TextSize', curWindow, 100);
    Screen('DrawText', curWindow, restMessage1, ...
        screenInfo.screenRect(3) / 4, screenInfo.screenRect(4) / 2, [255 0 0]);
    Screen('DrawText', curWindow, restMessage2, ...
        screenInfo.screenRect(3) / 4, screenInfo.screenRect(4) / 2 + 150, [255 0 0]);
    Screen('Flip',curWindow);
    
    %% Wait for spacebar
    KbQueueRelease();
    initDecisionTimeFrames = round(restDuration * screenInfo.monRefresh);
    decisionTimeFrames = initDecisionTimeFrames;
    answered = 0;
    while (decisionTimeFrames > 0 || decisionTimeFrames < 0) && ~answered
        decisionTimeFrames = decisionTimeFrames - 1;
        [keyIsDown,secs,keyCode] = KbCheck;
        if keyIsDown
            if any(keyCode([KbName('space')]))
                answered = 1;
            end
        end
        KbQueueRelease();
        Screen('WaitBlanking', screenInfo.curWindow);
    end %while
    
    

    Screen('DrawText', curWindow, 'Get Ready...', ...
    screenInfo.screenRect(3) / 2.8, screenInfo.screenRect(4) / 10, [255 0 0]);           
    crossRect1 = [screenInfo.screenRect(3) / 2-crossSize/2,screenInfo.screenRect(4) / 2-crossSize/10,screenInfo.screenRect(3) / 2+crossSize/2,screenInfo.screenRect(4) / 2+crossSize/10];
    crossRect2 = [screenInfo.screenRect(3) / 2-crossSize/10,screenInfo.screenRect(4) / 2-crossSize/2,screenInfo.screenRect(3) / 2+crossSize/10,screenInfo.screenRect(4) / 2+crossSize/2];
    Screen('FillRect',curWindow,[255 255 255],crossRect1)
    Screen('FillRect',curWindow,[255 255 255],crossRect2)
    Screen('Flip',curWindow);
    
    pause(returnDuration);
end