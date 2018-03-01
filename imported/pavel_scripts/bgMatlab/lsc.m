function o=lsc(varargin)
%LSC         same as LS or DIR, but returns a cell array of filenames
%  LIST = LSC(PATTERN)  directories are ignored
%  LSC(PATTERN, 't')    sort files by time
%
%  See also LS, DIR.

%  $Id: lsc.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flags = '';
if length(varargin) > 1
    flags = varargin{2};
    varargin(2) = [];
end
res = dir(varargin{:});
isdir = cat(1, res.isdir);
res(isdir) = [];
o = {res.name};
if nargin > 0
    head = fileparts(varargin{1});
    if ~isempty(head)
        for i = 1:length(o)
            o{i} = fullfile(head, o{i});
        end
    end
end
o = o(:);

% sort by time if requested
if find(flags == 't', 1) & length(o) > 1
    tstr = {res.date};
    tnum = datenum(tstr);
    [ignore, i] = sort(tnum);
    o = o(i);
end
