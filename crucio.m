function crucio

% For punishing bad behavior.
% Written by ML 2009/01/30
% Improved 2009/02/03

WaitSecs(.3);
[KeyPressed Time KeyCode] = KbCheck;

TimePast = GetSecs;
if strcmpi(computer,'MACI')
    disp('Press and hold a key to relent.')
    disp('(This is no fun if your sound isn''t on)')
    Ow = {'Ow','What the hell!','Stop it!','That hurts!','Ow','Eye m sorry already!','Ow','I wohnt do it again!','Ow'};
    RepTime = .01;
else
    Ow = {'What the hell!','Stop it!','That hurts!','I''m sorry already!','aaaaaaahhhh!','I won''t do it again!'};
    RepTime = .1;
end

while ~KeyPressed
    [KeyPressed Time KeyCode] = KbCheck;
    if Time>TimePast+RepTime;
        if strcmpi(computer,'MACI')
            eval(['!say -v Fred ' Ow{ceil(length(Ow)*rand)}]);
        else
            disp(Ow{ceil(length(Ow)*rand)});
        end
        TimePast = Time;
    end
    WaitSecs(.01);
end