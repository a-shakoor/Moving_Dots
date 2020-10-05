function esc = checkForEsc() 
    esc = 0;
    [keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown
        if any(keyCode([KbName('ESCAPE')]))
            esc = 1;
        end
    end
    KbQueueRelease();
end