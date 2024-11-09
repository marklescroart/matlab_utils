function[] = LinkPRT2VTC_doit(vtclistfile,prtlistfile)

try
% Read VTC list -> vtclist
vtclist = importdata(vtclistfile,'\n');
n=str2num(vtclist{1});
disp([num2str(n),' pairs have to be linked']);

% Read PRT list -> prtlist
prtlist = importdata(prtlistfile,'\n');

%Link files
for ii = 2:n
    vtc=vtclist{ii};
    prt=prtlist{ii};
    vtc_temp=BVQXfile(vtc)
    vtc_temp.NameOfLinkedPRT = prt
    vtc_temp.Save
    disp([prt,' linked to ',vtc]);
end
disp('Linking procedure terminated!')
clear all
catch
    save DebugVars
    rethrow(lasterror)
end