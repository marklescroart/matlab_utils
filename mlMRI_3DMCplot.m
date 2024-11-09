function mp = mlMRI_3DMCplot(whichrun)

Cut = 0;

if ~exist('whichrun','var')
    fnms = mlStructExtract(dir('*.dat'),'name');
    Run = 1:length(fnms);
    pp = [321 322 323 324 325 326];
    OneRun = 0;
else
    OneRun = 1;
    Run = 1;
    fnms = {whichrun};
    %Pos = TileFigs(length(fnms)); 
end

for iF = Run
    mp{iF} = importdata(fnms{iF}); 
    if Cut
        mp{iF} = mp{iF}(28:end,:);
    end
    %if ~OneRun
    %    subplot(pp(iF));
    %else
        figure; %('Position',Pos(iF,:));
    %end
    set(gca,'fontsize',18);
    LL = {'x trans' 'y trans' 'z trans' 'x rot' 'y rot' 'z rot'};
    RunNum = {'xx'}; %regexp(fnms{iF},'(?<=Run)[0-9]*','match');
    SubID = regexp(fnms{iF},'(?<=Sub_)[A-Z]*','match');
    plot(mp{iF}); 
    title(sprintf('Subject %s Run %s',SubID{1},RunNum{1})); %,'fontsize',18);
    ylabel('Head motion (mm)')
    %xlabel('Time (seconds)')
    ylim([-1.5 1.5]); 
    %title({strrep(fnms{iF},'_',' ')...
    %    sprintf('%9s  ',LL{:}) ...
    %    sprintf('%11.4f',std(mp{iF}))});
    if OneRun;
        
        legend(LL);
    end
    %whitebg([0 0 0 ])
end
%subplot(7,7,18);
%plot(ones(10,6));
