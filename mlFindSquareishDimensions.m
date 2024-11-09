function [x,y] = mlFindSquareishDimensions(n)

% Usage: [x,y] = mlFindSquareishDimensions(n)
% 
% Returns (nearly) sqrt dimensions for a given number. e.g. for 23, will
% return [5,5] and for 26 it will return [6,5]. For creating displays of
% sets of images, mostly. Always sets x greater than y if they are not
% equal.
% 
% Created by ML 2009.07.??

sq = sqrt(n);

if round(sq)==sq; % if this is a whole number - i.e. a perfect square
    x = sq;
    y = sq;
    return
end


% One: next larger square
x(1) = ceil(sq);
y(1) = ceil(sq);
opt(1) = x(1)*y(1);

% Two: immediately surrounding numbers
x(2) = ceil(sq);
y(2) = floor(sq);
opt(2) = x(2)*y(2);

% Three: 
% ??

Test = opt-n;
Test(Test<0) = 1000; % make sure negative values will not be chosen as the minimum
GoodOption = find(Test==min(Test));

x = x(GoodOption);
y = y(GoodOption);