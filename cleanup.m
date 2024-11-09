function cleanup

%
% function CLEANUP.m
%
% gets rid of temporary current directory (i.e., files ending in ~ - as of
% 7.27.07, it removes .txt~, .m~, and .c~)
% 
% It also recycles any DebugVars.mat files (or variants on that) (this is
% an ML convention)
% 
% New 7.27.07: recycles extra motion-correction files created by ML's BV
% automation. 
%
% Created ?? by ML; updated 7.27.07 by ML

delete *.txt~
delete *.m~
delete *.c~
delete *.cpp~

RecycleState = recycle;

recycle on;

delete *GuineaPig*.mat
delete *ebugVars*.mat


recycle(RecycleState);