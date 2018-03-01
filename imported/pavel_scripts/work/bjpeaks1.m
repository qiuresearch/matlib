function PK=bjpeaks(file, varargin)
%BJPEAKS   fitting of Bostjan's peaks
%    PK=BJPEAKS(FILE, p1, p2, ...) 
%    possible additional arguments p:
%    'iw'  interval width, must be followed by number
%    'fn'  peak function, must be followd by 'l', 'g', or 0<gamma<1
%    'v'   view the fit details

%defaults and constants
pk0.th2=  [18.8	21.73	30.93]; %positions
pk0.fwhm= [.2	.2	.3];   %FWHM's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isnumeric(file)
    file=sprintf('z%05i', file(1));
end
if all(file >= '0' & file <= '9')
    file = ['z' file];
end
pk0.fname=file;

PK=refpks(pk0, varargin{:});

if nargout==0
    fprintf('\n%s\n', file);
    fprintf('pos\tfwhm\tI1/I2\n');
    fprintf('---------------------------\n');
    fprintf('%.3f\t%.4f\t%.4e\n',  ...
	[PK.th2   PK.fwhm   PK.icps/PK.icps(3)]');
    fprintf('\n');
    clear PK
end
