function optLog = plot3ReefOptSpace(c1Hat, c2Hat, c1Std, c2Std, n1Hat, ...
    n2Hat, n1Std, n2Std)
% plot3ReefOptSpace() will simply plot the optimisation space for the
% variance of reef 3's larval settlement - details are held in Chapter 3 of
% my thesis

% inputs:

% c1Hat, c2Hat - the expected values for the connectivities from reefs 1
    % and 2 to reef 3
% c1Std, c2Std - the standard deviations for the connectivity values for
    % reefs 1 and 2
% n1Hat, n2Hat - the expected values for the populations at reefs 1 and 2
% n1Std, n2Std - the standard deviations for the population values for
    % reefs 1 and 2

% outputs:

% optLoc - a vector containing the optimal correlation values [rhoC, rhoN]

% note that I'm just gonna assume R^2 is 1 just because I'm lazy and it's a
% constant multiple anyway so fuck it

% setup the good old vectors of correlations
rhoC = linspace(-1, 1, 201);
rhoN = linspace(-1, 1, 201);

% loop over both, and calculate the variance at each point
varMat = zeros(length(rhoC), length(rhoN));
for c = 1:length(rhoC)
    for n = 1:length(rhoN)
        varMat(c, n) = c1Hat^2 * n1Std^2 + c2Hat^2 * n2Std^2 ...
            + n1Hat^2 * c1Std^2 + n2Hat^2 * c2Std^2 + c1Std^2 * n1Std^2 ...
            + c2Std^2 * n2Std^2 + 2 * (c1Hat * c2Hat * n1Std * n2Std ...
            * rhoN(n) + n1Hat * n2Hat * c1Std * c2Std * rhoC(c) + c1Std ...
            * c2Std * n1Std * n2Std * rhoC(c) * rhoN(n));
    end
end

% plot that shit
imagesc(rhoN, rhoC, varMat)
colormap(myColourMap())
colorbar()
set(gca, 'Ydir', 'Normal')
xticks([-1, 0, 1])
yticks([-1, 0, 1])
% xlabel("$\rho_n$")
% ylabel("$\rho_c$")

% use an automated process because I'm lazy
if c1Hat * c2Hat > c1Std * c2Std && n1Hat * n2Hat > n1Std * n2Std
    subtitle("$CV_C < 1, \ CV_N < 1$")
elseif c1Hat * c2Hat == c1Std * c2Std && n1Hat * n2Hat == n1Std * n2Std
    subtitle("$CV_C = 1, \ CV_N = 1$")
elseif c1Std * c2Std / (c1Hat * c2Hat)  > n1Std * n2Std / (n1Hat * n2Hat) 
    if c1Std * c2Std / (c1Hat * c2Hat) == 1
        subtitle("$CV_C > CV_N, \ CV_C = 1$") 
    else
        subtitle("$CV_C > CV_N, \ CV_C > 1$") 
    end
else
    if n1Std * n2Std / (n1Hat * n2Hat) == 1
        subtitle("$CV_C < CV_N, \ CV_N = 1$") 
    else
        subtitle("$CV_C < CV_N, \ CV_N > 1$") 
    end
    
end

% determine the optimal values
minVal = min(min(varMat));
[optLog(1), optLog(2)] = find(varMat == minVal, 1);
optLog = [rhoC(optLog(1)), rhoN(optLog(2))];

end