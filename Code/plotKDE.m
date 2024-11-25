function plotKDE(data, bandWidth)
% plotKDE() will take an array of data, and produce a kernel density
% estimate

% inputs:

% data - an array of the data to plot
% bandWidth - optional - the bandwidth parameter to pass into the ksdensity
    % function - default is just matlab's assigned value

% check whether bandWidth has been inputted
if nargin < 2 || isempty(bandWidth)
    bandWidthInd = false;
else
    bandWidthInd = true;
end

% create the KDE, and then plot it
if bandWidthInd
    [y, x] = ksdensity(data, "BandWidth", bandWidth, "NumPoints", 200);
else
    [y, x] = ksdensity(data);
end
area(x, y, "FaceAlpha", 0.5)

end