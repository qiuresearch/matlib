function xyyplot(varargin)
%        xyyplot(varargin)
% plot one or more MxN matrix. First column is X, following columns
% are Y. 
%

if isempty(varargin)
   help xyyplot
   return
end

for i = 1:length(varargin)
  plot(varargin{i}(:,1), varargin{i}(:,2:end) );
end
