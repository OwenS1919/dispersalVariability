function figResize(heightMult, widthMult)
% figResize is a simple function I am using in order to create figures
% which are sized differently to normal matlab figures

% heightMult - optional - the factor by which to multiply the default
    % matlab figure height by - default is 1.8
% widthMult - optional - the factor by which to multiply the default matlab
    % figure width by - default is 1

% set defaults if necessary
if nargin < 1 || isempty(heightMult)
    heightMult = 1.8;
end
if nargin < 2 || isempty(widthMult)
    widthMult = 1;
end

% set the figure proporties to create the desired effect
set(gcf, 'position', [0, 0, widthMult * 560, heightMult * 420])

end
