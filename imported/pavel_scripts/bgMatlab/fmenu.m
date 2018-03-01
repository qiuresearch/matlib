function fmenu( varargin )
%FMENU       display or hide figure(s) menu and toolbar
%FMENU [FIGURE] [FLAGS]
%  FIGURE  string or vector of figure handles or 'all', def. [gcf]
%  FLAGS   may have one of the following values:
%     m         show menu only
%     t         show only toolbar
%     mt, tm    show menu and toolbar
%    [toggle]   set toolbar to its default and toggle menu setting
%     on        set toolbar to its default, set menu on
%     off|none  hide toolbar and menubar

%  $Id: fmenu.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% default arguments
c_hf = [];
% default setting is 'toggle':
s_menu = 'toggle';
s_tool = 'toggle';

i = 1;
while i <= nargin
    carg = varargin{i}; i = i + 1;
    if isnumeric( carg )
        c_hf = [ c_hf; carg(:) ];
        continue;
    elseif isstr(carg) & carg(1) >= '0' & carg(1)<='9'
        j = eval( carg );
        c_hf = [ c_hf; j(:) ];
        continue;
    end
    switch carg
    case 'all',
        c_hf = findobj( 'Type', 'figure', 'Visible', 'on' );
    case 'm',
        s_menu = 'figure'; s_tool = 'none';
    case 't',
        s_menu = 'none';   s_tool = 'figure';
    case {'mt', 'tm'},
        s_menu = 'figure'; s_tool = 'figure';
    case 'on',
        s_menu = 'figure'; s_tool = 'default';
    case {'off', 'none'},
        s_menu = 'none';   s_tool = 'none';
    case 'toggle',
        s_menu = 'toggle'; s_tool = 'toggle';
    otherwise,
        error(sprintf('unknown switch %s', carg))
    end
end

if isempty(c_hf)
    c_hf = gcf;
end
if strcmp(s_menu, 'toggle') == 1
    s_tool = 'default';
    if strcmp( get(c_hf(1), 'Menubar'), 'none' )
        s_menu = 'figure';
    else
        s_menu = 'none';
    end
end

set( c_hf, 'Menubar',s_menu, 'Toolbar', s_tool )
