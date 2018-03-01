function [Hout,Yout] = fplt(file, varargin)
%FPLT        quickly plot ascii data file
%  H = FPLT(FILE, P1, P2,...)  plots one or more files,
%    FILE can be either a single string, matrix, or a list of strings
%  FPLT &FILELIST P1 P2 ...  plots all files in the variable FILELIST
%
%  syntax for additional arguments P:
%    'x'  must be followed by x data column number or 0 for no x data
%         by default FPLT tries to guess if it should use column 1 for x
%    'y'  must be followed by y data column(s) number/vector,
%    	  use -1 to for the last column
%    'l'  must be followed by number or ex-style address of header
%         lines to skip
%    'b'  number of bytes to skip, 'b' and 'l' are exclusive
%    'd'  must be followed by numbers of data sets to plot [1],
%    	  use -1 for the last set
%    'f'  use extra figure for every data set
%    'C'  clear figure before plotting
%    'h'  hold on before plotting
%    's'  should be followed by line style, or by a number of
%    	  color from the ColorOrder, sN uses next ColorOrder color
%    'head'  print the header lines
%    't'  add title for a single file plot
%    'r'  don't plot, just read the data e.g.
%         [X,Y] = FPLT(file, 'r') or XY = FPLT(file, 'r')
%         FPLT(file, 'r')  reads to variables x_fplt, y_fplt in caller

%  $Id: fplt.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%constants:
c_nx=[];	%x data column
c_ny=[];	%y data column
c_b=0;		%header bytes to skip
c_l=0;		%header lines to skip
c_d=1;		%data set to read
c_f=0;		%all in one fig
c_C=0;		%do not clear figure
c_h=0;		%no explicit hold on
c_head=0;	%do not print header
c_t=0;		%don't put title unless asked to
c_r=0;		%this is for reading
c_s='';		%default line style
c_color=[];	%plot color
c_dxtol=1;	%tolerance for guessing the x-column
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ischar(file) & file(1)=='&'
    file=evalin('caller', file(2:end));
end

i=1; files2={};
if isstr(file) & length(varargin) > 0
    idash = find( strcmp( '--', varargin ) );
    if any( idash )
	idash = idash(1);
	files2 = varargin(1:idash-1);
	varargin(1:idash) = [];
    else
	i=1;
	while i <= length(varargin)  &  exist( varargin{i}, 'file' )
	    files2{end+1} = varargin{i};
	    i = i+1;
	end
	varargin(1:i-1) = [];
    end
end

if length(files2) > 0
    file = { file , files2{:} };
end

i=1;
while i<=length(varargin)
    carg=varargin{i};
    switch(carg(1))
	case {'x', 'y'},
	    ca1 = carg(1);
	    if length(carg)==1
		i=i+1; carg=varargin{i};
	    else
		carg=carg(2:end);
	    end
	    if isstr(carg)
		cxy=eval([ '[' carg ']' ]);
	    else
		cxy = carg;
	    end
	    if isempty(cxy)
		error(sprintf('Cannot interpret "%s"', carg));
	    end
	    if ca1=='x'
		c_nx = cxy;
	    else
		c_ny = cxy;
	    end
	case 'b',
	    % cancel line offset
	    c_l = 0;
	    if length(carg)==1
		i=i+1; carg=varargin{i};
	    else
		carg=carg(2:end);
	    end
	    if isstr(carg)
		c_b=sscanf(carg, '%i', 1);
	    else
		c_b = carg;
	    end
	case 'l',
	    % cancel byte offset
	    c_b = 0;
	    if length(carg)==1
		i=i+1; carg=varargin{i};
	    else
		carg=carg(2:end);
	    end
            c_l = carg;
	case 'd',
	    if length(carg)==1
		i=i+1; carg=varargin{i};
	    else
		carg=carg(2:end);
	    end
	    if isstr(carg)
		c_d=eval([ '[' carg ']' ]);
	    else
		c_d = carg;
	    end
	    c_d=c_d(:)';
	case 'h',
	    if strcmp(carg, 'head')
		c_head=1;
	    elseif strcmp(carg, 'h')
		c_h=1;
	    end
	case 'r',
	    c_r=1; c_f=0; c_C=0;
	case 't',
	    c_t=1;
	case 'f',
	    c_f=1; c_r=0;
	case 'C',
	    c_C=1; c_r=0;
	    c_Cidx = i;
	case 's',
	    if length(carg)==1
		i=i+1; carg=varargin{i};
	    else
		carg=carg(2:end);
	    end
	    c_s = carg;
	    if isnumeric( c_s )
		c_color = ncol( c_s(1) );
	    else
		ci=find(c_s>='0' & c_s<='9');
	    end
	    if length(ci)
		c_color=ncol(sscanf(c_s(ci(1):end), '%i', 1));
		c_s(ci)='';
	    else
		ci = find(c_s == 'N');
		if (length(ci))
		    c_Next = length(findobj(get(gca, 'Children'), 'flat', ...
			'Type', 'line', 'Visible', 'on')) + 1;
		    c_color = ncol(c_Next);
		    c_s(ci) = '';
		end
	    end
	otherwise,
	    error(sprintf('unknown switch %s', carg))
    end
    i=i+1;
