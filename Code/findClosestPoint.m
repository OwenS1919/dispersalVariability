function pointInd = findClosestPoint(point, shapeStruct, searchCell, ...
    partArr)
% findClosestPoint() will take a point stored in point, and determine the
% point it lies closest too from a set defined in shapeStruct and
% searchCell

% this method is a spin off from the findReefFast() method -> the only
% difference is that once we reach the end of the search cell, we just find
% the closest point/reef via pdist rather than using inpolygon

% inputs:

% point - the point in question in the form [x, y]
% shapeStruct - a structure taken from a shape file, where each element is
    % the voronoi tesselation border  in the fields X and Y, and contains
    % the actual point in the Centriod field
% searchCell - a cell array which is used to speed up the searching process
    % and can be created using the createSearchCell() function
% partArr - a partition array, which contains the coordinates of a number
    % of rectangular blocks used for speeding up searches, in the form n x
    % 2 x 5, where the n refers to the number of blocks present, the 2
    % corresponds to the x and y coordinates, and the 5 corresponds to the
    % points of rectangle, with the origin (bottom left hand corner) twice

% output:

% pointInd - the index for the reef which the point lies in, or 0 otherwise

% first set the pointInd as 0 just as a default
pointInd = 0;

% now start the regular searching where there is no overlap- we can use
% a while loop here - also split based on whether we are testing or not, so
% that we don't have a bunch of irrelevent if statements otherwise
finished = false;
currCell = searchCell;
while ~finished

    % check if the current level is an "x" or "y" split
    if currCell{3} == "x"

        % check what the next index should be based on the split
        if point(1) >= currCell{4}
            nextInd = 1;
        else
            nextInd = 2;
        end

    else

        % check what the next index should be based on the split
        if point(2) >= currCell{4}
            nextInd = 1;
        else
            nextInd = 2;
        end

    end

    % check if we're finished, otherwise update the current cell
    if currCell{nextInd}{3} == "empty" ...
            || currCell{nextInd}{3} == "partition"
        finished = true;
    else

        % if we're not finished, update the currCell as the next level down
        currCell = currCell{nextInd};

    end

end

% check if we got "empty" or "partition"
if currCell{nextInd}{3} == "partition"

    % search the points whose voronoi borders are inside the
    % current partition
    pointIndices = currCell{nextInd}{4};

else

    % % in this case, the point is outside all partitions, so determine the 3
    % % partitions to which the point is closest to - do this using the
    % % pairwise distance to the centroids of each of the centroids of the
    % % partitions
    % nParts = size(partArr, 1);
    % partitionCentroids = zeros(nParts, 2);
    % for p = 1:nParts
    %     partitionCentroids(p, 1) = squeeze((partArr(p, 1, 1) ...
    %         + partArr(p, 1, 3)) / 2);
    %     partitionCentroids(p, 2) = squeeze((partArr(p, 2, 1) ...
    %         + partArr(p, 2, 3)) / 2);
    % end
    % pdistParts = pdist2(partitionCentroids, point);
    % [~, closest] = mink(pdistParts, 3);
    % 
    % % gather the indices of all the points in these 3 closest partitions
    % pointIndices = [partArr(closest(1)), partArr(closest(2)), ...
    %     partArr(closest(3))];

    % for some reason the above code was horrific and didn't work, no idea
    % why but I'm just gonna brute force it in this case
    pointIndices = 1:length(shapeStruct);

end

% if there is only one index in pointIndices, we can simply return this and
% leave the method
if length(pointIndices) == 1
    pointInd = pointIndices;
    return
end

% otherwise, gather the centroids which may be closest
centroidsCurr = zeros(length(pointIndices), 2);
for p = 1:length(pointIndices)
    centroidsCurr(p, :) = shapeStruct(pointIndices(p)).Centroid;
end

% calculate the pairwise distances, and return the index of the point with
% the minimum distance
[~, ind] = min(pdist2(point, centroidsCurr));
pointInd = pointIndices(ind);

end
