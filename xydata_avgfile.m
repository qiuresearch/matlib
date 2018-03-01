function [iq_avg, iq_all] = iq_avgfile(filenames, varargin)
% --- Usage:
%        [iq_avg, iq_all] = iq_avgfile(filenames, varargin)
%
% --- Purpose:
%
% --- Parameter(s):
%        filenames   -  a cell array of strings 
%        varargin    - 'datadir', 'suffix'
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: xydata_avgfile.m,v 1.1 2013/04/03 16:04:52 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

datadir = '';
suffix = '';
parse_varargin(varargin);

% read in all data
for i=1:length(filenames);
   iq_all{i} = loadxy([datadir filenames{i} suffix]);
   num_rows(i) = length(iq_all{i}(:,1));
end

% assume the column #1 is Q, all other columns are simply averaged

iq_avg = iq_all{1};
for i=2:length(filenames)
   iq_avg = iq_avg +iq_all{i};
end

iq_avg = iq_avg/length(filenames);
