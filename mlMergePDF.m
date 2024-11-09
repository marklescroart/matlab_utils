function mlMergePDF(merged_file,varargin)

% Usage: mlMergePDF(merged_file_name,file1,file2,file3,...)
% 
% Merges multiple PDF files
% 
% first argument is merged output file name.
% second and third or after them are input file names.
% input file name is not cell
% Please convert cell to strings by following command.
%      aaa{:}
% Created by Takayuki 080520
% Stolen by ML 2008.08.04

% if strcmp(merged_file[end-3:end],'.pdf')
%     merged_file = [merged_file,'.pdf'];
% end

file_names = cat(2,merged_file,varargin);
num_files = length(file_names);

for m=1:num_files
    if ~strcmp(file_names{m}(end-3:end),'.pdf')
        file_names{m} = [file_names{m},'.pdf'];
    end
end

merge_command1 = '!gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=';
merge_command2 = sprintf('%s ',file_names{:});
merge_command = [merge_command1,merge_command2];


disp(' ');
disp('source PDF files');
for m=2:num_files
    disp(sprintf('     %s',file_names{m}));
end

eval(merge_command);%unix(merge_command);    % merge here ===========================

disp('Merged PDF file');
disp(sprintf('     %s',file_names{1}));

