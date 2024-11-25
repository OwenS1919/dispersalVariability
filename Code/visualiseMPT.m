function visualiseMPT(expRets, vars, names, assetExpRets, assetVars, ...
    randInd, presInd)
% visualise MPT will visualise a set of portfolios and assets or random
% portfolios in the expected returns to variance space

% inputs:

% expRets - the expected returns of portfolios on the Pareto optimal front
% vars - the variances of the portfolios on the Pareto optimal front
% names - the text to be placed on the legend for each of the Pareto
    % optimal solutions
% assetExpRetrs - the expected returns for either single assets (if in
    % continuous space) or random (or otherwise) selected portfolios (if in
    % the discrete decision space)
% assetVars - the associated variances of these assets or random portfolios
% randInd - optional - if specified as "rand" the legend will reflect that
    % these points are random portfolios rather than individual assets -
    % default is "no", i.e. legend text will read "Assets"
% preInd - optional - specify as "pres" to enlarge text to create figures
    % for the presentation - default is "no"

% set a default for randInd and presInd
if nargin < 6 || isempty(randInd)
    randInd = "no";
end
if nargin < 7 || isempty(presInd)
    presInd = "no";
end

% set sizes based on presInd
presInd = presInd == "pres";
sizeMult = 1 + 0.65 * presInd;

% plot all da stuff
hold on
plot(vars, expRets, ':', 'Color', [0.2, 0.2, 0.2])
for m = 1:5
    plot(vars(m), expRets(m), '.', 'Color', getColour(m), 'MarkerSize', ...
        sizeMult * 15)
end
plot(assetVars, assetExpRets, '.', 'Color', getColour(6), 'MarkerSize', ...
    sizeMult * 8)
for m = 1:5
    plot(vars(m), expRets(m), '.', 'Color', getColour(m), 'MarkerSize', ...
        sizeMult * 18)
end
if randInd == "rand"
    lg = legend(['', names(1:5), 'Random Portfolios'], 'Location', 'best');
else
    lg = legend(['', names(1:5), 'Assets'], 'Location', 'best');
end
if presInd
    if randInd == "rand"
        lg = legend(['', names(1:5), 'Random Sel.'], 'Location', 'best');
    else
        lg = legend(['', names(1:5), 'Assets'], 'Location', 'best');
    end
end
fontsize(lg, sizeMult * 7.25, 'points')
xlabel("Portfolio Variance", "FontSize", sizeMult * 11)
ylabel("Portfolio Expected Returns", "FontSize", sizeMult * 11)

end
