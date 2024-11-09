function mlFigTitle(h,TitStr,TitSpace,FontSize)

% Usage: mlFigTitle(h,TitStr,TitSpace,FontSize)

%%% Inputs: 
if ~exist('h','var')
    h = 1;
end
% if TitStr and TitSpace don't exist, you're fucked.
if ~exist('FontSize','var')
    FontSize = 18;
end

%%% Calculations: 
figure(h);
axes('Position',TitSpace);

text(.5,.5,TitStr,'horizontalalignment','center','fontsize',FontSize)

axis off;