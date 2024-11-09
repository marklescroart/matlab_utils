function mlBV_VMRmovie(VMRfile,MovieName,TitleStr)

% Usage: mlVMRmovie(VMRfile,MovieName,TitleStr)
%
%
% Created by ML 2009.04.23

% VMRf = 'AM_Base_ACPC.vmr';

if ~exist('PrintDir','var')
    PrintDir = 'TmpMovie';
end
if ~exist(PrintDir,'dir')
    mkdir(PrintDir);
end
if ~exist('TitleStr','var')
    TitleStr = {'Your Brain'}; %{'Andrew''s Big';'Fat Brain'}
end
if ~exist('MovieName','var')
    MovieName = 'VMRMovie.mpg';
end

nFramesForStart = 25;

VMR = BVQXfile(VMRfile);

Vv = VMR.VMRData;
Sz = size(Vv);

mlFigure(1,[max(Sz)/100,max(Sz)/100]);
set(1,'Position',[400 300 400 400]);

Rr = [0 -90 -90]; % Image rotation. BV coordinates give upside-down / sideways brains.
whitebg([0 0 0])
Ct = 1;

for iLead = 1:nFramesForStart;
    T = text(.5,.5,TitleStr,'fontname','Arial','color','w');
    set(T,'horizontalalignment','center','fontsize',18);
    whitebg([0,0,0])
    set(gca,'visible','off');
    set(gca,'xtick',[],'ytick',[]);
    set(1,'color',[0 0 0])
    set(gcf, 'InvertHardCopy', 'off');
    drawnow;
    print('-f1','-dpng','-r100',fullfile(PrintDir,sprintf('Frame_%03d',Ct)));
    Ct = Ct+1;
end
0;
for iDir = 1:3;
    WhichSlice = {':',':',':'};
    WhichSlice{iDir} = 'iSlice';
    for iSlice = 1:Sz(iDir);
        TmpIm = eval(['Vv(' WhichSlice{1} ',' WhichSlice{2} ',' WhichSlice{3} ');']);
        TmpIm = squeeze(TmpIm);
        TmpIm = imrotate(TmpIm,Rr(iDir));
        imshow(TmpIm,[],'initialmagnification','fit')
        set(gca,'Position',[0 0 1 1])
        drawnow;
        print('-f1','-dpng','-r100',fullfile(PrintDir,sprintf('Frame_%03d',Ct)));
        Ct = Ct+1;
    end
end

mlMPGfromStills(MovieName,1,PrintDir)

YN = questdlg('Delete temporary image folder?');

if strcmp(YN,'Yes')
    rmdir(PrintDir,'s')
end
