function [out,stda]=pprec(pkf,isverb)
%PPREC     corrects perovskite XRD peaks file to the Si standard
%[A,STDA]=PPREC(PKFILE, ISVERB), where
%   PKFILE is a peaks file, A the found lattice constant,
%   VERBOSE=1 prints all steps and plots the lattice parameter fit
%   VERBOSE=2 generates input for finax with double unit cell

% 2000 by Pavol

%note: D from pks file is trashed and calculated from th2 for cuka1

sith2tol=0.120;
q2tol=0.06;
th2ref=21.8;
ihklref=2; 	%it is 100 in phkl

if nargin<2
    isverb=0;
end
if length(pkf)>1
    if isverb>0
	disp('sorry, isverb is possible only for single file...')
	isverb=0
    end
    out=0*pkf;
    stda=out;
    for i=1:prod(size(pkf));
	[out(i),stda(i)]=pprec(pkf(i), isverb);
    end
    return;
end

%1:1 ordered perovskite data:
phkl=[	1/2 	1/2 	1/2
	1	0	0
	1	1	0
	3/2	1/2	1/2
	1	1	1
	2	0	0
	3/2	3/2	1/2
	2	1	0
	2	1	1
	3/2	3/2	3/2
	2	2	0
	5/2	3/2	1/2
	3	0	0
	3	1	0];
q2=sum(phkl.^2,2)./sum(phkl(ihklref,:).^2);

%Silicon data, reference: PDF 27-1402
sidhkl =[   3.13550  1  1  1
	    1.92010  2  2  0
	    1.63750  3  1  1
	    1.35770  4  0  0
	    1.24590  3  3  1
	    1.10860  4  2  2
	    1.04520  5  1  1
	    .960000  4  4  0
	    .918000  5  3  1
	    .858700  6  2  0
	    .828200  5  3  3];
sith2=d2th2(sidhkl(:,1));
if isstruct(pkf)
    pk=pkf;
else
    pk=rpks(pkf);
end
%force cuka1
%pk.d=th2d(pk.th2);
pk0=pk;

idxsi=[];
idxpk=1:length(pk.th2);
for i=find(sith2>=pk.th2(1) & sith2<=pk.th2(end))';
    [dif,j]=min(abs(sith2(i)-pk.th2));
    if dif<sith2tol
	idxsi=[idxsi;[j i]];
    end
end

if isverb==1
    fprintf('\n%s:\n', pk.fname);
    fprintf('contains %i peaks, of them:\n', length(pk.d));
    fprintf('    %i matched with Si peaks...\n', size(idxsi,1));
end

if ~isempty(idxsi)
    siobs=pk.th2(idxsi(:,1));
    sicorr=sith2(idxsi(:,2));
    pk=pkcorrect(pk, siobs, sicorr);
    if isverb==1
	fprintf('\n    Si 2theta correction:\n')
	fprintf('    obs      corr     corr-obs\n');
	fprintf('    %-9.3f%-9.3f%+-9.5f\n', [siobs sicorr sicorr-siobs]');
	fprintf('\n');
    end
    idxpk(idxsi(:,1))=0;
end
[dif,idx100]=min(abs(pk.th2-th2ref));
pkq2=(pk.d(idx100)./pk.d).^2;
%now remove the impurity peaks...
idxrm=[];
jpk=[];
for i=idxpk(idxpk~=0)
    [dif,j]=min(abs(pkq2(i)-q2));
    if dif>q2tol
	idxrm=[idxrm i];
    else
	jpk=[jpk j];
    end
end
idxpk(idxrm)=0;
idxpk=idxpk(idxpk~=0);
if isverb==1
    fprintf('    %i peaks matched with perovskite pattern:\n', length(jpk))
    fprintf('        %.4f\n', pk.th2(idxpk))
    fprintf('    %i peaks removed as impurities...\n', length(idxrm));
    fprintf('        %.4f\n', pk.th2(idxrm))
end
phkl=phkl(jpk,:);
thr=pk.th2(idxpk)/2*pi/180;
al=pk.d(idxpk).*sqrt(sum(phkl.^2,2));
x=cos(thr).^2 .* (1./sin(thr) + 1./thr);
[u,v,ignore,stda]=linreg(x,al);
a=v;
if isverb==1
    cla;plot(x,al,'*',[0;x],u*[0;x]+v);
elseif isverb==2
    s1=sprintf('TITLE  %s %s\n', pk.fname, pk.desc);
    s2=sprintf('CRYSTL F M -3 M  %.4f/\n', 2*a);
    s3=sprintf('CONDIT DS CUA1 /\n');
    if ~isempty(idxsi)
	simeas=zeros(1+idxsi(end,2)-idxsi(1,2),1);
	simeas(1+idxsi(:,2)-idxsi(1,2))=pk0.th2(idxsi(:,1));
	s4=sprintf('STNDRD SI %s/\n', sprintf('%.4f ', simeas));
    else
	s4='';
    end
    s5=sprintf('  %-4i%-4i%-4i%6.4f\n', [2*phkl pk0.th2(idxpk)]');
    if nargout==0
	disp([s1 s2 s3 s4 s5])
    else
	out=[s1 s2 s3 s4 s5];
    end
    return
end
out=a;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pkc=pkcorrect(pk,th2old,th2new)
pkc=pk;
L=length(th2old);
switch(L)
   case 0,
      return;
   case 1,     
      pkc.th2=pkc.th2+th2new-th2old;
   otherwise,  
      il=(pkc.th2<=th2old(1));
      ih=(pkc.th2>=th2old(end));
      im=(~il) & (~ih);
      pkc.th2(im)=interp1(th2old, th2new, pkc.th2(im));
      %pkc.th2(il)=pkc.th2(il)+th2new(1)-th2old(1);
      %pkc.th2(ih)=pkc.th2(ih)+th2new(end)-th2old(end);
      pkc.th2(il)=(th2new(2)-th2new(1))/(th2old(2)-th2old(1))*...
        	  (pkc.th2(il)-th2old(1)) + th2new(1);
      pkc.th2(ih)=(th2new(end)-th2new(end-1))/(th2old(end)-th2old(end-1))*...
        	  (pkc.th2(ih)-th2old(end-1)) + th2new(end-1);
end
pkc.d=th2d(pkc.th2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pkc=pkrm(pk, iout)
pkc=pk;
pkc.th2(iout)=[];
pkc.d(iout)=[];
pkc.irel(iout)=[];
pkc.icps(iout)=[];
pkc.fwhm(iout)=[];
