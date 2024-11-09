function mlWebPageBackup

MarkCode = '/Applications/Matlab74/MarkCode/';
WebPageIndex = '/Users/Work/Desktop/WebPage/index.html';
When = mlTitleDate;

cd(MarkCode);

cd ExperimentUtilities
cleanup;
cd ..

% !tar -zcf /Users/Work/Desktop/WebPage/mlUtilities.tar ExperimentUtilities/
zip('/Users/Work/Desktop/WebPage/mlUtilities','ExperimentUtilities/');

fid = fopen(WebPageIndex,'r');
count = 1;
while(1)
    WebPage{count} = fgetl(fid);
    if ~ischar(WebPage{count}), break, end
    count = count+1;
end
fclose(fid);

for ii = 1:length(WebPage); 
    aa = findstr('Updated',WebPage{ii}); 
    if ~isempty(aa); 
        WebPage{ii} = [WebPage{ii}(1:aa+6) ' ' When ')'];
    end; 
end

fid2 = fopen(WebPageIndex,'w');
fprintf(fid2,'%s\n',WebPage{:});

fclose(fid2);

cd MLDemos
cleanup;
cd ..
% !tar -zcf /Users/Work/Desktop/WebPage/MLDemos.tar MLDemos/
zip('/Users/Work/Desktop/WebPage/MLDemos','MLDemos/');

disp('Update Complete.');