end

if c_f, c_C = 0; end
if c_C
    clf;
    % do this only once
    varargin(c_Cidx) = [];
end
if c_h
    hold on;
end
hp=[];
% call itself for several files
if iscellstr( file )
    ax = []; org_hold = '';
    if ~c_f
	ax = gca;
	org_hold = get( ax, 'NextPlot' );
    end
    for i = 1:length(file)
	if c_f
	    figure
	end
	if isempty(c_s) & isempty(c_color) & ~c_f
	    carg = sprintf('s%i', i);
	    hp = [ hp;  fplt(file{i}, carg, varargin{:}) ];
	else
	    hp = [ hp; fplt(file{i}, varargin{:}) ];
	end
	set( ax, 'NextPlot', 'Add' );
    end
    set( ax, 'NextPlot', org_hold );
    if nargout > 0
	Hout = hp;
    end
    return
end

if ~exist(file, 'file')
    error('File not found.')
end
fid = fopen(file, 'rt');
i=0;
while ( i < max(c_d) | any(c_d < 0) ) & ~feof(fid)
    i = i+1;
    fseek( fid, c_b, 'cof' );
    [a_data{i},a_head{i},fname] = rhead(fid, c_l);
end
c_d(c_d<0) = i + 1 + c_d(c_d<0);
if feof(fid) & i<max(c_d)
    fprintf(2, 'Cannot get more than %i datasets from %s\n', i, fname);
    c_d(c_d > i) = [];
end
fclose(fid);
if ~c_r
    hax = gca;
    orgNP = get(hax, 'NextPlot');
    if ~ishold, cla, end
    hold on;
end

for i_d = 1:length(c_d)
    data=a_data{c_d(i_d)};
    head=a_head{c_d(i_d)};
    d_m = size(data,1);
    d_n = size(data,2);
    if isempty(c_nx)
	%try to guess
	d_ds = sign( diff(data(:,1)) );
	if d_n > 1 & max(d_ds) - min(d_ds) ~=2
	    c_nx=1;
	else
	    c_nx=0;
	end
    end
    if isempty(c_ny)
	c_ny=1:d_n;
	if c_nx
	    c_ny(c_nx)=[];
	end
    end
    if c_head
	disp(head);
    end
    c_nx(c_nx<0) = d_n + 1 + c_nx(c_nx<0);
    c_ny(c_ny<0) = d_n + 1 + c_ny(c_ny<0);
    if c_nx==0
	Xout{i_d} = (1:size(data,1))';
    else
	Xout{i_d} = data(:,c_nx);
    end
    Yout{i_d} = data(:,c_ny);
    %do we need new figure
    if c_f & i_d > 1
	figure
    end
    if ~c_r
	hp1 = plot(Xout{i_d}, Yout{i_d}, c_s);
	hp = [hp; hp1];
	if ~isempty(c_color)
	    set(hp, 'Color', c_color);
	end
	[ignore,name,ext]=fileparts(fname);
	if c_t
	    title( esctex( [name ext] ) )
	    if c_f & i_d > 1
		title( esctex( sprintf('%s (#%i)', [name ext], i_d) ) )
	    end
	end
    end
end

if ~c_r
    if isempty(c_s) & isempty(c_color) & ~c_f & i_d>1
	for i=1:length(hp(:))
	    set(hp(i), 'Color', ncol(i))
	end
    end
    set(hax, 'NextPlot', orgNP);
end

if length(Xout) == 1
    Xout = Xout{:};
    Yout = Yout{:};
end

if c_r
    switch (nargout)
    case 0,
	disp('setting x_fplt, y_fplt ...');
	assignin('caller', 'x_fplt', Xout);
	assignin('caller', 'y_fplt', Yout);
    case 1,
	Hout = [ Xout, Yout ];
    case 2,
	Hout = Xout;
    end
elseif nargout>0
    Hout = hp;
end
