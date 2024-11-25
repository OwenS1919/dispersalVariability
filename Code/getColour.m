function colour = getColour(val, maxVal, cMapInd)
% getColour will produce an RGB triplet based on a colourmap specified in
% cMap, which is proportional to some current value and the max value

% OR - so that it works with my other method, can just be used to return a
% nicer RGB triplet than matlab's defaults if val is valted as a char -
% ceebs commenting this properly but the code should make that case self -
% evident

% inputs:

% val - current value for which colour will be representative of (integer)
    % OR alternatively a char or string value from the set of 'b', 'o',
    % 'y', 'p', 'g', 'lb', 'r' OR an integer from the set 1 - 7 - in this
    % case, following outputs become irrelevant
% maxVal - the maximum possible value
% cMapInd - optional  - the type of colourmap used, e.g. "jet", or could be
    % any of the colours mentioned for val, in which place colourmap
    % transitions from white to said colour - default is "mine" for
    % myColourMap

% outputs:

% colour - an rgb triplet, i.e. 1 x 3 vector between 1 and 0

% set the default for the colour map
if nargin < 3 || isempty(cMapInd)
    cMapInd = "mine";
end

% set the maxVal to empty if it is not specified
if nargin < 2 || isempty(maxVal)
    maxVal = [];
end

% create a vector of the colour possibilities
colourCodes = ['b', 'o', 'y', 'p', 'g', 'lb', 'r'];

% convert the integer value to an rgb triplet
if nargin == 1 && ((class(val) == "double" && round(val) == val) ...
        || class(val) == "int") && isempty(maxVal)

    % just in case the val exceeds 7, simply convert it
    if val > 7
        val = mod(val, 6) + 1;
    end
    val = colourCodes(val);

end

if class(val) == "char" || class(val) == "string"

    % now just use some switch cases to return the correct colour
    switch val

        case {'b', "b"}
            colour = [0 0.4470 0.7410];
        case {'o', "o"}
            colour = [0.8500 0.3250 0.0980];
        case {'y', "y"}
            colour = [0.9290 0.6940 0.1250];
        case {'p', "p"}
            colour = [0.4940 0.1840 0.5560];
        case {'g', "g"}
            colour = [0.4660 0.6740 0.1880];
        case {'lb', "lb"}
            colour = [0.3010 0.7450 0.9330];
        case {'k', "k"}
            colour = [0, 0, 0];
        otherwise
            colour = [0.6350 0.0780 0.1840];
            
    end

else

    % initialise the colourmap -> if we have a maxVal, treat this as the
    % 256th entry, and scale val based on this
    switch cMapInd
        case "jet"
            cMap = jet();
        case "mine"
            cMap = myColourMap();
        case "halfTurbo"
            cMap = myColourMap([], "halfTurbo");
        otherwise
            cMap = myColourMap([], cMapInd);
    end

    % return the correct colour
    colour = cMap(max([ceil(256 * (val / maxVal)), 1]), :);

end

end
