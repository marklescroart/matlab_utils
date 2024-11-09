function mlGraphSetup_big(Title,Xlabel,Ylabel,xlim,ylim,xtick,xticklabel,ytick,yticklabel)

% Usage: mlGraphSetup(Title,Xlabel,Ylabel [,xlim,ylim,xtick,xticklabel,ytick,yticklabel])
% 
% Setting all graph properties at one go.
% 
% All inputs past Ylabel are optional; put in empty fields ("[]") if you do
% not wish to specify or change an input, enter "NaN" for xticklabel or 
% yticklabel to specify NO values printed on the axes. Keep to the variable 
% order.
% 
% Created by ML 04.28.08

if ~exist('Title','var')
    Title = get(get(gca,'title'),'string');
end
if ~exist('Xlabel','var')
    Xlabel = get(get(gca,'xlabel'),'string');
end
if ~exist('Ylabel','var')
    Ylabel = get(get(gca,'ylabel'),'string');
end


title(Title,'fontname','Arial','fontsize',36,'fontweight','Bold');
xlabel(Xlabel,'fontname','Arial','fontsize',24);
ylabel(Ylabel,'fontname','Arial','fontsize',24);
set(gca,'lineWidth',2,'fontsize',20,'fontname','Arial');

Vars = {'xlim','ylim','xtick','xticklabel','ytick','yticklabel'};
for i = 1:length(Vars);
    if exist(Vars{i},'var')&&~isempty(eval(Vars{i}))
        if iscell(eval(Vars{i}))
            set(gca,Vars{i},eval(Vars{i}))
            continue;
        end
        if isnan(eval(Vars{i}))
            set(gca,Vars{i},[])
        end
        set(gca,Vars{i},eval(Vars{i}));
    end
end

set(gca,'Layer','top')
set(gca,'box','on')