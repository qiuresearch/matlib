function result = sigfig(number, n)
% --- Usage:
%        result = sigfig(number, n)
%
% --- Purpose:
%        reformat a number to have 'n' decimal places
%
%
% --- Parameter(s):
%
%
% --- Return(s):
%
% --- Example(s):
%
%         x = 1.53426;
%         x_2 = sigfig(x,2); % x_2 -> 1.53
%         x_1 = sigfig(x,1); % x_1 -> 1.5
%         x_0 = sigfig(x,0); % x_0 -> 2
%         
% $Id: sigfig.m,v 1.1 2013/05/13 15:57:00 schowell Exp $
%
    
    if (nargin < 2)
        help iqgetx_getiq_sns
        return
    end
    
    result = round(number*10^n)/10^n;