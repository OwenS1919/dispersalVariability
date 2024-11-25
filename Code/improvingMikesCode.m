% create the searchCell and test my code, just to make sure that this
% works
gridDim = [100, 100];
[searchCellGBR, partArrGBR, borderGBR] = constructSearchCell(GBRShapeLL, ...
    gridDim);

% plot the results
% plotGBRShape(GBRShapeLL, "fig", "holdOn")
% plot(borderGBR(:, 1), borderGBR(:, 2))

% visualise the grid
% plotGBRShape(GBRShapeLL, "fig", "holdOn")
% plotGrid(partArrGBR, "", "holdOn")
% plot(borderGBR(:, 1), borderGBR(:, 2))

% ensure the method is working by checking which centroids are inside their
% reef
nReefs = length(GBRShapeLL);
test = zeros(nReefs, 1);
for r = 1:nReefs
    test(r) = findReefFast(GBRShapeLL(r).Centroid, GBRShapeLL, searchCellGBR);
end

% create a search cell for the coral trout data so that I can process the
% results more efficiently
xMin = min(centroidsCT(:, 1));
xMax = max(centroidsCT(:, 1));
yMin = min(centroidsCT(:, 2));
yMax = max(centroidsCT(:, 2));

% now form the border for the CT
xAdd = 0.1 * (xMax - xMin);
yAdd = 0.1 * (yMax - yMin);
xMax = xMax + xAdd;
xMin = xMin - xAdd;
yMax = yMax + yAdd;
yMin = yMin - yAdd;
borderCT = [xMin, yMin; xMax, yMin; xMax, yMax; xMin, yMax; xMin, yMin];
clear xMax xMin yMax yMin

% need to add extra points to the border now
nPoints = 10;
weights = linspace(0, 1, nPoints + 1);
weights = weights(1:(end - 1));
voronoiBorder = [];
for i = 1:4
    voronoiBorder = cat(1, voronoiBorder, ...
        weights' .* borderCT(i + 1, :) + (1 - weights') .* borderCT(i, :));
end

% plot the results
figure
hold on
plot(voronoiBorder(:, 1), voronoiBorder(:, 2), 'k.')
plot(centroidsCT(:, 1), centroidsCT(:, 2), '.')
axis equal
darkFig()

voronoiBorder(1, :)
voronoiBorder(end, :)

% this is the function that will do shit
delTriang = delaunayTriangulation(cat(1, centroidsCT, voronoiBorder));
[vorVert, vorInd] = voronoiDiagram(delTriang);

% % keep track of the indices which correspond to the original centroids and
% % which don't 
% borderInd = (length(centroidsCT) + 1):length(vorInd);
% 
% figure
% hold on
% % for r = 1:length(borderInd)
% %     plot(vorVert(vorInd{borderInd(r)}, 1), vorVert(vorInd{borderInd(r)}, 2), ...
% %         'k')
% % end
% plot(centroidsCT(:, 1), centroidsCT(:, 2), '.')
% for r = 1:length(centroidsCT)
%     plot(vorVert(vorInd{r}, 1), vorVert(vorInd{r}, 2))
% end
% axis equal
% % darkFig()
% % saveCoolFig("VoronoiGBR3")

% convert the voronoi indices into a shapefile
clear voronoiShapeCT borderInd
voronoiShapeCT(length(centroidsCT)) = struct();
for r = 1:length(centroidsCT)
    voronoiShapeCT(r).X = vorVert([vorInd{r}, vorInd{r}(1)], 1);
    voronoiShapeCT(r).Y = vorVert([vorInd{r}, vorInd{r}(1)], 2);
    voronoiShapeCT(r).Centroid = centroidsCT(r, :);
end

% make sure the above has worked correctly
figure
hold on
for r = 1:5:500
    plot(voronoiShapeCT(r).X, voronoiShapeCT(r).Y, "Color", ...
        getColour(r));
    plot(voronoiShapeCT(r).Centroid(1), voronoiShapeCT(r).Centroid(2), ...
        'o', "Color", getColour(r));
end
darkFig()

% ensure that there are no more infs in the array
for r = 1:length(voronoiShapeCT)
    if sum(voronoiShapeCT(r).X == inf) > 0 || ...
        sum(voronoiShapeCT(r).Y == inf) > 0
        error
    end
end

% now, need to form the search cell
[searchCellCT, partArrCT, borderCT] = constructSearchCell(voronoiShapeCT);

% plot the above
figure
hold on
plot(centroidsCT(:, 1), centroidsCT(:, 2), 'k.')
plotGrid(partArrCT, [], "holdOn")
darkFig()

% check the findClosestPoints() method
sum = 0;
for r = 1:length(centroidsCT)
    if findClosestPoint(centroidsCT(r, :), voronoiShapeCT, ...
            searchCellCT, partArrCT) == r
        sum = sum + 1;
    end
end
sum

% now, let's test the speed difference here
nReefs = length(voronoiShapeCT);
tic
for n = 1:1000
    test = zeros(nReefs, 1);
    for r = 1:nReefs
        test(r) = findReefFast(voronoiShapeCT(r).Centroid, voronoiShapeCT, ...
            searchCellCT);
    end
end
fastVer = toc
centroidsTest = zeros(length(GBRShapeLL), 2);
for r = 1:length(GBRShapeLL)
    centroidsTest(r, :) = GBRShapeLL(r).Centroid;
end
tic
for n = 1:1000
    test = zeros(nReefs, 1);
    for r = 1:nReefs
        dist = pdist2(voronoiShapeCT(r).Centroid, centroidsCT);
        [~, ind] = min(dist(:));
    end
end
slowVer = toc

% simulate this pdist2() bullshit here because it is pissing me off
points = [1, 1; 1, 2; 3, 4; 5, 1];
point = [2, 2];
figure
hold on
plot(points(:, 1), points(:, 2), '.')
plot(point(1), point(2), 'k.')
axis([0, 6, 0, 6])
darkFig()

% look at the distances
dists = pdist2(point, points)
[~, test] = min(dists)

% I feel like crying because these are almost the exact same amount of
% time -> maybe let's see if I can create a version that doesn't use
% inpolygon instead idk -> like once it gets to the end of the search cell,
% it can just check the pdist there
