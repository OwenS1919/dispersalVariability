function [partArr, cellArea] = gridPartRectangle(border, gridDim)
% gridPartRectangle will partition an area represented by border into
% dimensions specified by gridDim

% inputs:
% border – A matrix consisting of two column vectors in the form [xp’, yp’]
%     which are the respective x and y coordinates of the rectangular
%     domain – this will include the origin twice, and does not need to be
%     in any specific order
% gridDim – A vector of the dimensions of the grid to be created, in the
%     form [m, n] to create an m (rows) by n (columns) grid

% outputs:
% partArr – A multidimensional array containing the x and y coordinates of
%     each individual partition, and will be of dimension n by 2 by 5,
%     where n refers to the number of total partitions created, 2 refers to
%     the coordinates for x and y, and 5 is due to the 5 vertices
%     (including the first vertex twice) of each rectangle. The cell
%     indices begin at the top left corner, then move left to right and
%     then top to bottom 
% cellArea - the area of each partitioned cell

% initialise the partArr
m = gridDim(1);
n = gridDim(2);
totCells = m * n;
partArr = zeros(totCells, 2, 5);

% create a vector of all the possible x and y values, using the border matrix as
% a guide
xVals = linspace(min(border(:, 1)), max(border(:, 1)), n + 1);
yVals = linspace(max(border(:, 2)), min(border(:, 2)), m + 1);

% fill in the x values corresponding to the first row, and then copy them
% into each consecutive row
for i = 1:n
    partArr(i, 1, [1 2 5]) = xVals(i);
    partArr(i, 1, [3 4]) = xVals(i + 1);
end

% copy the above set of x values into each consecutive row
for r = 2:m
    partArr(((r-1)*n + 1):(r*n), 1, :) = partArr(1:n, 1, :);
end

% fill in the y values corresponding to the first column, and then copy
% them into each consecutive column
for i = 1:m
    partArr((i-1)*n + 1, 2, [2 3]) = yVals(i);
    partArr((i-1)*n + 1, 2, [1 4 5]) = yVals(i + 1);
end

% create a vector of the indices in partArr that the first column is
% contained in, in order to more easily access it in the following loop:
indVec = 1:m;
indVec = (indVec-1).*n + 1;

% copy the above set of y values to the following columns
for c = 2:n
    partArr((indVec + c - 1), 2, :) = partArr(indVec, 2, :);
end

% also return the area of each grid cell
cellArea = polyarea(border(:, 1), border(:, 2)) / totCells;

end

