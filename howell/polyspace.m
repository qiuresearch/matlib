function poly = polyspace(x1, x2, P, N)
% --- Usage:
%        poly = polyspace(x1, x2, P, N)
%
% --- Purpose:
%        create an array quadratically spaced between x1 and x2
%
%
% --- Parameter(s):
%        x1: first value of the array
%        x2: second value of the array
%        P:  polynomial power
%
% --- Return(s): 
%        poly: array of quadratically spaced values
%
% --- Example(s):
%
% $Id: polyspace.m,v 1.1 2015/06/24 14:28:58 schowell Exp $
%

if ~exist('N','var')
    N = 100;
end

poly = linspace(x1^(1/P), x2^(1/P), N).^P;