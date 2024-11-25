function plotPairedConSim(resMat, conStrengthMat)
% plotPairedConnSim() will plot the results from the pairedConSim()
% function

% inputs:

% resMat - an nReefs x nReefs x 4 matrix, with upper triangular elements
    % only, where resMat(i, j, k) indicates the base OF value for k = 1
    % without any action, with the rest indicating the added benefit of
    % investing in reef i for k = 2, reef j for k = 3, and both for k = 4
% conStrengthMat - a matrix where conStrengthMat(i, j) holds a measure of
    % the connectivity strength between reefs i and j, upper triangular
    % only

% we probably want to convert these matrices into vectors methinks, and I'm
% going to do it very lazily because I'm tired so leave me alone
nReefs = size(resMat, 1);
resVec = [];
conStrengthVec = [];
for i = 1:nReefs
    for j = (i + 1):nReefs
        resVec = [resVec, (resMat(i, j, 2) + resMat(i, j, 3) ...
            - resMat(i, j, 4)) / (resMat(i, j, 2) + resMat(i, j, 3))];
        conStrengthVec = [conStrengthVec, conStrengthMat(i, j)];
    end
end

% now plot
% plot(conStrengthVec, resVec, '.')
scatter(conStrengthVec, resVec, '.', 'MarkerFaceAlpha', 0.5, ...
    'MarkerEdgeAlpha', 0.5)
xlabel("Connectivity strength")
ylabel("Relative benefit")

end