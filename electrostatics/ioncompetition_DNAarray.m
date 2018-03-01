function ionmodel = ioncompetition_DNAarray(ionbuf, varargin)
% --- Usage:
%        ionmodel = ioncompetition_DNAarray(ionbuf, varargin)
% --- Purpose:
%        The cell model was critisized for assuming a crystal-like
%        behavior of a liquid state structure, and it is more accurate
%        for very concerntrated solutions.  The Jellium model regards
%        the macromolecule and its condensed counterions as a uniform
%        background for subtraction. The effective charge and the
%        background charge can be determined self-consistently. It
%        is more suitable for dilute moelcular solutions. Please
%        refer to Trizac and Levin PRE, 69, 031403, 2004 for details.
%   
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: ioncompetition_DNAarray.m,v 1.1 2012/07/05 03:09:48 xqiu Exp $
%

   