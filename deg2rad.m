function rad = deg2rad(deg);

if ~nargin||nargin>1
    error('Please stop mucking about. This is a very simple function to use.')
end

rad = deg/360*2*pi;
