function mlMRI_3DMCinfo

% Getting motion correction information from dicom headers

% DIR = uigetdir('/Applications/MATLAB74/MarkCode','Pick a directory');
if ~exist('PlotOn','var')
    PlotOn = 0;
end

try
    aa = mlStructExtract(dir('*.dcm'),'name');
catch
    aa = mlStructExtract(dir,'name');
    aa = grep(aa,'-v','.');
end

for ii = 1:length(aa); 
    bb(ii) = str2num(aa{ii}(end-7:end-4)); 
end
ScanStartIdx = find(bb==1);
nScans = length(ScanStartIdx);
fprintf('Detected %.0f scans\n',nScans);

LastScan = 'xxx';
fid = fopen('DummyFileDeleteMe.dat','a');
for ii = 1:length(aa)
    DI = dicominfo(aa{ii});
    ScanNm = DI.ProtocolName;
    if ~isfield(DI,'ImageComments')
        %fprintf('Run %s better be an anatomical.\n',aa{ii})
        continue
    end
    if strcmp(LastScan,ScanNm) %First vol will be called: 'Reference volume for motion correction.' - but we avoid that here.
        ss = str2num(DI.ImageComments(8:end));
        fprintf(fid,[repmat('%.4f\t',1,6) '\n'],ss(:));
    else
        fclose(fid);
        fname = ['Sub_' DI.PatientName.GivenName '_' DI.ProtocolName '_3DMCinfo.dat'];
        fid = fopen(fname,'a');
        fprintf('Writing file %s\n',fname)
    end
    LastScan = ScanNm;
end

delete DummyFileDeleteMe.dat
fclose(fid);


% Plotting: 
if PlotOn
    mlMRI_3DMCplot;
end
if strcmp('MACI',computer);
    movefile('*.dat','../PRTs_RTCs/');
end