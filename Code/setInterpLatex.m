function setInterpLatex()
% setInterpLatex() will just set the default interpreter to latex for the
% text, axes ticks, and legend
% set(groot, 'defaultTextInterpreter', 'latex');
% set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
% set(groot, 'defaultLegendInterpreter', 'latex');
% set(groot, 'defaultColorbarTickLabelInterpreter', 'latex');

% apparently this from some individual online will change absolutely
% everything to latex which is cool
list_factory = fieldnames(get(groot,'factory'));
index_interpreter = find(contains(list_factory,'Interpreter'));
for i = 1:length(index_interpreter)
    default_name = strrep(list_factory{index_interpreter(i)},'factory','default');
    set(groot, default_name,'latex');
end

end
