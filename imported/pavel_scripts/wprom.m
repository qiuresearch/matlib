function wprom(file, sp, flag)
%WPROM     write PKS structure to powder2 promer file
%   Usage: WPROM(FILE, S [, FLAG] )
%   where S is a PKS structure
%   WPROM('', S), would only print the prom data 
%   for FLAG='ka'  the CuKA2 dublets will be removed.
%
%See also REFPKS, WPDSM, RPKS, WREFPKS

%   2001 by Pavol

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%constants:
c_ddtol=1e-3;	%tolerance in d to determining K12 dublets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3
    flag='';
end

if isstr(sp)
    sp=evalin('caller', sp);
end

%double check
if ~isfield(sp, 'th2') | ~isfield(sp, 'irel') | ~isfield(sp, 'd')
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
    while i<=length(sp.th2)
	d1 = dK ./ 2 ./ sin(sp.th2(i)/2*pi/180) + sp.d(i) - sp.d(1:i-1);
	if any(abs(d1) < c_ddtol)
	    %found dublet
	    fprintf('removing CuKa2 peak at th2=%.3f\n', sp.th2(i));
	    sp=pksind(sp, i, 'v');
	else
	    i=i+1;
	end
    end
otherwise,
    error(sprintf('unknown flag %s', flag));
end

%write it down
if isempty(file)
    fid=1;
else
    fid=fopen(file, 'wt');
end
%build the variable name
desc='';
if isfield(sp, 'fname')
[ig, n, e]=fileparts(sp.fname);
    desc=[desc n e ', '];
end
if isfield(sp, 'desc')
    desc=[desc sp.desc];
end
fprintf(fid, 'Commentary: %s\n', desc);
fprintf(fid, 'Cu Ka1, diffractometer, none standard\n');
fprintf(fid, '  N     2*TH        D          Q       I/Io\n');
fprintf(fid, '\n');
pl = length(sp.th2);
fprintf(fid, '%3i%10.3f%11.4f%11.2f%7.0f\n', ...
    [ (1:pl)' sp.th2 sp.d  1e4./sp.d.^2  sp.irel ]');
if fid~=1
    fclose(fid);
end
