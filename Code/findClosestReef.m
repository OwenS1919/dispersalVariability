function reefInd = findClosestReef(x, y, GBRShape, indices)
% findClosestReef will find the closest reef to a point out of a given list
% of reefs stored in indices, by finding the minimum distance to each
% reef's border and comparing them

% inputs:
% x - x position of point in question
% y - y position of point in question
% GBRShape - a structure containing the borders of each reef, with the
% fields X and Y representing the x and y coordinates of the reef's border
% respectively
% indices - the indices of the specific reefs to check

% output:
% reefInd - the index of the reef (relative to the GBRShape struct)

% loop through each of the indices, and find the shortest distance to the
% reef's border
minDist = realmax;
reefInd = 1;
for i = 1:length(indices)

    % find distances from each border point to the point in question
    pdistArray = pdist2([x, y], horzcat(GBRShape(indices(i)).X', GBRShape(indices(i)).Y'));

    % if the minimum distance in pdistArray is below the current global
    % minimum, update the global minimum and distance
    if min(pdistArray) < minDist
        minDist = min(pDistArray);
        reefInd = indices(i);
    end
end

end