function plotAutocorrVals(autocorrVec, autocorrRankVec, propNonzeroConn, ...
    descString)
% plotAutocorrVals() is just a helper function I am using to plot
% autocorrelation values

% inputs:

% autocorrVec - a vector of autocorrelation values to plot
% propNonzeroConn - the proportion of timesteps at which a connection must
    % have a nonzero connection to be considered
% descString - a string describing the model and the time intervals it
    % operates over

% plot shit
figure
tL = tiledlayout(2, 1);
title(tL, descString + " Autocorrelation Values Distribution", ...
    "interpreter", "latex")
if propNonzeroConn < 10^-4
    subtitle(tL, "Only connections with $\geq 1$ nonzero value considered", ...
        "interpreter", "latex")
else
    subtitle(tL, "Only connections with $\geq " + num2str(100 * ...
        propNonzeroConn) + "\%$ nonzero values considered", ...
        "interpreter", "latex")
end
nexttile
hold on
histogram(autocorrVec, "EdgeAlpha", 0, "FaceColor", getColour('b'))
xline(mean(autocorrVec), "--")
xlabel("Autocorrelation")
ylabel("Count")
legend("", "Average Value", "Location", "northwest")
nexttile
hold on
histogram(autocorrRankVec, "EdgeAlpha", 0, "FaceColor", getColour('b'))
xline(mean(autocorrRankVec), "--")
xlabel("Rank Autocorrelation")
ylabel("Count")
legend("", "Average Value", "Location", "northwest")

end