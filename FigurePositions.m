function FigurePositions

% sets positions for display of an experiment's figures

DontStop = 1;
FigCount = 1;
q = 1;

%SetFigProps;
DeviceNumber = SetKBDeviceNumber;

while DontStop
    
    hh(FigCount) = figure(FigCount);
    disp('Press Return once you have positioned the figure...')
    WaitSecs(.2)
    DontStop = input('keep going or what? (1 or 0)');
%     while(1)
%         [KeyDown Secs KeyCode] = KbCheck(DeviceNumber);
%         if KeyDown
%             if any(KeyCode(kbname('Return')))
%                 break
%             elseif KeyCode(kbname('ESCAPE'))
%                 return
%             end
%         end
%         WaitSecs(.01)
%     end
    
    Pos(FigCount,:) = get(hh(FigCount), 'Position');
    
    FigCount = FigCount + 1;    
end

save('FigPositionsBoscoaaHW', 'Pos' );