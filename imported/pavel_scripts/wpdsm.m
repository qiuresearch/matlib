function wpdsm(file, sref, flag)
%WPDSM  save pks structure to a file suitable for UPDSM
%   Usage: WPDSM(FILE, S [, FLAG] )
%   for FLAG='ka'  the CuKA2 dublets are first removed.
%
%See also REFPKS, WPROM, RPKS, WREFPKS

%   2001 by Pavol

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%constants:
c_ddtol=1e-3;	%tolerance in d to determining K12 dublets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3
    flag='';
end

if isstr(sref)
    sref=evalin('caller', sref);
end

%double check
if ~isfield(sref, 'icps') | ~isfield(sref, 'fwhm') | ~isfield(sref, 'irel') |...
   ~isfield(sref, 'fname')| ~isfield(sref, 'desc') | ~isfield(sref, 'd')
    error('Input argument is not valid PKS structure')
end

%take care of the flag
switch flag
case '',
case 'ka',
    %remove dublets
    i=2;
    Ka1=phconst('cuka1');
    Ka2=phconst('cuka2');
    dK=Ka2-Ka1;
    while i<=length(sref.th2)
	d1 = dK ./ 2 ./ sin(sref.th2(i)/2*pi/180) + sref.d(i) - sref.d(1:i-1);
	if any(abs(d1) < c_ddtol)
	    %found dublet
	    fprintf('removing CuKa2 peak at th2=%.3f\n', sref.th2(i));
	    sref=pksind(sref, i, 'v');
	else
	    i=i+1;
	end
    end
otherwise,
    error(sprintf('unknown flag %s', flag));
end

%write it down
fid=fopen(file, 'wt');
%build the variable name
[ig, n, e]=fileparts(sref.fname);
fprintf(fid, '%s - refined\n', [n e]);
fprintf(fid, '%s\n', sref.desc);
fprintf(fid, '%-10.5f%.2f\n', [sref.d, sref.irel]');
fclose(fid);
