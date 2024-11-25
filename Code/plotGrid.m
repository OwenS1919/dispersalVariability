function plotGrid(partArr, fig, holdOn, index)
% plotGrid will plot a grid stored in partArr

% inputs:
% partArr – A multidimensional array containing the x and y coordinates of
% each individual partition, and will be of dimension n by 2 by 5, where n
% refers to the number of total partitions created, 2 refers to the
% coordinates for x and y, and 5 is due to the 5 vertices (including the
% first vertex twice) of each rectangle. The cell indices begin at the top
% left corner, then move left to right and then top to bottom
% fig - optional - if specified as "fig" will create a figure in the
% function
% holdOn - optional - if specified as "holdOn" will leave hold on before
% exiting method
% index - optional - but will plot the index of each partition

% intialise optional variables
if nargin < 2 || isempty(fig)
    fig = "";
end
if nargin < 3 || isempty(holdOn)
    holdOn = "";
end
if nargin < 4 || isempty("index")
    index = "";
end

% create figure if necessary
if fig == "fig"
    figure
end
hold on

% determine the number of partitions
nParts = size(partArr, 1);

% loop over and plot each partition
for p = 1:nParts
    plot(squeeze(partArr(p, 1, :)), squeeze(partArr(p, 2, :)))
end

if index == "index"
    for p = 1:nParts
        text(squeeze(partArr(p, 1, 1)), squeeze(partArr(p, 2, 1)), num2str(p))
    end
end

if holdOn ~= "holdOn"
    hold off
end

axis equal

end