function data_out = sinft(data_in, x_out, method, varargin)
%        data_out = sinft(data_in, x_out, method, varargin)
% --- Purpose:
%    A general sine FT transform routine with choices of methods, and
%    ESD later. Just a straight transform
%
% --- Parameter(s):
%
%
% --- Return(s):
%        results -
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: sinft.m,v 1.1 2013/08/17 16:51:00 xqiu Exp $
%

% 1) Simple check on input parameters

if (nargin < 2)
  disp('Usage:');
  disp('data_out = sinft(data_in, x_out, method)');
  return
end

method = 'adhoc';
num_outpoints = length(x_out);
data_out = zeros(num_outpoints, 2);
data_out(:,1) = x_out(:);

% 2) do the sine FT

switch method
 case 'adhoc' 
    % scale each data points with its span in Q
    y_in = data_in(:,2) .*  [ data_in(2,1) - data_in(1,1); ...
                        data_in(2:end,1) - data_in(1:end-1,1)];
    esd_isa = 0;
    for i_out=1:num_outpoints
      data_out(i_out,2) = sum(y_in .* sin(x_out(i_out)*data_in(:,1)));
    end
  case 'fft'
  case 'matrix'
  otherwise
end
