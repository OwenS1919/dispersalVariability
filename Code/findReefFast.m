function reefInd = findReefFast(point, GBRShape, searchCell, overlap, ...
    GBRShape2, nearest, partArr)
% findReefFast will take a point stored in point, and determine if it lies
% within a reef, and if so what the index of that reef is

% inputs:

% point - the point in question in the form [x, y]
% GBRShape - a structure taken from a shape file, where each element is a
    % separate reef and contains the border coordinates in the fields X and
    % Y partArr - a partition array, which contains the coordinates of a
    % number of rectangular blocks used for speeding up searches, in the
    % form n x 2 x 5, where the n refers to the number of blocks present,
    % the 2 corresponds to the x and y coordinates, and the 5 corresponds
    % to the points of rectangle, with the origin (bottom left hand corner)
    % twice
% searchCell - a cell array which is used to speed up the searching process
    % and can be created using the createSearchCell() function
% overlap - optional -  specify as "overlap" if the GBRShape is the
    % enlarged by 1km version, so algorithm can test if point exists inside
    % multiple reef outlines
% GBRShape2 - optional - if "overlap" is specified, then GBRShape should be
    % the enlarged shape, and GBRShape2 should be the original shapefile -
    % this way if there is an overlap, the original, unenlarged shape file
    % can be used to determine which reef the point is closer to
% nearest - optional - if specified as "nearest" then rather than returing
    % a 0 if the point does not lie within a reef, it will instead return
    % the index of the closest reef
% partArr - a partition array, which contains the coordinates of a number
    % of rectangular blocks used for speeding up searches, in the form n x
    % 2 x 5, where the n refers to the number of blocks present, the 2
    % corresponds to the x and y coordinates, and the 5 corresponds to the
    % points of rectangle, with the origin (bottom left hand corner) twice

% output:

% reefInd - the index for the reef which the point lies in, or 0 otherwise

% first set the reefInd as 0 just as a default
reefInd = 0;

% set defaults for each optional variable starting with overlap
if nargin < 4 || isempty(overlap) || overlap ~= "overlap"
    overlap = false;
else
    overlap = true;
end

% set default for nearest
if nargin < 6 || isempty(nearest) || nearest ~= "nearest"
    nearest = false;
else
    nearest = true;
end

% first check that the point is inside the search area - if it is not,
% then we should just return
if point(1) < searchCell{5}(1) || point(1) > searchCell{5}(2) ...
        || point(2) < searchCell{6}(1) || point(2) > searchCell{6}(2)
    return
end


