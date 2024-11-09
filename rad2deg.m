function deg = rad2deg(rad)

if ~nargin||nargin>1
    error('Please stop mucking about. This is a very simple function to use.')
end

deg = rad*180/pi;
