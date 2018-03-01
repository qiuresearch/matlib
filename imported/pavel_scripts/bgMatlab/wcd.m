function wcd(varargin)
%wcd  3.2.1  (Apr 5 2006) - Wherever Change Directory
%Usage: wcd [drive:][dir] [-h] [-V] [-Q] [-b] [-l] [-c] [-e[e]] [-E <path>]
%       [-s] [-S <path>] [-a[a]] [-A <path>] [-u <username>] [-f <treefile>]
%       [-n <path>] [-i] [-d <drive>] [-[m|M|r|rmtree] <dir>] [-t]
%       [-v] [-g[a|d]] [-N] [-o[d]] [-j] [-G <path>] [-z #] [-[#]] [+[#]] [=]
%       [-w] [-x <path>] [-xf <file>] [-k]
%  dir (partial) name of directory to change to.
%      Wildcards *, ? and [SET] are supported!
%  -h  show this Help                 -m  Make <dir>, add to treefile
%  -V  Verbose operation              -M  Make <dir>, add to extra treefile
%  -Q  Quieter operation              -r  Remove <dir>, (-rmtree recursive)
%  -u  use User's treefile (+u add)   -c  direct CD mode
%  -f  use extra treeFile (+f add)    -l  aLias current dir
%  -n  use relative treefile (+n add) -b  Ban current path
%  -s  (re)Scan disk from $HOME       -v  print Version info
%  -S  Scan disk from <path> (+S rel) -L  print software License
%  -a  Add current path to treedata   -e  add current path to Extra treedata
%  -A  Add tree from <path>           -E  add tree from <path> to Extra treedata
%  -   Push dir (# times)             -i  Ignore case (+i regard case)
%  +   Pop dir (# times)              -d  set <Drive> for stack & go files (DOS)
%  =   Show stack                     -z  set max stack siZe
%  -w  Wild matching only             -N  use Numbers
%  -o  use stdOut (-od dump matches)  -g  Graphics (-ga alt nav; -gd  dump tree)
%  -j  Just go mode                   -G  set path Go-script  -GN  No Go-script
%  -x  eXclude path during disk scan  -k  Keep paths
%  -xf eXclude paths from File

%  $Id: wcd.m 34 2007-03-13 20:16:42Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    disp(cd)
    return
end
arg='';
smartcase = 1;
set_ignorecase = smartcase & ...
    (nargin > 0) & isempty(strmatch('-', varargin{end})) & ...
    ~any(strcmp('-i', varargin)) & ~any(strcmp('+i', varargin)) & ...
    strcmp(lower(varargin{end}), varargin{end});
if set_ignorecase
    varargin = {'-i', varargin{:}};
end

for a = varargin
    arg = [ arg ' ' a{1} ];
end

if isunix
    [s,w]=unix(['wcd.exe ' arg ], '-echo');
    fid = fopen( fullfile( getenv('HOME'), 'bin/wcd.go' ) );
    w = char( fread( fid, [1 Inf] ) );
    start = strfind(w, 'cd '); start = start(1);
    w = w(start:end);
    fclose(fid);
    eval(w);
    return;
end

% must be Windows
[s,w]=dos(['wcd.exe -j -GN ' arg ], '-echo');
if ~isempty(strmatch('-> ', w))
    w(1:3) = ''
end
w( w == sprintf('\n') | w == sprintf('\r') ) = '';

if isempty(w) | strmatch('Wcd: ', w)
    return
end
if ~isempty(strmatch('/cygdrive/', w))
    w=[w(11) ':' w(12:end)];
end

if isempty(findstr(arg, '--help'))
    cd(w)
end
