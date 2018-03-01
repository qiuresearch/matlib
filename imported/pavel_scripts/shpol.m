function H=shpol(file,s)
%SHPOL     plot of polarization curver from RT66 system
%SHPOL(FILE[,S])
%	   S is a linestyle, add '0' (zero) to the S for pretty loop

%2000 by Pavol

pretty=0;
c_prat = 1/8;
if nargin==0
   file=''; s='';
elseif nargin==1
   s='';
end
if ~isstruct(file)
    dat=rpol(file);
    if exist('dat')~=1
	return
    end
else
    dat=file;
end
file=dat.fname;
if ~isempty(s) & any(s=='0')
    pretty=1;
    s(s=='0')='';
end
e=dat.e;
p=dat.p;
desc=dat.desc;
if pretty
    Npts=length(e);
    c_pn = round( Npts * c_prat );
    i1 = mod( ceil(-c_pn/2) + (0:c_pn-1), Npts ) + 1;
    i2 = mod( i1 + round( Npts/2 ) - 1, Npts ) + 1;
    em = e;
    pm = p;
    em([i1 i2]) = [];
    pm([i1 i2]) = [];
    e = e - mean( em );
    p = p - mean( pm );
    w = 2 - abs( -(c_pn-1)/2 : (c_pn-1)/2 )' / ((c_pn-1)/4);
    w(w>1) = 1;
    p(i1) = w .* (-1 * p(i2)) + (1-w) .* p(i1);
    % % original code
    % i1=1:floor(Npts/20);
    % i2=[floor(Npts*5/6):Npts i1(end)+1:Npts/6];
    % e(1)=e(end);
    % p(i1)=spline(e(i2),p(i2),e(i1));
    % %3 nove lajny
    % i3=floor(7/16*Npts):ceil(9/16*Npts);
    % i4=[ceil(Npts/4):i3(1) i3(end):floor(Npts*3/4)];
    % p(i3)=spline(e(i4),p(i4),e(i3));
    % %koniec 3 novych lajn
    % e=e-mean(e);
    % p=p-mean(p);
end
h=plot(e,p,s);
%Now check, if it is first plot
if length(findobj(gca,'type','line'))==1
   xlabel('E (kV/cm)');
   ylabel('P ({\mu}C/cm^2)');
   i=max([findstr(file,'\') findstr(file,'/')]);;
   if i
      file=file(i+1:end);
   end
   title(strrep([file ' ' desc],'_','\_'));
   set(gca,'xminortick','on', 'yminortick', 'on');
elseif isempty(s) | (all(s~='y') & all(s~='m') & all(s~='c') &...
       all(s~='r') & all(s~='g') & all(s~='b') & all(s~='w') & all(s~='k') )
   i=length(findobj(gca,'type','line'));
   set(h,'color',ncol(i));
end
if nargout>0
   H=h;
else
   figure(gcf)
end
