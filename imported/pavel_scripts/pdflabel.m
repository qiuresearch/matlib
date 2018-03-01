function HOUT = pdflabel(a, ltype, rmax, varargin)
%PDFLABEL  add markers for the ideal ABO3 pdf peaks positions to gca
%  PDFLABEL(A,LTYPE,RMAX, P1, P2, ...) 
%    A is the lattice parameter of base cell
%    values of labels LTYPE: 0 .. none, [1] .. alpha, 2 .. Pb-O
%  PDFLABEL OFF remove labels in gca
%  PDFLABEL ALLOFF  remove all labels in gcf
%  similarly
%  PDFLABEL [ALL]RESET  resets all labels in gca, or gcf
%  possible additional arguments P:
%    'TL',tl   normalized position of text labels [0.02]
%    'GH',gh   high grid lines cut-off
%    'GL',gl   low grid lines cut-off

%defaults and constants
c_tl = 0.02;		% y position of text labels
c_gh = [];		% high cut-off for grid lines
c_gl = [];		% low cut-off for grid lines

s_a='B-O'; s_b=sprintf('Pb-O\nO-O'); s_g='Pb-B';
rl = {
sqrt(1/4),   '\alpha1',	s_a
sqrt(2/4),   '\beta1',  s_b
sqrt(3/4),   '\gamma1', s_g
sqrt(4/4),   '1',	'100'
sqrt(5/4),   '\alpha2',	s_a
sqrt(6/4),   '\beta2',	s_b
sqrt(8/4),   '2',	'110'
sqrt(9/4),   '\alpha3', s_a
sqrt(10/4),  '\beta3',  s_b
sqrt(11/4),  '\gamma3', s_g
sqrt(12/4),  '3',	'111'
sqrt(13/4),  '\alpha4', s_a   
sqrt(14/4),  '\beta4',	s_b   
sqrt(16/4),  '4',	'200' 
};

if nargin < 2; ltype = 1; end
if nargin < 3; rmax = Inf; end
if isempty( rmax )
    rmax = Inf;
end

i=1; args=varargin;
while i<=length(args)
    curarg=args{i};
    switch(curarg)
    case 'gh',
        i=i+1;
        c_gh=args{i}(1);
    case 'gl',
        i=i+1;
        c_gl=args{i}(1);
    case 'tl',
        i=i+1;
        c_tl=args{i}(1);
    otherwise,
	error(sprintf('unknown switch %s', curarg))
    end
    i=i+1;
end

if strcmp( a, 'alloff' )
    delete( findobj( gca, 'Tag', 'PDFLABEL' ) ); return
elseif strcmp( a, 'off' )
    delete( findobj( gcf, 'Tag', 'PDFLABEL' ) ); return
elseif strcmp( a, 'reset' )
    hpl = findobj( gca, 'Tag', 'PDFLABEL', 'Type', 'line' );
    if isempty( hpl ); return; end
    hpl = hpl(1);
    udata = get(hpl, 'UserData' );
    args = { udata.args };
    delete( findobj( gca, 'Tag', 'PDFLABEL' ) );
    pdflabel( args{:} );
    return;
elseif strcmp( a, 'allreset' )
    s_gca = gca;
    for ha = findobj( gcf, 'type', 'axes' )';
	axes( ha )
	pdflabel( 'reset' );
    end
    axes( s_gca );
    return
end
a = a(1);

xl = get( gca, 'XLim' );
yl = get( gca, 'YLim' );
y0 = ( yl(2) - yl(1) )*c_tl + yl(1);

r0 = cat(2, rl{:,1}) * a;
i = find(r0 < rmax);
r0 = r0(i); 
rl = rl(i,:);
L = size(rl,1);
xm = [r0 ; r0; NaN+r0];
xm = xm(:);
yml = yl;
if length( c_gl )
    yml(1) = c_gl;
end
if length( c_gh )
    yml(2) = c_gh;
end
ym = [ zeros(1,L) + yml(1); zeros(1,L) + yml(2); zeros(1,L) + NaN ];
ym = ym(:);
h_l = line( xm, ym, 'LineStyle', '--', 'Color', 'k', 'LineWidth', .15, ...
		    'Tag', 'PDFLABEL', 'UserData', ...
		    struct('args', {a, ltype, rmax, varargin{:}}) );
prop_t = {};
switch ltype
case 1,
    prop_t = { 'HorizontalAlignment', 'center',...
	       'VerticalAlignment', 'bottom' };
case 2,
    prop_t = { 'Rotation', 90,...
	       'HorizontalAlignment', 'left',...
	       'VerticalAlignment', 'middle' };
end

h_t = [];
if ltype
    for i = find( r0 >= xl(1) & r0 <= xl(2) );
	h_t = [h_t;
	    text( rl{i,1}*a, y0, rl{i,ltype+1},...
		'Tag', 'PDFLABEL', prop_t{:} );
	];
    end
end

if nargout > 0
    HOUT = [h_l(:) ; h_t(:)];
end
