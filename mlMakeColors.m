function mlMakeColors

% Usage: mlMakeColors
% 
% Defines colors used by Mark Lescroart in functions / whatever. 
% 
% Created by ML

SaveColors = 1;

Red =           [255 0 0];
RedOrange =     [255 75 0];
Orange =        [255 135 0];
YellowOrange =  [255 155 0];
Yellow =        [255 255 0];
YellowGreen =   [127 255 0];
Green =         [0 255 0];
BlueGreen =     [0 255 135];
Blue =          [0 0 255];
Violet =        [200 0 200];


% Yellows:

Mustard =       [255 235 0];
Flesh =         [255 255 199];
DirtyYellow =   [125 100 0];
Gold =          [255 206 0];

% Reds:

Cherry =        [177 0 0];
Cardinal =      [153 0 0]; %official USC red
SoftRed =       [235 0 75];
Pink =          [255 45 255];
LightPink =     [255 150 200];
DarkRed =       [135 25 25];

% Cool:

LightGreen =    [150 255 75];
SoftGreen =     [0 255 75];
DarkDarkGreen = [25 100 25];
MidnightBlue =  [0 0 100];
DarkBlue =      [0 0 140];
LOBlue =        [59 88 136];
LightBlue =     [75 150 255];
Purple =        [120 0 120];
Cyan =          [0 255 255];    % This is pretty bright
PastelBlue =    [120 134 255];
Lavender =      [200 54 255];
DeepPurple =    [80 0 80];

% Grayscale:

Gray200 =       [200 200 200];
Gray128 =       [128 128 128];
Gray111 =       [111 111 111];
Black =         [0 0 0];
White =         [255 255 255];

if SaveColors
    clear SaveColors;
    save MLColors.mat
end

WhichColor = 1;
WhichSquare = 1;

while WhichSquare < 17
    disp('What color do you want to be next on the palatte?');
    WhichColor = input('(1 to display options, 0 to quit)    ', 's');
    disp(' ');

    if strcmp(WhichColor, '1') == 1
        who
        disp('Which will it be?');
        WhichColor = input(' ', 's');
    elseif strcmp(WhichColor, '0') == 1
        return
    end
    
    h = figure(1);
    set(h, 'NumberTitle', 'off')
    set(h, 'Name', 'Color Palatte');
    set(h, 'MenuBar', 'none');
    %set(h, 
    subplot(4,4,WhichSquare);
    ColorSquare = 111.*ones(30,30,3);
    
    RGBValue = eval(WhichColor);
    
    for Layer = 1:3
        ColorSquare(5:25,5:25, Layer) = RGBValue(Layer);
    end

    ColorSquare = uint8(ColorSquare);
    image(ColorSquare);
    title(WhichColor);
    axis off;
    WhichSquare = WhichSquare + 1;
end


