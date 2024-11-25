function searchCellBranch = createSearchCellLevel(partArr, partCell, ...
    prevDir, prevXBounds, prevYBounds, prevXDim, prevYDim)
% createSearchCellLevel will create a level in the searchCell used for
% optimising searching processes - the search cell itself will be a
% recursive cell array, and as such this function itself will be recursive
% function - the returned searchCellBranch will hold a filled out level of
% the search cell, which will also store any further children/branch levels
% below

% inputs:

% GRBShape - a structure taken from a shape file, where each element is a
    % separate reef and contains the border coordinates in the fields X and
    % Y
% partArr - a partition array, which contains the coordinates of a number
    % of rectangular blocks used for speeding up searches, in the form n x
    % 2 x 5, where the n refers to the number of blocks present, the 2
    % corresponds to the x and y coordinates, and the 5 corresponds to the
    % points of rectangle, with the origin (bottom left hand corner) twice
% partCell - a cell array, where each cell contains the indices of the
    % reefs contained in the corresponding partition in an array (same
    % order as partArr)
% prevXBounds - before the check at the current level has occured, what
    % area have we narrowed down our point to, in the form [minX, maxX]
% currYBounds - same as x above
% prevXDim - the previous dimensions of the partition array (before any
    % partitions were removed, i.e. dimensions at initialisation)
% prevYDim - as above but for y

% output:

% searchCellBranch - as described in the function description, the current
    % level of the searchCell and all its completed children/branches

% first, determine the current split direction - may need to switch if
% either only has 1 dimension left
if prevDir == "x"
    if prevYDim > 1
        currDir = "y";
    else
        currDir = "x";
    end
else
    if prevXDim > 1
        currDir = "x";
    else
        currDir = "y";
    end
end

% update the current direction
searchCellBranch = cell(1, 4);
searchCellBranch{3} = currDir;

% figure out and store the current split
if currDir == "x"
    currSplit = prevXBounds(1) + ((prevXBounds(2) - prevXBounds(1)) ...
        * (floor(prevXDim / 2) / prevXDim));
    nextDims = [prevXDim - floor(prevXDim / 2), floor(prevXDim / 2)];
else
    currSplit = prevYBounds(1) + ((prevYBounds(2) - prevYBounds(1)) ...
        * (floor(prevYDim / 2) / prevYDim));
    nextDims = [prevYDim - floor(prevYDim / 2), floor(prevYDim / 2)];
end
searchCellBranch{4} = currSplit;

% check if the next levels will actually have stuff - keep a track of how
% many partitions are found and search all, stop if 2 are found
% also keep track each time a partition is found, to make life easier when
% only one is found
partitionsFound1 = 0;
partitionsFound2 = 0;
partFound1 = 0;
partFound2 = 0;

% use some if statements here I think that might help, and maybe just
% calculate the next step's dimensions as a variable that may also help
for p = 1:size(partArr, 1)

    % record the bottom corner, then check where it fits into the next
    % split
    [centX, centY] = centroid(polyshape(squeeze(partArr(p, 1, :)), ...
        squeeze(partArr(p, 2, :))));

    % the if statements here vary between > and >=, but now that I'm using
    % centroids it really shouldn't matter 
    if centX >= prevXBounds(1) && centX < prevXBounds(2) ...
            && centY >= prevYBounds(1) && centY < prevYBounds(2)

        % in this case, the partition is inside the current search area, we
        % just need to check which side of the split it is in, and update
        % our counters
        if currDir == "x"
            if centX >= currSplit
                partitionsFound1 = partitionsFound1 + 1;
                partFound1 = p;
            else
                partitionsFound2 = partitionsFound2 + 1;
                partFound2 = p;
            end
        else
            if centY >= currSplit
                partitionsFound1 = partitionsFound1 + 1;
                partFound1 = p;
            else
                partitionsFound2 = partitionsFound2 + 1;
                partFound2 = p;
            end
        end

    end

    % cut off the loop early if both counts reach 2
    if partitionsFound1 > 1 && partitionsFound2 > 1
        break
    end

end

% check if the first count was below 2
if partitionsFound1 == 0

    % then we need to set up the next level to be an empty level
    searchCellBranch{1} = cell(1, 4);
    searchCellBranch{1}{1} = 0;
    searchCellBranch{1}{2} = 0;
    searchCellBranch{1}{3} = "empty";
    searchCellBranch{1}{4} = 0;

elseif partitionsFound1 == 1

    % set up the next level as a partition search
    searchCellBranch{1} = cell(1, 4);
    searchCellBranch{1}{1} = 0;
    searchCellBranch{1}{2} = 0;
    searchCellBranch{1}{3} = "partition";
    searchCellBranch{1}{4} = partCell{partFound1};

end

% same for the second region
if partitionsFound2 == 0

    % set up the next level to be an empty level
    searchCellBranch{2} = cell(1, 4);
    searchCellBranch{2}{1} = 0;
    searchCellBranch{2}{2} = 0;
    searchCellBranch{2}{3} = "empty";
    searchCellBranch{2}{4} = 0;

elseif partitionsFound2 == 1

    % set up the next level as a partition search
    searchCellBranch{2} = cell(1, 4);
    searchCellBranch{2}{1} = 0;
    searchCellBranch{2}{2} = 0;
    searchCellBranch{2}{3} = "partition";
    searchCellBranch{2}{4} = partCell{partFound2};

end

% recursively call this function, using isempty checks in case either
% direction was previously setup (i.e. was empty or had only 1 partition)
if currDir == "x"
    if isempty(searchCellBranch{1})
        searchCellBranch{1} = createSearchCellLevel(partArr, partCell, ...
            currDir, [currSplit, prevXBounds(2)], prevYBounds, ...
            nextDims(1), prevYDim);
    end
    if isempty(searchCellBranch{2})
        searchCellBranch{2} = createSearchCellLevel(partArr, partCell, ...
            currDir, [prevXBounds(1), currSplit], prevYBounds, ...
            nextDims(2), prevYDim);
    end
else
    if isempty(searchCellBranch{1})
        searchCellBranch{1} = createSearchCellLevel(partArr, partCell, ...
            currDir, prevXBounds, [currSplit, prevYBounds(2)], prevXDim, ...
            nextDims(1));
    end
    if isempty(searchCellBranch{2})
        searchCellBranch{2} = createSearchCellLevel(partArr, partCell, ...
            currDir, prevXBounds, [prevYBounds(1), currSplit], prevXDim, ...
            nextDims(2));
    end
end

end
