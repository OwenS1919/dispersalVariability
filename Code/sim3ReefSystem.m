function [varS3Sim, varS3Theory] = sim3ReefSystem(c1Hat, c2Hat, c1Std, ...
    c2Std, n1Hat, n2Hat, n1Std, n2Std, corrC, corrN, plotInd)
% in a rush to finish my thesis so not commenting xoxo

if nargin < 11 || isempty(plotInd)
    plotInd = "plot";
end

% form the sigma matrices
sigmaN = [n1Std^2, n1Std * n2Std * corrN; n1Std * n2Std * corrN, n2Std^2];
sigmaC = [c1Std^2, c1Std * c2Std * corrC; c1Std * c2Std * corrC, c2Std^2];

if plotInd == "plot"

    % generate some random streams for each
    tMax = 20;
    nVals = mvnrnd([n1Hat, n2Hat], sigmaN, tMax);
    cVals = mvnrnd([c1Hat, c2Hat], sigmaC, tMax);

    % plot each of the streams hehe
    figure
    tiledlayout(2, 2)

    % plot the population values
    nexttile
    hold on
    plot(nVals(:, 1))
    plot(nVals(:, 2))
    title("$N(t)$")

    % plot the connectivity values
    nexttile
    hold on
    plot(cVals(:, 1))
    plot(cVals(:, 2))
    title("$C(t)$")

    % plot the larval output of both
    nexttile
    hold on
    plot(nVals(:, 1) .* cVals(:, 1))
    plot(nVals(:, 2) .* cVals(:, 2))
    title("$N(t) \times C(t)$")

    % plot their sum
    nexttile
    hold on
    plot(nVals(:, 1) .* cVals(:, 1) + nVals(:, 2) .* cVals(:, 2))
    title("$N(t) \times C(t)$")

else

    % generate some random streams for each
    % tMax = 100;
    tMax = 1000;
    nVals = mvnrnd([n1Hat, n2Hat], sigmaN, tMax);
    cVals = mvnrnd([c1Hat, c2Hat], sigmaC, tMax);

end

% calculate the variance in the larval intake to reef 3
varS3Sim = var(nVals(:, 1) .* cVals(:, 1) + nVals(:, 2) .* cVals(:, 2));

% calculate the theoretical variance in the larval intake to reef 3
varS3Theory = c1Hat^2 * n1Std^2 + c2Hat^2 * n2Std^2 ...
    + n1Hat^2 * c1Std^2 + n2Hat^2 * c2Std^2 + c1Std^2 * n1Std^2 ...
    + c2Std^2 * n2Std^2 + 2 * (c1Hat * c2Hat * n1Std * n2Std ...
    * corrN + n1Hat * n2Hat * c1Std * c2Std * corrC + c1Std ...
    * c2Std * n1Std * n2Std * corrC * corrN);

end