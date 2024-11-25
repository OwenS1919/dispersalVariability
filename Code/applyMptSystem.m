function [portVec, portRet, portVar, boundVals, exitFlag] = applyMptSystem( ...
    data, actionEffect, weight, discreteInd, resources, costs, boundVals, ...
    calcBoundValsInd, useParallelFlag)
% applyMptSystem() is a function which will apply modern portfolio theory
% to a dataset and return the optimal portfolio configuration for a
% system-wide context - that is, it will be considering contributions of
% reefs both inside and outside a reserve system, whereas the previous
% function applyMPT() only considered reefs inside the reserve

% the optimal portfolio configuration will be determined using matlab's
% inbuilt optimisation functions, by maximising the function weight *
% expected return + (1 - weight) * (1 - variance), where both expected
% return and variance have been normalised relative to the highest values
% in each case

% note that I lost the will to try and type this method out in a manner
% that keeps assets general and not just reefs, but I don't really care
% anymore sorry oops

% inputs:

% data - a set of time - series (or analogous) datapoints to apply MPT to,
    % where each row corresponds to a different asset, and each column
    % corresponds to its value in a different timestep
% actionEffect - the predicted increase to both the expected value (and
    % variance when squared) of populations at actioned reefs as a
    % mutliplicative increase, e.g. actionEffect = 1.1 indicates actioned
    % reefs should have 10% higher population sizes
% weight - a weight parameter representing the trade - off between the
    % expected return and variance for the whole portfolio - in this case,
    % both expected return and variance will be scaled relative to the max
    % values in each, and weight = 1 will indicate only the expected return
    % is to be prioritised
% discreteInd - optional - an indicator with value "discrete" if assets can
    % only be selected or unselected, otherwise assets will be treated as
    % if continuous investment is possible - default is "continuous"
% resources - optional - the total budget available, in the same units as
    % the below costs, note that neither are necessary if using MPT with
    % continuous investment - default is round(0.1 * nAssets)
% costs - if we have discreteInd == "discrete", then costs is a vector
    % representing the cost of choosing each asset - default is a vector of
    % ones, meaning resources could take an integer value corresponding to
    % the number of assets which can be chosen
% boundVals - optional - a 2 x 2 matrix, which holds the values [minExpRet,
    % maxExpRet; minVar, maxVar], i.e. the minimum and maximum expected
    % returns and variances possible - default is [0, 1; 1, 0], i.e.
    % no scaling at all
% calcBoundValsInd - optional - if specified as "calcBoundVals", the
    % boundary value will be calculated internally through this method,
    % using recursion, althought if weight == 0 or weight == 1 this input
    % is ignored - default is "no"
% useParallelFlag - optional - if specified as "parallel", will use
    % parallel computing when applying the genetic algorithm - default is
    % "no"

% outputs:

% portVec - a vector indicating the level of investment in each asset
    % - if discreteInd == "discrete", then vector will be binary and sum to
    % resources, otherwise vector will be in [0, 1] and sum to 1
% boundVals - a 2x2 matrix, which holds the values [minExpRet,
    % maxExpRet; minVar, maxVar], i.e. the minimum and maximum expected
    % returns and variances possible - if boundVals was not specified as an
    % input or "calcBoundVals", then it will simply take its default value
% exitFlag - for testing purposes, the final exitFlag of from the ga() call

% first, determine the number of investment options
nAssets = size(data, 1);

% set defaults for inputs where necessary
if nargin < 4 || isempty(discreteInd)
    discreteInd = "continuous";
end
if nargin < 5 || isempty(resources)
    resources = round(nAssets / 3);
end
if nargin < 6 || isempty(costs)
    costs = ones(1, nAssets);
end
if nargin < 7 || isempty(boundVals)
    boundVals = [0, 1; -1, 0];
end
if nargin < 8 || isempty(calcBoundValsInd) || calcBoundValsInd ...
        ~= "calcBoundVals"
    calcBoundVals = false;
else
    calcBoundVals = true;
end
if nargin < 9 || isempty(useParallelFlag)
    useParallelFlag = "no";
end

% extract the boundVals for ease of variable naming
minRet = boundVals(1, 1);
maxRet = boundVals(1, 2);
minVar = boundVals(2, 1);
maxVar = boundVals(2, 2);

% alter the orientation of costs if necessary, so that it is a row vector
if size(costs, 1) > size(costs, 2)
    costs = costs';
end

