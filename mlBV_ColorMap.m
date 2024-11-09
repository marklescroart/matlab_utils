% This is only an example for now - for how to make a Brain Voyager color
% map:
% 1:
% [LUT,ColBar] = mlColorOpponencyBar([255 0 0; 0 255 255; 0 0 255],[10,10],10);
% 2:
% [LUT,ColBar] = mlColorOpponencyBar([0 0 255; 0 255 255; 255 0 0],[10,10],10);
% 3:
% [LUT,ColBar] = mlColorOpponencyBar([0 0 255; 255 255 0; 255 0 0],[10,10],10);
% 4:
% [LUT,ColBar] = mlColorOpponencyBar([255 0 0; 0 255 255; 0 0 255; 255 255 0; 255 0 0],[5,5,5,5],10);
% 5:
% [LUT,ColBar] = mlColorOpponencyBar([0 0 255; 0 255 255; 255 0 0; 255 255 0; 0 0 255],[5,5,5,5],10);
% 6:
% [LUT,ColBar] = mlColorOpponencyBar([0 0 255; 255 255 0; 255 0 0; 0 255 255; 0 0 255],[5,5,5,5],10);
% 7:
% [LUT,ColBar] = mlColorOpponencyBar([255 0 0; 255 255 0; 0 0 255; 0 255 255; 255 0 0],[5,5,5,5],10);
% 8:
% [LUT,ColBar] = mlColorOpponencyBar([0 0 255; 255 255 0],[20],10);
% 9:
% [LUT,ColBar] = mlColorOpponencyBar([0 255 255; 0 0 255; 255 255 0; 255 0 0; 0 255 255],[5,5,5,5],10);
% 10:
[LUT,ColBar] = mlColorOpponencyBar([0 0 255; 255 255 0; 0 0 255],[10,10],10);
LUT = round(LUT);
% Double Check:
%colormap(LUT/255);
%colorbar;

% 1:
% fid = fopen('Red_Cyan_Blue.olt','w');
% 2:
% fid = fopen('Blue_Cyan_Red.olt','w');
% 3:
% fid = fopen('Blue_Yellow_Red.olt','w');
% 4:
% fid = fopen('Red_Cyan_Blue_Yellow_Red.olt','w');
% 5:
% fid = fopen('Blue_Cyan_Red_Yellow_Blue.olt','w');
% 6:
% fid = fopen('Blue_Yellow_Red_Cyan_Blue.olt','w');
% 7:
% fid = fopen('Red_Yellow_Blue_Cyan_Red.olt','w');
% 8:
% fid = fopen('BlueToYellowFade.olt','w');
% 9:
%fid = fopen('Cyan_Blue_Yellow_Red_Cyan.olt','w');
% 10:
fid = fopen('BlueToYellowFade_PosNeg.olt','w');

for i = 1:length(LUT);
    fprintf(fid,'Color%d: %d %d %d\n',i,LUT(i,1),LUT(i,2),LUT(i,3)); 
end

fclose(fid);