function whiteSquareFlash(screenInfo,flashDuration)

hLength = screenInfo.screenRect(3);
vLength = screenInfo.screenRect(4);
sideLen = hLength/50;

Screen('FillRect', screenInfo.curWindow, [255 255 255], ...
    [hLength - hLength/20 - sideLen ...
     vLength - vLength/20 - sideLen ...
     hLength - hLength/20  ...
     vLength - vLength/20]);
Screen('Flip',screenInfo.curWindow);
pause(flashDuration); 
Screen('Flip',screenInfo.curWindow);

end