function o_s = pks2fin(sp, sc, varargin);
%PKS2FIN   prepare finax input for refinment
%   S = PKS2FIN(SPKS, SC, P1, P2, ...) returns string for finax
%   PKS2FIN tries to index peaks given in SP, according
%   to the PDF card in structure SC
%   possible additional arguments P:
%    'lam'   wavelength, must be followed by number
%    's',  simple, indexes only 6 strongest lines
%    'iw', interval width, must be followed by number
%    'il', intensity level, must be followed by number
%    'ab', lattice parameters, must be followd abcABG vector
%    'rd', try to remove CuK1, CuK2 dublets
%    'v'   verbose, report what is done
%   use RPKS to read SP, RAIDS to get SC
%
%See also RPKS, RAIDS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%constants:
c_lam=phconst('cuka1');    %Cu Kalpha1
c_iw=1;		%interval width
c_il=0;		%intensity level
c_ab=sc.abcABG; %not given, take from SAIDS
c_s=0;		%keep only identified peaks
c_rd=0;		%do not remove dublets
c_v=0;		%no verbose
c_ddtol=1e-3;	%tolerance in d to determining K12 dublets
c_sitol=7e-3;	%tolerance in d for finding Si peaks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=1;
while i<=length(varargin)
    curarg=varargin{i};
    switch(curarg)
    case 'lam',
	i=i+1;
	c_lam=varargin{i}(1);
    case 'iw',
	i=i+1;
	c_iw=varargin{i}(1);
    case 'il',
	i=i+1;
	c_il=varargin{i}(1);
    case 'ab',
	i=i+1;
	c_ab=varargin{i};
    case 'rd',
	c_rd=1;
    case 's',
	c_s=1;
    case 'v',
	c_v=1;
    otherwise,
	error(sprintf('unknown switch %s', curarg))
    end
    i=i+1;
end

%remove dublets
if c_rd
    i=2;
    Ka1=phconst('cuka1');
    Ka2=phconst('cuka2');
    dK=Ka2-Ka1;
    while i<=length(sp.th2)
	d1 = dK ./ 2 ./ sin(sp.th2(i)/2*pi/180) + sp.d(i) - sp.d(1:i-1);
	if any(abs(d1) < c_ddtol)
	    %found dublet
	    if c_v
		fprintf('removing CuKa2 peak at th2=%.3f\n', sp.th2(i));
	    end
	    sp=pksind(sp, i, 'v');
	else
	    i=i+1;
	end
    end
end

%Silicon data, reference: PDF 27-1402
dsi = [ 3.13550  
	1.92010  
	1.63750  
	1.35770  
	1.24590  
	1.10860  
	1.04520  
	.960000  
	.918000  
	.858700  
	.828200  ];
psi = [];
for i=1:length(dsi)
    [x,j]=min(abs(dsi(i)-sp.d));
    if x < c_sitol
	psi=[psi; j];
    end
end
m_si=[];
if length(psi)>2
    m_si = sp.th2(psi);
    sp=pksind(sp, psi, 'v');
    if c_v
	fprintf('found %i Si standard peaks\n', length(psi));
    end
end

%match peaks
sc.d=dspace(c_ab, sc.hkl);
sc.th2=d2th2(sc.d, c_lam);
hklt=NaN+ones(length(sp.d),4);
for ip=1:length(sp.d);
    t2=sp.th2(ip);
    i1=find(abs(t2-sc.th2)<c_iw);
    if length(i1>1)
	[ignore, i2]=min(abs(sc.th2(i1) - sp.th2(ip)));
	i1 = i1(i2);
    end
    if ~isempty(i1)
	hklt(ip,:)=[sc.hkl(i1,:) sc.th2(i1)];
    end
end

%take care of c_il
i1=find(sp.irel<c_il);
if c_v 
    fprintf('removing %i peaks with irel<%.1f...\n', length(i1), c_il);
end
hklt(i1,:)=[];
sp=pksind(sp, i1, 'v');

%make it simple...
if c_s
    i1=find(isnan(hklt(:,1)));
    if c_v 
	fprintf('removing %i unidentified peaks...\n', length(i1));
    end
    hklt(i1,:)=[];
    sp=pksind(sp, i1, 'v');
end

s_1=sprintf('TITLE  %s %s\n', sp.fname, sp.desc);
s_2=sc.SG; s_2=char([s_2 ; ' '+0*s_2]); s_2=deblank(s_2(:)');
s_2=strrep(s_2, ' / ', '/');
s_2=upper(strrep(s_2, '- ', '-'));
s_2=sprintf('CRYSTL %-10s', s_2);
s_2=[s_2 sprintf('%.5g ', c_ab) sprintf('/\n')];
s_3=sprintf('CONDIT DS CUA1 /\n');
if ~isempty(psi)
    s_4=sprintf('STNDRD SI %s/\n', sprintf('%.4f ', m_si));
else
    s_4='';
end
if c_v
    s_5=sprintf('  %-4i%-4i%-4i%6.4f  (%.4f, %.2f)\n', ...
	[hklt(:,1:3) sp.th2 hklt(:,4) sp.irel]');
else
    s_5=sprintf('  %-4i%-4i%-4i%6.4f\n', [hklt(:,1:3) sp.th2]');
end
if nargout==0
    if c_v, fprintf('\n'); end
    disp([s_1 s_2 s_3 s_4 s_5])
else
    o_s=[s_1 s_2 s_3 s_4 s_5];
end
