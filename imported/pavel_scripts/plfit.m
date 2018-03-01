function HOUT = plfit( expname, varargin )
% PLFIT    PLFIT(EXPNAME, OPTIONS)
% plots the fitted PDF from EXPNAME.pdf, difference curver from EXPNAME.dif
% and experimental data from the file in EXPNAME.sh
% possible options:
%   c	  show cumulative Rw
%   nd    turn off difference curve
%   ndat  don't plot observed data
%   s	  calculated data linestyle

% defaults:
c_s='-';	%default line style
c_color=[];	%default line style
c_cumRw = 0;
c_nd = 0;
c_ndat = 0;
c_Rw_color = [0.5 0 0];
c_Rw_lw = .25;

[p,f,e] = fileparts( expname );
if strcmp(e, '.pdf')
    expname = fullfile(p, f);
end
e_sh = [ expname '.sh' ];
e_pdf = [ expname '.pdf' ];
e_dif = [ expname '.dif' ];
e_res = [ expname '.res' ];

% process options
i=1;
while i<=length(varargin)
    curarg=varargin{i};
    if strcmp( curarg(1:min(end,1)), '-' );
	curarg(1)='';
    end
    switch(curarg),
	case 'c',
	c_cumRw = 1;
	case 'nd',
	c_nd = 1;
	case 'ndat',
	c_ndat = 1;
	% case 'iw',
	% i=i+1; curarg=varargin{i};
	% if isstr(curarg)
	%     c_iw=sscanf(curarg, '%f', 1);
	% else
	%     c_iw=curarg;
	% end
	otherwise,
	if strmatch( 's', curarg )
	    if length(curarg)==1
		i=i+1; curarg=varargin{i};
	    else
		curarg=curarg(2:end);
	    end
	    c_s = curarg;
	    if isnumeric( c_s )
		c_color = ncol( c_s(1) );
	    else
		ci=find(c_s>='0' & c_s<='9');
	    end
	    if length(ci)
		c_color=ncol(sscanf(c_s(ci(1):end), '%i', 1));
		c_s(ci)='';
	    end
	else
	    error(sprintf('unknown switch %s', curarg))
	end
    end
    i=i+1;
end
% options done

% read data
d_calc = rhead( e_pdf );
d_dif  = rhead( e_dif );

if ~isequal( d_calc(:,1) , d_dif(:,1) )
    error('pdf and dif files have different r')
end
Gcalc = d_calc(:,2);
Gdif  = d_dif(:,2);
Gobs = Gcalc + Gdif;
r = d_calc(:,1);

h = plot(r, Gcalc, c_s);
if ~isempty( c_color ); 
    set(h(1), 'Color', c_color );
end
hold_state = get(gca, 'NextPlot');
hold on
if ~c_ndat
    h=[ h ; plot(r, Gobs, 'k-.') ];
end

if ~c_nd
    ydlev = min(Gcalc) - max(Gdif);
    h = [ h ;
	plot(r([1 end]), [ydlev ydlev], r, Gdif+ydlev)
    ];
    set(h(end-1), 'Color', 'k', 'LineWidth', 0.15, 'LineStyle', '--')
end
if c_cumRw
    h = [h ; add_cumRw( e_res, r, Gobs, Gcalc, c_Rw_lw, c_Rw_color ) ];
end

xlim(r(1), r(end))
xlabel('r (Å)');
ylabel('G(r)')
title( esctex(expname) )

set(gca, 'NextPlot', hold_state)
if nargout > 0
    HOUT = h;
end


function hc = add_cumRw( e_res, r, Gobs, Gcalc, c_Rw_lw, c_Rw_color )
% add cumulative Rw to the plot

f_res = fopen( e_res, 'r' );
s_res = char( fread( f_res, [1 inf], 'char' ) );
fclose( f_res );
i = findstr( s_res, 'DATA SET :   1' );
i = i(1);
s_data = s_res(i:i+120);
ib = find( s_data == '(' )+1; ib=ib(1);
ie = find( s_data == ')' )-1; ie=ie(1);
p = fileparts( e_res );
e_dat = fullfile( p, s_data(ib:ie) );
e_dat(e_dat=='\') = '/';
d_dat = rhead( e_dat, 62 );
w = interp1( d_dat(:,1), d_dat(:,4), r );

Rw2 = cumsum( w .* ( Gobs - Gcalc ).^2 ) ./ sum( w .* Gobs.^2 );
Rw  = sqrt( Rw2 );
% normalize to max Gobs
obs_min = min(Gobs);
obs_max = max(Gobs);
Rwn = Rw * ( obs_max - obs_min ) / max(Rw) + obs_min;
hc = [
    plot( r, Rwn, 'Color', c_Rw_color );
    text( r(end), Rwn(end), sprintf('Rw = %.4f', Rw(end)), ...
	'Color', c_Rw_color, ...
	'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
];
if ~isempty( c_Rw_lw )
    set( hc(1), 'LineWidth', c_Rw_lw );
end
