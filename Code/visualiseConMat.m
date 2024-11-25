function visualiseConMat(conMat, noFigFlag, genericInd)
% visualiseConMat will visualise the connectivity matrix in a basic
% circular layout

% the plan is to update this code as I go, for now it is useful for just a
% 3 reef system

% input:

% conMat - a connectivity matrix representing the system to be modelled,
    % where conMat(i, j) represents the probability that larvae released
    % from reef i will settle at reef j
% tLFlag - optional - a variable with value "noFig" if no figure should be
    % generated in this code (i.e. visualisation is part of a tiledlayout
    % etc) - default is "fig", i.e. to create a figure

% set defaults
if nargin < 2 || isempty(noFigFlag) || noFigFlag ~= "noFig"
    figInd = true;
else
    figInd = false;
end
if nargin < 3 || isempty(genericInd)
    genericInd = false;
else
    genericInd = true;
end

% determine the number of reefs
nReefs = size(conMat, 1);

% determine an angle at which each of the reefs will sit, moving clockwise
% with reef 1 at the top, and convert these to points
reefAngles = linspace(pi / 2, -3 * pi / 2, nReefs + 1);
reefAngles = reefAngles(1:(end - 1));
reefX = cos(reefAngles);
reefY = sin(reefAngles);

% determine the largest connection in the system, or just set the largest
% connection colour to 1, and set a max and min linewidth
maxConn = max(max(conMat));
if figInd
    nodeSize = 90;
    arrowSize = 8;
    lWMin = 1;
    lWMax = 3;
    labelSize = 15;
else
    nodeSize = 50;
    arrowSize = 4;
    lWMin = 0.5;
    lWMax = 2.5;
    labelSize = 10;
end

% if we want a generic plot, we just set the max connectivity to like
% realmax hehe
if genericInd
    maxConn = realmax;
end

% begin drawing in the connections, starting with the self recruitment
hold on
selfRecRad = 0.125;
thetaVec = linspace(0, 2 * pi, 21);
for r = 1:nReefs
    if conMat(r, r) > 0

        % plot the circle
        centreCircleX = selfRecRad * cos(thetaVec + reefAngles(r) + pi);
        centreCircleY = selfRecRad * sin(thetaVec + reefAngles(r) + pi);
        circleCentre = (1 + selfRecRad) * [cos(reefAngles(r)), ...
            sin(reefAngles(r))];
        circleX = centreCircleX + circleCentre(1);
        circleY = centreCircleY + circleCentre(2);
        plot(circleX, circleY, 'k', 'lineWidth', lWMin + (lWMax - lWMin) ...
            * (conMat(r, r) / maxConn), 'color', ...
            getColour(conMat(r, r), maxConn))

        % add an arrow in the middle to represent the direction
        mP = round(length(circleX) / 2);
        ah = annotation('arrow', 'headStyle', 'cback1', ...
            'HeadLength', arrowSize, 'HeadWidth', arrowSize, 'Color', ...
            getColour(conMat(r, r), maxConn));
        set(ah, 'parent', gca)
        set(ah, 'position', [circleX(mP), circleY(mP), (circleX(mP) ...
            - circleX(mP+1)), (circleY(mP) - circleY(mP+1))])

    end
end

% create functions which will rotate points
rotFuncX = @(x, y, theta) x .* cos(theta) - y .* sin(theta);
rotFuncY = @(x, y, theta) y .* cos(theta) + x .* sin(theta);

