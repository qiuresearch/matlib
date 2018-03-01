function [PK,FPWAI]=pswpk1(files, varargin)
%PSWPK1    improved fitting of PSW ordering peaks
%    [PK,FPWAI]=PSWPK1(XRDFILES, p1, p2, ...) 
%    possible additional arguments p:
%    'iw', interval width, must be followed by number
%    'fn', peak function, must be followd by 'l', 'g', or 0<gamma<1
%    'pk'  initial peak parameters
%    'v',  view the fit details
%    'i',  show iterations
%
%See also REFPKS

%defaults and constants
pk0.th2 =[18.8	21.8]; %positions
pk0.fwhm=[.3	.2];   %FWHM's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rno=[];
if isnumeric(files)
    rno=files;
    files={};
    for i=1:length(rno);
	files{i}=sprintf('z%05i.raw', rno(i));
    end
end
files=cellstr(files);
fN=length(files);
if isempty(rno)
    rno=zeros(fN,1);
    for i=1:fN
	j = find(files{i}>='0' & files{i}<='9');
	rno(i)=sscanf(files{i}(j(end-4:end)), '%i');
	if length(j)==length(files{i})
	    files{i}=['z' files{i} '.raw'];
	end
    end
end

pN=2;
%FPWAI - results matrix File Pos1 Fwhm1 Amp1 Int1...
FPWAI=[ rno(:) , zeros(fN, 4*pN) ];

for i=1:fN
    pk0.fname=files{i};
    p1 = refpks(pk0, 'mx', 'q', varargin{:});
    PK(i)=p1;
    FPWAI(i,2:end)=[p1.th2(1) p1.fwhm(1) p1.a(1) 10*p1.irel(1) ...
		      p1.th2(2) p1.fwhm(2) p1.a(2) 10*p1.irel(2) ];
end
if nargout==0
    fprintf('file        th2         fwhm        A1/A2       I1/I2\n');
    fprintf('------------------------------------------------------\n');
    fprintf('%i %12.3f%12.4f%12.4f%12.4f\n', [FPWAI(:,1:3) ...
	  FPWAI(:,4)./FPWAI(:,8) FPWAI(:,5)./FPWAI(:,9) ]');
end
