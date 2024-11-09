function fig_h = mlFigure(fig_h, PaperSize, margin)

% Usage: fig_h = mlFigure([fig_h],[PaperSize: Width Height],[Margin: Bottom Left Top Right])
% 
% PaperSize is [Height Width] of the figure; PaperSize defaults to 7.5 x 10
% (Power point slide size)
% 
% Created by ML summer 2008

if ~exist('fig_h','var')
    fig_h = figure;
else
    figure(fig_h);
end

if ~exist('PaperSize','var')
    PaperSize = [10,7.5];   % in inches - this is PPT size
end

if ~exist('margin','var')
    margin = [0,0,0,0]; % in inches
end

fig_size_long = 800;  % [pixel] default:1000


set(fig_h,'PaperType','<custom>','PaperUnits','inches','PaperSize',PaperSize);

paper_size = get(fig_h,'PaperSize');
%plot_size = paper_size-margin*2;

plot_size = [paper_size(1)-margin(2)-margin(4),paper_size(2)-margin(1)-margin(3)]; % [9.5 7];

if paper_size(1)>paper_size(2)
    fig_size_short = round(fig_size_long*plot_size(2)/plot_size(1));
    fig_size = [fig_size_long fig_size_short];
else
    fig_size_short = round(fig_size_long*plot_size(1)/plot_size(2));
    fig_size = [fig_size_short fig_size_long];
end


% Figure orientation
paper_orientation = 'portrait';


% Figure position on the screen
screen_size = get(0,'ScreenSize');
fig_position(1) = (screen_size(3)-fig_size(1))/2;
fig_position(2) = screen_size(4)-fig_size(2);


set(fig_h,'PaperOrientation',paper_orientation,'Position',[fig_position fig_size]);
paper_size = get(fig_h,'PaperSize');
set(fig_h,'PaperPosition',[margin(1) margin(2) paper_size-[margin(1),margin(2)]-[margin(3),margin(4)]]);

0;


%{

NOTE: to save a particular figure as it is, use "getframe". Returns a 
struct array - for x = getframe(gca); x.cdata will contain the image of the 
figure. Limtied to screen resolution.

%}

