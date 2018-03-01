function [data, offset] = saxs_setbaseline(data, refdata, match_range, varargin)
% A simple wrapper for match.m applied to iq data

[iq_dummy, scale, offset] = match(data, refdata, match_range, 'all', 1, 'dy', data(:,4));
data(:,2) = data(:,2) + offset/scale;
%[data(:,2), scale, offset] = match(data, refdata, match_range, 'all', 1, 'dy', data(:,4));