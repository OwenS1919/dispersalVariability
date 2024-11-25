function curvedLine = createCurvedLine(points, bendProp, res, method)
% createCurvedLine() will create a curved line between two points

% inputs:

% points - a 2 x 2 matrix with the points to join by a curved line, where
    % points = [x1, y1; x2, y2]
% bendProp - optional - the proportion of the total distance between the
    % two points to bend to - default is 0.05
% res - optional - the resolution, or number of points to use to plot the
    % curved line - default is 50
% method - optional - the interpolation method to use - default is "cubic"

% outputs:

% curvedLine - the points making up the curved line, with dimension res x
    % 2

% set defaults
if nargin < 2 || isempty(bendProp)
    bendProp = 0.05;
end
if nargin < 3 || isempty(res)
    res = 51;
end
if nargin < 4 || isempty(method)
    method = "cubic";
end

% turn warnings off because matlab is annoying me
warning("off", "all")

% calculate the midpoint and distance between the points
midPoint = points(1, :) / 2 + points(2, :) / 2;
distBetw = sqrt((points(1, 1) - points(2, 1))^2 + (points(1, 2) ...
    - points(2, 2))^2);

% calculate the angle between the points
angleBetw = atan((points(1, 2) - points(2, 2)) ...
    / (points(1, 1) - points(2, 1)));

% centre and rotate the points because apparently I'm insane
rotMat = [cos(-angleBetw), -sin(-angleBetw); sin(-angleBetw), ...
    cos(-angleBetw)];
points = (rotMat * (points - midPoint)')';

% create a vector perpendicular to the line between the points, of the
% desired width, with a switch in direction of the bend based on the
% ordering of the points, so that bi-directional connections can be visible
if points(1, 1) < points(2, 1)
    bendPoint = distBetw * bendProp * [cos(pi / 2), sin(pi / 2)];
else
    bendPoint = distBetw * bendProp * [cos(-pi / 2), sin(-pi / 2)];
end

% interpolate between the two points, along with the bendPoint
res = 50;
curvedLine = zeros(res, 2);
curvedLine(:, 1) = linspace(points(1, 1), points(2, 1), res);
curvedLine(:, 2) = interp1([points(1, 1), bendPoint(1), ...
    points(2, 1)], [points(1, 2), bendPoint(2), points(2, 2)], ...
    curvedLine(:, 1), "cubic");

% rotate and un-centre things lmao
curvedLine = (rotMat' * curvedLine')' + midPoint;

% turn warnings back on
warning("on", "all")

end