% split cases based on whether or not overlaps are possible
if ~overlap

    % now start the regular searching where there is no overlap- we can use
    % a while loop here - also split based on whether we are testing or
    % not, so that we don't have a bunch of irrelevent if statements
    % otherwise
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

            % if we're not finished, update the currCell as the next level
            % down
            currCell = currCell{nextInd};

        end

    end

    % check if we got "empty" or "partition"
    if currCell{nextInd}{3} == "empty"

        % if our point does not lay inside any partitions exit method
        return

    else

        % otherwise search the reefs inside the partition
        reefIndices = currCell{nextInd}{4};
        for r = 1:length(reefIndices)

            if inpolygon(point(1), point(2), GBRShape(reefIndices(r)).X, ...
                    GBRShape(reefIndices(r)).Y)
                reefInd = reefIndices(r);
                break
            end
        end

    end

    % now if we reach here and reefInd remains as 0, check if nearest is
    % true, and if so instead find the nearest reef
    if reefInd == 0
        if nearest

            % first, check whether the point is inside or outside a
            % partition
            if currCell{nextInd}{3} == "empty"

                % in this case, the point is outside all partitions, so
                % determine the 3 partitions to which the point is closest
                % to - do this using the pairwise distance to the centroids
                % of each of the centroids of the partitions
                nParts = size(partArr, 1);
                partitionCentroids = zeros(nParts, 2);
                for p = 1:nParts
                    partitionCentroids(p, 1) = squeeze((partArr(p, 1, 1) ...
                        + partArr(p, 1, 3)) / 2);
                    partitionCentroids(p, 2) = squeeze((partArr(p, 2, 1) ...
                        + partArr(p, 2, 3)) / 2);
                end
                pdistParts = pdist2(partitionCentroids, point);
                [~, closest] = maxk(pdistParts, 3);

                % why is the above a max call??

                % gather the indices of all the reefs in these 3 closest
                % partitions
                reefIndices = [partArr(closest(1)), partArr(closest(2)), ...
                    partArr(closest(3))];

                % now find the 5 closest reefs by centroid (if 5 can be
                % found)
                reefCentroids = zeros(length(reefIndices), 2);
                for r = 1:length(reefIndices)
                    reefCentroids(r) = GBRShape(reefIndices(r)).Centroid;
                end
                pdistReefs = pdist2(reefCentroids, point);
                k = min(5, length(reefIndices));
                [~, closest] = maxk(pdistReefs, k);
                closest = reefIndices(closest);

                % now loop through these 5 (or less) reefs and determine
                % the closest by boundary
                minDist = realmax;
                minInd = 1;
                for r = closest

                    % find the pairwise distance between the point and all
                    % boundary points of the reef
                    pdistBoundary = pdist2(horzcat(GBRShape(r).X', ...
                        GBRShape(r).Y'), point);
                    if min(pdistBoundary) < minDist
                        minDist = min(pdistBoundary);
                        minInd = r;
                    end
                end

                % now seet the output to minInd
                reefInd = minInd;

            else

                % otherwise, the point exists inside a partition
                % what would be best, is for us to check all the reefs in
                % surrounding partitions too, but for the use of this
                % method currently that is relatively unnecessary (i.e.
                % assigning initial positions)
                % instead we will just find the closest reef contained in
                % the current partition

                % otherwise search the reefs inside the partition, and find
                % the closest 5 by centroid
                reefIndices = currCell{nextInd}{4};
                reefCentroids = zeros(length(reefIndices), 2);
                for r = 1:length(reefIndices)
                    reefCentroids(r, :) = GBRShape(reefIndices(r)).Centroid;
                end
                pdistReefs = pdist2(reefCentroids, point);
                k = min(length(reefIndices), 5);
                [~, closest] = mink(pdistReefs, k);

                % now loop through these closest reefs and determine the
                % reef who is closest by boundary
                closest = reefIndices(closest);
                minInd = 1;
                minDist = realmax;
                for r = closest

                    % calculate the pairwise distances between all border
                    % points and the point in questions
                    pdistBoundary = pdist2(horzcat(GBRShape(r).X', ...
                        GBRShape(r).Y'), point);

                    if min(pdistBoundary) < minDist
                        minDist = min(pdistBoundary);
                        minInd = r;
                    end
                end

                % now update reefInd and leave method
                reefInd = minInd;

            end
        end
    end

else

    % otherwise, if we reach here, we are searching with an overlap
    % the process is almost identical, the only difference being that we
    % check all reefs in a partition and store multiple reefs if the point
    % exists in both, and then choose the closer reef by boundary
    % now start the regular searching where there is no overlap- we can use
    % a while loop here - also split based on whether we are testing or
    % not, so that we don't have a bunch of irrelevent if statements
    % otherwise
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

            % if we're not finished, update the currCell as the next level
            % down
            currCell = currCell{nextInd};

        end

    end

    % check if we got "empty" or "partition"
    if currCell{nextInd}{3} == "empty"

        % if our point does not lay inside any partitions set reefInd to an
        % empty array and search for the closest later if necessary
        reefInd = [];

    else

        % otherwise search the reefs inside the partition allowing for
        % overlap
        reefIndices = currCell{nextInd}{4};
        reefInd = [];
        for r = reefIndices

            if inpolygon(point(1), point(2), GBRShape(r).X, GBRShape(r).Y)
                reefInd = [reefInd, r];
            end
        end

    end

    % check the status of reefInd - if it not empty find the closest reef
    % inside reefInd, otherwise instead find the closest reef if nearest is
    % true
    if ~isempty(reefInd)

        % check the size of reefInd - if it is just 1, then we have found
        % the reef already and can simply exit the method, otherwise we
        % need to find the closest out of those listed
        if length(reefInd) > 1

            % loop through the reefs and find the closest by the unenlarged
            % boundary
            minDist = realmax;
            minInd = 1;
            for r = reefInd

                % calculate the pdist from point to all boundary points
                pdistBoundary = pdist2(horzcat(GBRShape2(r).X', ...
                    GBRShape2(r).Y'), point);
                if min(pdistBoundary) < minDist
                    minDist = min(pdistBoundary);
                    minInd = r;
                end

            end

            % set reefInd to the closest reef
            reefInd = minInd;

        end
        
    else 

        % otherwise, reefInd is empty - set to 0 and then find the closest
        % reef if nearest is true
        reefInd = 0;

        if nearest

            % first, check whether the point is inside or outside a
            % partition
            if currCell{nextInd}{3} == "empty"

                % in this case, the point is outside all partitions, so
                % determine the 3 partitions to which the point is closest
                % to - do this using the pairwise distance to the centroids
                % of each of the centroids of the partitions
                nParts = size(partArr, 1);
                partitionCentroids = zeros(nParts, 2);
                for p = 1:nParts
                    partitionCentroids(p, 1) = squeeze((partArr(p, 1, 1) ...
                        + partArr(p, 1, 3)) / 2);
                    partitionCentroids(p, 2) = squeeze((partArr(p, 2, 1) ...
                        + partArr(p, 2, 3)) / 2);
                end
                pdistParts = pdist2(partitionCentroids, point);
                [~, closest] = maxk(pdistParts, 3);

                % gather the indices of all the reefs in these 3 closest
                % partitions
                reefIndices = [partArr(closest(1)), partArr(closest(2)), ...
                    partArr(closest(3))];

                % now find the 5 closest reefs by centroid (if 5 can be
                % found)
                reefCentroids = zeros(length(reefIndices), 2);
                for r = 1:length(reefIndices)
                    reefCentroids(r) = GBRShape(reefIndices(r)).Centroid;
                end
                pdistReefs = pdist2(reefCentroids, point);
                k = min(5, length(reefIndices));
                [~, closest] = maxk(pdistReefs, k);
                closest = reefIndices(closest);

                % now loop through these 5 (or less) reefs and determine
                % the closest by boundary
                minDist = realmax;
                minInd = 1;
                for r = closest

                    % find the pairwise distance between the point and all
                    % boundary points of the reef
                    pdistBoundary = pdist2(horzcat(GBRShape(r).X', ...
                        GBRShape(r).Y'), point);
                    if min(pdistBoundary) < minDist
                        minDist = min(pdistBoundary);
                        minInd = r;
                    end
                end

                % now seet the output to minInd
                reefInd = minInd;

            else

                % otherwise, the point exists inside a partition
                % what would be best, is for us to check all the reefs in
                % surrounding partitions too, but for the use of this
                % method currently that is relatively unnecessary (i.e.
                % assigning initial positions)
                % instead we will just find the closest reef contained in
                % the current partition

                % search the reefs inside the partition, and find
                % the closest 5 by centroid
                reefIndices = currCell{nextInd}{4};
                reefCentroids = zeros(length(reefIndices), 2);
                for r = 1:length(reefIndices)
                    reefCentroids(r, :) = GBRShape(reefIndices(r)).Centroid;
                end
                pdistReefs = pdist2(reefCentroids, point);
                k = min(length(reefIndices), 5);
                [~, closest] = mink(pdistReefs, k);

                % now loop through these closest reefs and determine the
                % reef who is closest by boundary
                closest = reefIndices(closest);
                minInd = 1;
                minDist = realmax;
                for r = closest

                    % calculate the pairwise distances between all border
                    % points and the point in questions
                    pdistBoundary = pdist2(horzcat(GBRShape(r).X', ...
                        GBRShape(r).Y'), point);

                    if min(pdistBoundary) < minDist
                        minDist = min(pdistBoundary);
                        minInd = r;
                    end
                end

                % now update reefInd and leave method
                reefInd = minInd;

            end
        end
    end
end

end
