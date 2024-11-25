function array = removeNaNs(array)
% removeNaNs() simply removes any NaN values from a 1D

% input:

% array - the array to remove the NaNs from

% output:

% array - the same array, however now with any NaN values removed (i.e. may
    % have less elements)

% remove the NaNs (very complicated I know)
nanInds = isnan(array);
array = array(~nanInds);

end