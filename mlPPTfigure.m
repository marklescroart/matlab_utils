function fig_h = mlPPTfigure()

margin = 0.25; % [cm] default:0.5
fig_size_long = 1000;  % [pixel] default:1000

%main start ==============================================================

fig_h = figure('PaperType','<custom>','PaperUnits','inches','PaperSize',[10 7.5]);
paper_size = get(gcf,'PaperSize');
plot_size = paper_size-margin*2;
fig_size_short = round(fig_size_long*plot_size(1)/plot_size(2));


% Figure orientation
paper_orientation = 'portrait';
fig_size = [fig_size_long fig_size_short];


% Figure position on the screen
screen_size = get(0,'ScreenSize');
fig_position(1) = (screen_size(3)-fig_size(1))/2;
fig_position(2) = screen_size(4)-fig_size(2);


set(gcf,'PaperOrientation',paper_orientation,'Position',[fig_position fig_size]);
paper_size = get(gcf,'PaperSize');
set(gcf,'PaperPosition',[margin margin paper_size-margin*2]);