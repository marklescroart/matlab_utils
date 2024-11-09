function [] = LinkPRT2VTC(vtclistfile,prtlistfile)

% Usage: LinkPRT2VTC([vtclistfile, prtlistfile])
%
% Quickly links any number of .vtc files to .prt files. Requires two text
% documents as inputs. These can be specified as (string) input arguments 
% or chosen from a pop-up dialog box. The files must have the format:
% 
% General:                Specific:
% (NumberOfprtFiles)      3
% (filename1).prt         Run1.prt
% (filename2).prt         Run2.prt
% ...                     Run3.prt
% 
% and 
% 
% (NumberOfvtcFiles)      3
% (filename1).vtc         Run1.vtc
% (filename2).vtc         Run2.vtc
% ...                     Run3.vtc
% 
% NOTE: the file names need not be the same (besides the extension) for the
% .prt and .vtc files, and they do not need to follow any naming
% convention. They only need to be in the desired order. 
% 
% Created by Ben Godde

% Modified by ML 4.16.07

% Dealing with absent inputs:
if nargin == 1
    error('I need both a .prt and a .vtc file, please.')
elseif nargin < 2
    [filename, pathname] = uigetfile('*.txt','Pick the vtc-filelist');
    vtclistfile = fullfile(pathname, filename);
    [filename, pathname] = uigetfile('*.txt','Pick the prt-filelist');
    prtlistfile = fullfile(pathname, filename);
end

% Read VTC list -> vtclist
vtclist = importdata(vtclistfile,'\n');
n=str2num(vtclist{1});
disp([num2str(n),' pairs have to be linked']);

% Read PRT list -> prtlist
prtlist = importdata(prtlistfile,'\n');

% Link files
for ii = 2:n+1
    vtc=vtclist{ii};
    prt=prtlist{ii};
    vtc_temp=BVQXfile(vtc);
    vtc_temp.NameOfLinkedPRT = prt;
    vtc_temp.Save;
    disp([prt,' linked to ',vtc]);
end
disp('Linking procedure finished!')
clear all
