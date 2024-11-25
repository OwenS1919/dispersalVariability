function [ntExp, ntVar, ntSSVec] = meanVarBH(a, b, sigma, ntVec, calcInd)
% meanVarBH will calculate the mean and variance for a Beverton - Holt
% model with multiplicative stochasticity using lognmormally distributed
% random varaible zt with a mean of 0, assuming the system has reached a
% pseudo - steady state

% the a and b inputs signify the Beverton - Holt parameters:

% n_{t+1} = z_{t} * a * n_{t} / (1 + b * n_{t})

% important note - this method seems to fail for very low sigma values, so
% should really fix this up at some point

% look at the transition matrices - there is a clear error somewhere in
% this code regarding the transfer to the final state, so need to fix this
% up

% inputs:

% a - the a parameter for the Beverton - Holt model
% b - the b parameter for the Beverton - Holt model
% sigma - the sigma parameter for the multiplicative lognormal
%     stochasticity
% ntVec - optional - holds the specific set of states the Beverton - Holt
%     model is being discretised to in ascending order - default will
%     simply calculate 1.5 * the equilibrium population for a non -
%     stochastic model and will discretise so that there are at least 50
%     states
% calcInd - optional - if value is "iter" it uses standard iterations of
%     the Markov transition matrix to produce the steady state, and if
%     value is "eigen" it will use eigendecomposition to speed up this
%     process (potentially) - default is "iter"

% outputs:

% ntExp - the expected value for the pseudo - steady state Beverton - Holt
%     model
% ntVar - the variance of the pseudo - steady state Beverton - Holt model
% ntSSVec - the steady state vector determined

% calculate the equilibrium population for a deterministic model
nInf = -(1 - a) / b;

% assign a defaults to ntVec and calcInd if necessary
if nargin < 4 || isempty(ntVec)

    % create a vector of at least 50 states for this model
    if round(1.5 * nInf) >= 50
        ntVec = 0:round(1.5 * nInf);
    else
        ntVec = linspace(0, round(1.5 * nInf), 50);
    end

end
if nargin < 5 || isempty(calcInd)
    calcInd = "iter";
end

% determine the gap between points in ntVec
delta = (ntVec(2) - ntVec(1)) / 2;

% determine the number of states
nStates = length(ntVec);

% if the sigma parameter is 0, simply return the above for the mean
% population and 0 for the variance
if sigma == 0 
    ntExp = nInf;
    ntVar = 0;
    ntSSVec = zeros(nStates, 1);
    [~, nInfInd] = min(abs(ntVec - nInf));
    ntSSVec(nInfInd) = 1;
    return
end

% compute the Markov transition probability matrix, noting that the tMat(0,
% 0) = 1, setting up functions for the left and right bounds
lb = @(x, y) max((y - delta) * (1 + b * x) / (a * x), 0);
rb = @(x, y) (y + delta) * (1 + b * x) / (a * x);
tMat = zeros(nStates, nStates);
tMat(1, 1) = 1;
for x = 2:nStates
    for y = 1:nStates

        % calculate P(n_{t+1} = y | n_{t} = x)
        leftBound = lb(ntVec(x), ntVec(y));
        rightBound = rb(ntVec(x), ntVec(y));
        if y == ntVec(nStates)
            rightBound = inf;
        end
        tMat(x, y) = logncdf(rightBound, 0, sigma) - logncdf(leftBound, 0, ...
            sigma);

    end
end

% while tMat should have row sums = 1, just to avoid numerical error
% convert them all to 1
tMat = tMat ./ sum(tMat, 2);

% manually iterate through Markov transitions until a steady state can be
% reached

% set the prior to just the value closest to equilibrium population then
% iterate Markovian transitions
ntSSVec = zeros(nStates, 1);
[~, nInfInd] = min(abs(ntVec - nInf));
ntSSVec(nInfInd) = 1;
ntSSVecPrev = zeros(nStates, 1);
iter = 1;
while iter < 200 && (max(abs(ntSSVec - ntSSVecPrev)) > 1e-4 || iter < 20)

    % iterate through, and to avoid any numerical error normalise the
    % steady state vector after each iteration
    ntSSVecPrev = ntSSVec;
    ntSSVec = tMat' * ntSSVec;
    iter = iter + 1;
    ntSSVec = ntSSVec / sum(ntSSVec);

end

% compute the expected value and variance of n_{t}
ntExp = dot(ntSSVec, ntVec);
ntVar = dot(ntSSVec, (ntVec - ntExp).^2);

end
