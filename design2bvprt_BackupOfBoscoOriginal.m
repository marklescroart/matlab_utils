function design2bvprt(design_in, design_out)
%function design2bvprt(design_in, prt_out)
% make protocol file from a 'design' file

% parameters for this experiments:
event = {'fixation', 'left', 'right'}; % for event labels 1, 2, 3, ...
color = {[195 195 195], [75 255 165], [40 150 255]};
TRperTrial = 2;
Pre_event_idx = 1; % 'Baseline/fixation' event before the actual experiment; indexed into event
Pre_event_nTR = 0; % count after the skipped volumes
Post_event_idx = 1;
Post_event_nTR = 12;

%% Don't touch anything below this line!!
if exist('design_out', 'var')
   fout = fopen(design_out,'w');
else
   fout = 1;
end

design = load(design_in);
design = design(:);
ncond = length(event);
if min(design) ~=1 | max(design) ~= ncond
   error('Event numbering in the design file is inconsist with event specification in this .m file');
end

fprintf(fout, '\n');
fprintf(fout, 'FileVersion:        2\n');
fprintf(fout, '\n');
fprintf(fout, 'ResolutionOfTime:   Volumes\n');
fprintf(fout, '\n');
fprintf(fout, 'Experiment:         %s\n',design_in);
fprintf(fout, '\n');
fprintf(fout, 'BackgroundColor:    0 0 0\n');
fprintf(fout, 'TextColor:          255 255 255\n');
fprintf(fout, 'TimeCourseColor:    255 255 255\n');
fprintf(fout, 'TimeCourseThick:    3\n');
fprintf(fout, 'ReferenceFuncColor: 0 0 80\n');
fprintf(fout, 'ReferenceFuncThick: 3\n');
fprintf(fout, '\n');
fprintf(fout, 'NrOfConditions:  %d\n',ncond);
fprintf(fout, '\n');

for i=1:ncond
   j = find(design == i);
   fprintf(fout,'%s\n',event{i});
   n = length(j);
   if Pre_event_idx == i & Pre_event_nTR > 0;
      n = n+1;
   end
   if Post_event_idx == i & Post_event_nTR > 0;
      n = n+1;
   end
   fprintf(fout,'%d\n',n);
   if Pre_event_idx == i & Pre_event_nTR > 0;
      fprintf(fout,'%d %d\n', [1 Pre_event_nTR]);
   end
   fprintf(fout,'%d %d\n', [(j(:)'-1)*TRperTrial+1; j(:)'*TRperTrial]+Pre_event_nTR);
   if Post_event_idx == i & Post_event_nTR > 0;
      fprintf(fout,'%d %d\n', [1 Post_event_nTR]+length(design)*TRperTrial+Pre_event_nTR);
   end
   fprintf(fout,'Color: %d %d %d\n', color{i});
   fprintf(fout,'\n');
end

if fout ~= 1
   fclose(fout);
end
