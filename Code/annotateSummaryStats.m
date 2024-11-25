function annotateSummaryStats(data, posString)
% annotateSummaryStats() will take data, and annotate some key summary
% statistics in the top right hand corner of the axes (later should fix
% this and make the positioning better methinks

% inputs:

% data - data, in vector form
% posString - optional - the position to use for the text, using the same
    % syntx as matlab for legend positions - default is "northeast"

% set default for the text position
if nargin < 2 || isempty(posString)
    posString = "northeast";
end

% split cases based on the positioning
if posString == "northeast"

    % just annotate this shi xd
    text(0.95, 0.95, {"Mean = " + num2str(round(mean(data), 4)), ...
        "Med. = " + num2str(round(median(data), 4)), ...
        "Min = " + num2str(round(min(data), 4)), ...
        "Max = " + num2str(round(max(data), 4))}, 'Units', ...
        'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', ...
        'top', 'FontSize', 9)

elseif posString == "northwest"

    text(0.05, 0.95, {"Mean = " + num2str(round(mean(data), 4)), ...
        "Med. = " + num2str(round(median(data), 4)), ...
        "Min = " + num2str(round(min(data), 4)), ...
        "Max = " + num2str(round(max(data), 4))}, 'Units', ...
        'normalized', 'HorizontalAlignment', 'left', 'VerticalAlignment', ...
        'top', 'FontSize', 9)

elseif posString == "southeast"

    text(0.95, 0.05, {"Mean = " + num2str(round(mean(data), 4)), ...
        "Med. = " + num2str(round(median(data), 4)), ...
        "Min = " + num2str(round(min(data), 4)), ...
        "Max = " + num2str(round(max(data), 4))}, 'Units', ...
        'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', ...
        'bottom', 'FontSize', 9)

end

end
