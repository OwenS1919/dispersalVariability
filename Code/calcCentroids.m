function GBRShape = calcCentroids(GBRShape)
% calcCentroids will calculate the centroids of each reef and then store
% them in a new field "Centroid" in the form [xc, yc];

% input:
% GBRShape - a structure created from a shape file, with its outline stored
% in the fields X and Y

% output:
% GBRShape - same as the input, however now with the Centroid field which
% holds the centroid of each reef in the form [xc, yc]

% determine the number of reefs
nReefs = length(GBRShape);

% add the new field
GBRShape(1).Centroid = [];

warning('off','all')

% now loop over each reef, calculate the centroid and store it
for r = 1:nReefs
    [xc, yc] = centroid(polyshape(GBRShape(r).X, GBRShape(r).Y));
    GBRShape(r).Centroid = [xc, yc];
end

warning('on', 'all')

end
