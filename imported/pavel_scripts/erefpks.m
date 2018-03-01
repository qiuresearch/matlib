function [PK, RES]=erefpks(file, th20, varargin)
%EREFPKS   easy fitting of the peaks
%    [PK, RES]=EREFPKS(FILE, TH20, p1, p2, ...) 
%    FILE  can be in raw or gsas format, or it can be line handle
%    for fitting the data, use
%       EREFPKS('', TH20, 'xy', XY, ... )
%    RES = sum(f-y)^2 / length(y)
%    possible additional arguments p:
%    'iw'  interval width, must be followed by number
%    'fn'  peak function, must be followd by 'l', 'g', or 0<gamma<1
%    'v'   view the fit details
%
%See also REFPKS

%defaults and constants
pk0.th2=  th20(:)'; 			%positions
%pk0.fwhm= .25+zeros(size(pk0.th2));   	%FWHM's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isnumeric(file)
    if ishandle(file(1)) & strcmp(get(file(1),'Type'), 'line')
	x0 = get(file(1), 'XData');
	y0 = get(file(1), 'YData');
	pk0.xy = [ x0(:) y0(:) ];
	file = 'LineHandle';
    else
	file=sprintf('z%05i', file(1));
    end
end
if length(file) & all(file >= '0' & file <= '9')
    file = ['z' file];
end
pk0.fname=file;

[PK,RES]=refpks(pk0, varargin{:});

if nargout==0
    fprintf('\n%s\tRES=%g\n', PK.fname, RES);
    fprintf('pos\t  fwhm\t  Irel\t  Ampl\n');
    fprintf('------------------------------\n');
    fprintf('%.3f\t%6.4f\t%6.4g\t%6.1f\n',  ...
	[PK.th2   PK.fwhm   PK.irel PK.a]');
    fprintf('\n');
    clear PK RES
end