% now, draw in the larval transfer between reefs,
for i = 1:nReefs

    for j = 1:nReefs

        % skip diagonal entries
        if i == j
            continue
        end

        % check for a nonzero connection
        if conMat(i, j) > 0

            % determine the distance between the two points, then calculate
            % some other geometric bullshit I can't be bothered trying to
            % explain because I'm lazy
            % eventually, I should alter the curve radius based on if the
            % two points are neighbouring or not but oh well
            curveRad = 4;
            pointDist = pdist2([reefX(i), reefY(i)], [reefX(j), reefY(j)]);
            betweenAngleCurve = acos(1 - pointDist^2 / (2 * curveRad^2));
            betweenAngle = acos(1 - pointDist^2 / 2);
            curveTheta = linspace((pi - betweenAngleCurve) / 2, ...
                (pi + betweenAngleCurve) / 2, 20);

            % generate the unrotated points -> need to figure out the
            % centre of the new circke fuck -> can just add this on to the
            % y things though and we'll be fine
            xCurve1 = curveRad * cos(curveTheta);
            yCurve1 = curveRad * sin(curveTheta) - (sqrt(curveRad^2 - ...
                (pointDist / 2)^2) - sqrt(1 - (pointDist / 2)^2));

            % check the direction of the connection
            angleDiff = asin(sin(reefAngles(j) - reefAngles(i)));
            if angleDiff < 0

                % rotate the points 90 degrees to the right, and then rotate
                % back to the right position
                xCurve2 = rotFuncX(xCurve1, yCurve1, -pi / 2);
                yCurve2 = rotFuncY(xCurve1, yCurve1, -pi / 2);
                xCurve = rotFuncX(xCurve2, yCurve2, reefAngles(i) ...
                    - betweenAngle / 2);
                yCurve = rotFuncY(xCurve2, yCurve2, reefAngles(i) ...
                    - betweenAngle / 2);

            else

                % flip the points if we are doing an anti - clockwise
                % connection
                yCurve1 = 2 * sqrt(1 - (pointDist / 2)^2) - yCurve1;
                xCurve1 = fliplr(xCurve1);
                yCurve1 = fliplr(yCurve1);

                % rotate the points 90 degrees to the right, and then rotate
                % back to the right position
                xCurve2 = rotFuncX(xCurve1, yCurve1, -pi / 2);
                yCurve2 = rotFuncY(xCurve1, yCurve1, -pi / 2);
                xCurve = rotFuncX(xCurve2, yCurve2, reefAngles(j) ...
                    - betweenAngle / 2);
                yCurve = rotFuncY(xCurve2, yCurve2, reefAngles(j) ...
                    - betweenAngle / 2);

            end

            % plot the connection
            plot(xCurve, yCurve, 'lineWidth', lWMin + (lWMax - lWMin) ...
                * (conMat(i, j) / maxConn), 'Color', 'k', 'color', ...
                getColour(conMat(i, j), maxConn))

            % add an arrow in the middle to represent the direction
            mP = round(length(xCurve) / 2);
            ah = annotation('arrow', 'headStyle', 'cback1', ...
                'HeadLength', arrowSize, 'HeadWidth', arrowSize, 'Color', ...
                getColour(conMat(i, j), maxConn));
            set(ah, 'parent', gca)
            set(ah, 'position', [xCurve(mP), yCurve(mP), (xCurve(mP) ...
                - xCurve(mP+1)), (yCurve(mP) - yCurve(mP+1))])

        end

    end
end

% now draw in circles for the reefs
for r = 1:nReefs
    plot(reefX(r), reefY(r), 'k.', 'MarkerSize', 1.05 * nodeSize)
    plot(reefX(r), reefY(r), '.', 'MarkerSize', nodeSize, 'Color', ...
        getColour(r, nReefs))
    text(reefX(r), reefY(r), num2str(r), "FontSize", labelSize, ...
        'Color', 'w', 'FontWeight', 'bold', 'lineStyle', 'none', ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle')
end

% setup the colorbar, and control the axes
scatter([10, 10], [10, 10], 1, [0, maxConn])
if ~genericInd
    colormap(myColourMap());
    colorbar('limits', [0, maxConn])
end
axis off
axis([min(reefX) - 0.3, max(reefX) + 0.3, min(reefY) - 0.3, max(reefY) ...
    + 0.3])
axis equal

end
