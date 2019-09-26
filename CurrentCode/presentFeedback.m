function presentFeedback(screenInfo, isCorrect)

Screen('TextFont',screenInfo.curWindow, 'Arial');
Screen('TextSize',screenInfo.curWindow, 100);
Screen('TextStyle', screenInfo.curWindow, 0);
Screen('TextSize', screenInfo.curWindow, 100);


% Screen(‘DrawText’, windowPtr, text [,x] [,y] [,color] [,backgroundColor] 
%       [,yPositionIsBaseline] [,swapTextDirection]);
if isCorrect
    [~,~,~] = Screen('DrawText', screenInfo.curWindow, 'CORRECT', ...
        screenInfo.screenRect(3) / 2.8, screenInfo.screenRect(4) / 2 - 50, [0 255 0])
else
    [~,~,~] = Screen('DrawText', screenInfo.curWindow, 'INCORRECT', ...
        screenInfo.screenRect(3) / 2.8, screenInfo.screenRect(4) / 2 - 50, [255 0 0])
end
Screen('Flip',screenInfo.curWindow);
pause(0.5);

end