function colormap = myColourMap(n, styleInd)
% myColourMap will make a custom colormap emulating the matlab turbo
% colormap but with colours that I like more lol

% inputs:

% n - optional - the resolution of the colormap - default is 256
% styleInd - optional - a string indicating the colourmap style to use -
    % default is turbo

% output:

% colormap - a colormap in the default matlab form n x 3

% set default values if necessary
if nargin == 0 || isempty(n)
    n = 256;
end
if nargin < 2 || isempty(styleInd)
    styleInd = "turbo";
end


% split based on the colourmap choice being made
if styleInd == "turbo"

    % order will be the same as turbo, so black, to dark blue, to blue, to
    % green, to yellow, to orange to red
    k = [0 0 0];
    db = [0 0.4470 0.7410];
    lb = [0.3010 0.7450 0.9330];
    g = [0.4660 0.6740 0.1880];
    y = [0.9290 0.6940 0.1250];
    o = [0.8500 0.3250 0.0980];
    r = [0.6350 0.0780 0.1840];

    % consolidate these in a matrix, because it's easier
    colMat = cat(1, k, db, lb, g, y, o, r);

    % create a set of points at which each colour currently sits
    colPoints = linspace(0, 1, 7);

elseif styleInd == "halfTurbo"

    % order will be the same as turbo but without the darker colours and
    % ending in grey, so grey, to green, to yellow, to orange to red
    gr = [0.925 0.925 0.925];
    g = [0.4660 0.6740 0.1880];
    y = [0.9290 0.6940 0.1250];
    o = [0.8500 0.3250 0.0980];
    r = [0.6350 0.0780 0.1840];

    % consolidate these in a matrix, because it's easier
    colMat = cat(1, gr, g, y, o, r);

    % create a set of points at which each colour currently sits
    colPoints = linspace(0, 1, 5);

else

    % otherwise, assume we are using a single colour colourmap, that will
    % fade from white to the colour in question - first determine the base
    % colour
    if styleInd == "k"
        baseCol = [0 0 0];
    elseif styleInd == "db" || styleInd == "b"
        baseCol = [0 0.4470 0.7410];
    elseif styleInd == "g"
        baseCol = [0.4660 0.6740 0.1880];
    elseif styleInd == "y"
        baseCol = [0.9290 0.6940 0.1250];
    elseif styleInd == "o"
        baseCol = [0.8500 0.3250 0.0980];
    elseif styleInd == "r"
        baseCol = [0.6350 0.0780 0.1840];
    elseif styleInd == "lb"
        baseCol = [0.3010 0.7450 0.9330];
    elseif styleInd == "p"
        baseCol = [0.4940 0.1840 0.5560];
    end

    % simply set up the colMat array
    colMat = cat(1, [1, 1, 1], baseCol);
    colPoints = [0, 1];

end

% create a set of values to interpolate at
intPoints = linspace(0, 1, n);

% interpolate the r values
rVals = interp1(colPoints, colMat(:, 1), intPoints);

% interpolate the g values
gVals = interp1(colPoints, colMat(:, 2), intPoints);

% interpolate the b values
bVals = interp1(colPoints, colMat(:, 3), intPoints);

% join back values
colormap = cat(2, rVals', gVals', bVals');

end
