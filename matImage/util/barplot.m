function hl = barplot(data, varargin)
%BARPLOT plot mean and mean variance of data
%
%   barplot(data)
%   each column of data is an experiment
%   rows are repetition of experiment.
%

%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 25/08/2005
%


if iscell(data)
    N = length(data);
    md    = zeros(1, N);
    stdm  = zeros(1, N);
    for i = 1:length(data)
        md(i) = mean(data{i});
        stdm(i) = std(data{i}) / sqrt(length(data{i}));
    end
else    
    md = mean(data);
    stdm = std(data) / sqrt(size(data, 1));
end

bar(md, 'facecolor', 'b');

for i = 1:size(data, 2)
    hl = line([i i], [md(i) md(i)+stdm(i)]);
    set(hl, 'color', 'k');
    hl = line([i-.2 i+.2], [md(i)+stdm(i) md(i)+stdm(i)]);
    set(hl, 'color', 'k');
end

xlim([0 size(data, 2)+1]);
if ~isempty(varargin)
    set(gca, 'xticklabel', varargin{1});
end
