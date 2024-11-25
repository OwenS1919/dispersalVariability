function pDist = pdistLatLon(latLong)
% pdistLatLon will function the same as the inbuild matlab function pdist,
% however instead calculating the differences based on latitude and
% longitude, using the inbuilt matlab function distance

% inputs:

% latLong - an n x 2 matrix of the latitudes and longitudes of each point,
%     with latLon(:, 1) being the longitudes, and latLon(:, 2) being the
%     latitudes

% outputs:

% pDist - a matrix holding the differences between each point in km

% determine the number of points
nPoints = length(latLong);

% initialise the storage
pDist = zeros(nPoints, nPoints);

% calculate distances and populate the upper triangular portion of pDist
for i = 1:nPoints

    % store the current latitude and longitude
    currLong = latLong(i, 1);
    currLat = latLong(i, 2);

    for j = (i + 1):nPoints

        % calculate the distance between the current pair of points
        pDist(i, j) = distance('rh', currLat, currLong, ...
            latLong(j, 2), latLong(j, 1));

    end

end

% populate the bottom half of the array
pDist = pDist + pDist';

% convert results to distances in km, as distance outputs arclen in degrees
% of arc length, and so we need to fix this by calculating the arc length
% when each degree is 111km long, so simply multiply everything by 111
pDist = 111 * pDist;

end
