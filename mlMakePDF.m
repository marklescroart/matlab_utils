function mlMakePDF(PDFName,ImType,PDFSize)

% Makes PDF file from multiple images. Useful.
% PDFSize = [Width Height];

% To add: index for images, fix aspect ratio / allow black space to exist
% Set default size to be image size (or image aspect ratio, at least)


F = mlStructExtract(dir(['*' ImType]),'name');

% Idx = [1 3 2];
% for i = 1:12; Idx = [Idx,Idx((end-2):end)+3]; end
% F = F(Idx);

% for i = 1:length(F);
%     tmp = regexp(F{i},'[\d]*(?=-)','match');
%     if isempty(tmp)
%         tmp = {'1'};
%     end
%     try
%         N(i) = str2num(tmp{1});
%     catch 
%         0; % For debugging only
%     end
% end
% 
% [aa, idx] = sort(N);
% 
% F = F(idx);
% F = F([1,33,30,31,32,29,2:28]);

for iPDF = 1:length(F)
    tmp = imread(F{iPDF});
    %tmp = imrotate(tmp,-90);
    % Image size:
    H = size(tmp,1);
    W = size(tmp,2);
    if size(tmp,3)==1
        tmp = repmat(tmp,[1 1 3]);
    end
    % For display:
    Scr = get(0,'screensize');
    ScrW = Scr(3);
    ScrH = Scr(4);
    
    AspRat = H/W;
    
    PapW = PDFSize(1); % 300 dpi, one pix/2dots?
    PapH = PDFSize(2); %AspRat*10;
    
    h = figure(1);
    
    set(h,'units','pixels');
    set(h,'Position',[ScrW/2-W/2,ScrH/2-H/2,W,H])
    
    set(h,'units','inches');
    set(h,'PaperSize',[PapW,PapH])
    
    image(tmp);
    axis off
    
    set(gca,'position',[0,0,1,1]); 
    set(h,'PaperPosition',[0 0 PapW PapH],'PaperUnits','inches')
    
    SaveNm{iPDF} = sprintf('%s/TempPg%0.0f.pdf',pwd,iPDF);
    saveas(h,SaveNm{iPDF},'pdf')
    0;
end

mlMergePDF(PDFName,SaveNm{:})
delete(SaveNm{:});