% determine the expected return and variance of each of the time series
expReturns = mean(data, 2);
covariances = cov(data');

% setup a function for calculating the portfolio variance
varFunc = @(x) sum((actionEffect^2 - 1) * (x' * x) .* covariances ...
    + covariances, "all");

% switch between the discrete and continuous investment options
if discreteInd == "discrete"

    % set the constraints
    A = costs;
    b = resources;
    intcon = 1:nAssets;
    lb = zeros(nAssets, 1);
    ub = ones(nAssets, 1);

    % if we need to calculate the boundary values, calculate them
    if calcBoundVals && weight ~= 0 && weight ~= 1

        % initialise storage for the boundary values
        boundVals = zeros(2, 2);

        % calculate the maximum return portfolio, and store the results
        [~, maxRet, maxVar] = applyMPT(data, 1, discreteInd, resources, ...
            costs,  [], [], useParallelFlag);
        boundVals(1, 2) = maxRet;
        boundVals(2, 2) = maxVar;

        % calculate the minimum return portfolio, and store the results
        [~, minRet, minVar] = applyMPT(data, 0, discreteInd, resources, ...
            costs,  [], [], useParallelFlag);
        boundVals(1, 1) = minRet;
        boundVals(2, 1) = minVar;

    end

    % setup the objective function
    if weight == 1

        % setup the objective function for expected returns only
        objFunc = @(x) -((actionEffect - 1) * x * expReturns ...
            + sum(expReturns));

        % ensure consistency between parallel runs
        rng(1)

    elseif weight == 0

        % set up the objective function for the minimum variance portfolio
        objFunc = @(x) sum((actionEffect^2 - 1) * (x' * x) .* covariances ...
            + covariances, "all");

        % ensure consistency between parallel runs
        rng(1)

    else

        % setup the objective function for 0 < weight < 1
        objFunc = @(x) -(weight * ((actionEffect - 1) * x * expReturns ...
            + sum(expReturns) - minRet) / (maxRet - minRet) + (1 - weight) ...
            * (sum((actionEffect^2 - 1) * (x' * x) .* covariances ...
            + covariances, "all") - maxVar) / (minVar - maxVar));

        % reset the rng in case it has been set when weight == 0 or 1
        rng('shuffle')

    end

    % ensure that the maximum area is not exceeded, and that at least 95%
    % of the area is used
    A = [A; -A];
    b = [b; -0.95 * b];

    % set the optimisation options
    popSize = min(max(10 * nAssets, 40), 200);
    opts = optimoptions('ga', 'Display', 'off', 'ConstraintTolerance', ...
        1e-5, 'FunctionTolerance', 1e-9, 'MaxGenerations', ...
        200 * nAssets, 'MaxStallGenerations', 70, 'PopulationSize', ...
        popSize, 'UseParallel', useParallelFlag == "parallel", ...
        'EliteCount', round(0.045 * popSize), 'CrossoverFraction', 0.7);
    
    % run the optimisation algorithm until it converges succesfully, or
    % hits the maximum number of iterations
    maxIters = 5;
    iter = 1;
    exitFlag = -100;
    while iter <= maxIters && exitFlag < 0
        [portVec, ~, exitFlag] = ga(objFunc, nAssets, A, b, [], [], lb, ub, ...
            [], intcon, opts);
        iter = iter + 1;
    end

    % check the exitFlag, and print if it remains negative
    if exitFlag < 0
        fprintf("Exit flag: %g, k = %g\n", exitFlag, weight)
    end

    % calculate the expected return and variance for the optimal portfolio
    portRet = -((actionEffect - 1) * portVec * expReturns ...
        + sum(expReturns));
    portVar = varFunc(portVec);

else

    % a note to myself from earlier reckons that this shit might not work
    % now xd but who knows, I don't need it for continuous problems which
    % are easier anyway so she'll be right

    % if the problem is continuous, then the constraints are simply that
    % the portVec must sum to 1, and that the weights remain in [0, 1]
    Aeq = ones(1, nAssets);
    beq = 1;
    lb = zeros(nAssets, 1);
    ub = ones(nAssets, 1);
    options = optimset("Display", "notify");

    % given that calculations of the boundary values for continuous cases
    % are trivial, calculate them by default (unless supplied)
    if calcBoundVals || sum(sum(boundVals == [0, 1; -1, 0])) == 4

        % initialise storage for the boundary values
        boundVals = zeros(2, 2);

        % calculating the maximum and minimum return portfolios for the
        % continuous investment case is trivial, so is the maximum variance
        maxRet = max(expReturns);
        minRet = min(expReturns);
        maxVar = max(covariances, [], "all");

        % calculate the minimum variance portfolio
        objFunc = @(x) sum((x' * x) .* covariances, "all");
        minVarPort = fmincon(objFunc, ones(1, nAssets) / nAssets, [], [], ...
            Aeq, beq, lb, ub, [], options);
        minVarRet = minVarPort * expReturns;
        minVar = varFunc(minVarPort);

        % assign the boundVals calculated above
        boundVals(1, 1) = minRet;
        boundVals(1, 2) = maxRet;
        boundVals(2, 1) = minVar;
        boundVals(2, 2) = maxVar;

    end

    % check if the weights are 1 or 0 -> in these cases we have calculated
    % the optimal portfolios above
    if weight == 1

        % calculate solution and return
        [~, ind] = max(expReturns);
        portVec = zeros(1, nAssets);
        portVec(ind) = 1;
        portRet = maxRet;
        portVar = varFunc(portVec);
        return
        
    elseif weight == 0

        % assign solution and return
        portVec = minVarPort;
        portRet = minVarRet;
        portVar = minVar;
        return

    end

    % setup the objective function when 0 < weight < 1
    objFunc = @(x) -(weight * (x * expReturns - minRet) ...
        / (maxRet - minRet) + (1 - weight) * (sum((x' * x) ...
        .* covariances, "all") - maxVar) / (minVar - maxVar));

    % run the optimisation problem, starting with a random vector in which
    % all assets are invested in equally
    [portVec, ~, exitFlag] = fmincon(objFunc, ones(1, nAssets) / nAssets, ...
        [], [], Aeq, beq, lb, ub, [], options);

    % note that I haven't used a check here on the exitFlags, but I do at
    % least return one xd

end

end
