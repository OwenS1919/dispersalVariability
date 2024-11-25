function [searchCell, partArr, border] = constructSearchCell(shapeStruct, ...
    gridDim)
% constructSearchCell() will construct a searchCell object which can be
% used for efficient searching of shape files, for points lying inside
% shapes

% i.e. if you have a large number of points and a number of polygon
% outlines, this code is perfect for creating a structure which will help
% determine which points they are in / near

% note that this code will probably take quite a long time to run xd, but
% will be worth it in the end as the speed increase is extremely useful

% this function requires the following child functions, which clearly must
% be in the same folder for the method to work as intended:
% gridPartRectangle(), removeCells(), createSearchCell(),
% createSearchCellLevel()

% inputs:

% shapeStruct - a structure array full of the polygons, each of which has
    % an X, Y and Centroid field
% gridDim - optional - the dimensions of the grid used for searching, in
    % the form [xDim, yDim] - default is [100, 100]

% outputs:

% searchCell - a cell array which is used to speed up the searching process
    % it follows the following structure - each level has 4 entries -
    % searchCell{3} tells you the current split direction (i.e. "x" or "y")
    % and then searchCell{4} tells you the split value i.e. is pointX >=
    % splitVal - if the point in question has an x or y value above this
    % splitVal, the search continues down searchCell{1} which simply moves
    % down another level, or alternatively searchCell{2} if pointX <
    % splitVal searchCell{3} could also have the values "empty" or
    % "partition", which means that the point does not lie within any reef,
    % or lies within one of the reefs listed in searchCell{4} respectively
    % the only exception is the top layer, which also has the entries
    % searchCell{5} and {6}, which hold the ranges for x and y values
    % covered in the search area respectively, and should a point lie
    % outside these values it does not lie within a reef
% partArr - a partition array, which contains the coordinates of a number
    % of rectangular blocks used for speeding up searches, in the form n x
    % 2 x 5, where the n refers to the number of blocks present, the 2
    % corresponds to the x and y coordinates, and the 5 corresponds to the
    % points of rectangle, with the origin (bottom left hand corner) twice
% border - a 5 x 2 array holding the coordinates of the border around the
    % area covered by the searchCell, with the origin twice

% set a default for gridDim
if nargin < 2 || isempty(gridDim)
    gridDim = [100, 100];
end

% figure out the minimum and maximum values in each dimension
xMax = -inf;
xMin = inf;
yMax = -inf;
yMin = inf;

% loop over each shape, and update the above where necessary
for s = 1:length(shapeStruct)

    % extract the maximum and minimum values from the current set of
    % coordinates
    xMinCurr = min(shapeStruct(s).X);
    xMaxCurr = max(shapeStruct(s).X);
    yMinCurr = min(shapeStruct(s).Y);
    yMaxCurr = max(shapeStruct(s).Y);

    % update where necessary
    if xMinCurr < xMin
        xMin = xMinCurr;
    end
    if xMaxCurr > xMax
        xMax = xMaxCurr;
    end
    if yMinCurr < yMin
        yMin = yMinCurr;
    end
    if yMaxCurr > yMax
        yMax = yMaxCurr;
    end
    
end

% form the border by adding and subtracting small values proportional to
% the range, so that none of the shapes are perfectly on the border
xAdd = 0.01 * (xMax - xMin);
yAdd = 0.01 * (yMax - yMin);
xMax = xMax + xAdd;
xMin = xMin - xAdd;
yMax = yMax + yAdd;
yMin = yMin - yAdd;
border = [xMin, yMin; xMax, yMin; xMax, yMax; xMin, yMax; xMin, yMin];

% create the original grid
partArr = gridPartRectangle(border, gridDim);

% this code removes any grid cells which do not contain any shapes, and are
% hence unnecessary
[partArr, partCell] = removeCells(shapeStruct, partArr, gridDim);

% we now need to set up what I call a searchCell, which is used in the
% searching algorithm
searchCell = createSearchCell(partArr, partCell, [border(1, 1), ...
    border(2, 1)], [border(1, 2), border(3, 2)], 120, 120);

end
