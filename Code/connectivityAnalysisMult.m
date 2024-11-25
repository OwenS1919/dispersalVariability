function [conAnTable, conAnRowNames] = connectivityAnalysisMult( ...
    conMatsCell)
% connectivityAnalysisMult() will calculate a number of summary statistics
% for multiple connectivity matrices, and present the results in a matrix
% form thingy

% inputs:

% conMatsCell - a cell array of cell arrays, where conMatsCell{i}{j} holds
    % the jth connectivity matrix from the ith biophysical model

% outputs:

% conAnTable - a cell array containing matrices holding summary statistics,
    % where each column corresponds to a different biophysical model, and
    % each row corrsponds to a different statistic of interest

% set out each of the row names, just so I know what I'm going to calculate
rowNames = ["Min", "Median", "Mean", "Max", "IQR", "Range"];

% fucmk it, maybe I should make multiple tables for the different stats we
% want to look into

% table 1 will be the mean connectivity values

% table 2 will be the variance

% table 3 will be the range

% table 4 will be the coefficient of variation

% for each table, we should do the: min, median, mean, max, range


end