function [partArr, partCell] = removeCells(GBRShape, partArr, gridDim)
% removeCells will remove cells from a partition array which do not contain
% any reefs
% also used for assigning reefs to partitions in partCell

% inputs:
% GBRShape - a structure containing the information from a shape file of
%     the GBR
% partArr – A multidimensional array containing the x and y coordinates of
%     each individual partition, and will be of dimension n by 2 by 5,
%     where n refers to the number of total partitions created, 2 refers to
%     the coordinates for x and y, and 5 is due to the 5 vertices
%     (including the first vertex twice) of each rectangle. The cell
%     indices begin at the top left corner, then move left to right and
%     then top to bottom
% gridDim - the dimensions of the original grid in the form [xDim, yDim]

% outputs:
% partArr - same as original partArr, this time with redundant cells
%     removed
% partCell - a cell array which holds the indices of each reef which is
%     inside each cell in partArr - i.e. partCell{3} = [23, 56, 89] would
%     indicate that reefs 23, 56 and 89 all exist within the 3rd grid cell
%     in partArr

% determine the number of reefs
nReefs = length(GBRShape);

% determine the number of partitions
nParts = size(partArr, 1);

% make a cell array which holds the reefs contained in each cell - if a
% cell is empty, then we can remove that partition
partCell = cell(nParts, 1);

% reefs are indexed left to right, top to bottom, need to use partDim as
% well
nCols = gridDim(2);

% loop over each reef and assign it to a partition cell
for r = 1:nReefs
    
    % determine which grid cell the centroid falls into by looping over all
    % cells
    for p = 1:nParts
        
        if inpolygon(GBRShape(r).Centroid(1), GBRShape(r).Centroid(2), squeeze(partArr(p, 1, :)), squeeze(partArr(p, 2, :)))
            break
        end
        
    end
    
    % so the current reef belongs in p, so update reefCell
    partCell{p} = [partCell{p}, r];
    
    % now check if the border of the reef makes it into any of the
    % surrounding cells as well
    maxX = max(GBRShape(r).X);
    minX = min(GBRShape(r).X);
    maxY = max(GBRShape(r).Y);
    minY = min(GBRShape(r).Y);
    
    % determine the length of the border
    borderLength = length(GBRShape(r).X);
    
    % check if any of these fall outside the current partition, also use
    % check diagonals only in the x sections just for simplicity
    if maxX > partArr(p, 1, 3)
        
        % check if border is in the top right diagonal
        if maxY > partArr(p, 2, 2)
            
            for i = 1:borderLength
                if inpolygon(GBRShape(r).X(i), GBRShape(r).Y(i), squeeze(partArr(p+1-nCols, 1, :)), squeeze(partArr(p+1-nCols, 2, :)))
                    partCell{p+1-nCols} = [partCell{p+1-nCols}, r];
                    break
                end
            end
            
        end
        
        % check if border is in the bottom right diagonal
        if minY < partArr(p, 2, 1)
            
            for i = 1:borderLength
                if inpolygon(GBRShape(r).X(i), GBRShape(r).Y(i), squeeze(partArr(p+1+nCols, 1, :)), squeeze(partArr(p+1+nCols, 2, :)))
                    partCell{p+1+nCols} = [partCell{p+1+nCols}, r];
                    break
                end
            end
            
        end
        
        % check if the border is contained in the cell to the right
        for i = 1:borderLength
            if inpolygon(GBRShape(r).X(i), GBRShape(r).Y(i), squeeze(partArr(p+1, 1, :)), squeeze(partArr(p+1, 2, :)))
                partCell{p+1} = [partCell{p+1}, r];
                break
            end
        end
        
    end
    
    if minX < partArr(p, 1, 1)
        
        % check if border is in the top left diagonal
        if maxY > partArr(p, 2, 2)
            
            for i = 1:borderLength
                if inpolygon(GBRShape(r).X(i), GBRShape(r).Y(i), squeeze(partArr(p-1-nCols, 1, :)), squeeze(partArr(p-1-nCols, 2, :)))
                    partCell{p-1-nCols} = [partCell{p-1-nCols}, r];
                    break
                end
            end
            
        end
        
        % check if border is in the bottom left diagonal
        if minY < partArr(p, 2, 1)
            
            for i = 1:borderLength
                if inpolygon(GBRShape(r).X(i), GBRShape(r).Y(i), squeeze(partArr(p-1+nCols, 1, :)), squeeze(partArr(p-1+nCols, 2, :)))
                    partCell{p-1+nCols} = [partCell{p-1+nCols}, r];
                    break
                end
            end
            
        end
        
        % check if the border is contained in the cell to the left
        for i = 1:borderLength
            if inpolygon(GBRShape(r).X(i), GBRShape(r).Y(i), squeeze(partArr(p-1, 1, :)), squeeze(partArr(p-1, 2, :)))
                partCell{p-1} = [partCell{p-1}, r];
                break
            end
        end
        
    end
    
    if maxY > partArr(p, 2, 2)
        
        % check if the border is contained in the cell above
        for i = 1:borderLength
            if inpolygon(GBRShape(r).X(i), GBRShape(r).Y(i), squeeze(partArr(p-nCols, 1, :)), squeeze(partArr(p-nCols, 2, :)))
                partCell{p-nCols} = [partCell{p-nCols}, r];
                break
            end
        end
        
    end
    
    if minY < partArr(p, 2, 1)
        
        % check if the border is contained in the cell below
        for i = 1:borderLength
            if inpolygon(GBRShape(r).X(i), GBRShape(r).Y(i), squeeze(partArr(p+nCols, 1, :)), squeeze(partArr(p+nCols, 2, :)))
                partCell{p+nCols} = [partCell{p+nCols}, r];
                break
            end
        end
        
    end
    
end

% once all reefs have been assigned, let's remove any cells which have no
% reefs inside them
nonemptyParts = zeros(nParts, 1);
for p = 1:nParts
    if ~isempty(partCell{p})
        nonemptyParts(p) = 1;
    end
end

% now remove any empty partitions
partArr1 = [];
for p = 1:nParts
    if nonemptyParts(p) == 1
        partArr1 = cat(1, partArr1, partArr(p, :, :));
    end
end

% we also need to remove empty cells
partCell(~nonemptyParts) = [];

partArr = partArr1;

end