function data = replaceNaNs(data, replaceVal)
% replaceNaNs will replace NaNs in some dataset data, with the value
% replaceVal

% inputs:
% data - an array or matrix which potentially contains NaNs
% replaceVal - optional - the value to replace the NaNs with - defualt = 0

% output:
% data - the same as the input variable data, however now with the NaNs
%     replaced with replaceVal

% set default value for replaceVal
if nargin < 2 || isempty(replaceVal)
    replaceVal = 0;
end

% determine where the NaNs are
mask = isnan(data);

% replace them with replaceVal
data(mask) = replaceVal;

end