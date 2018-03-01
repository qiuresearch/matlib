function H=shraw(file,s,q)
%SHRAW     plot of XRD spectra from RAW file
%SHRAW(FILE[,S,Q])
%	   S is linestyle, Q normalization constant

%1998 by Pavol

Q=1;
if nargin==0
   file=''; s='';
elseif nargin==1
   s='';
end
if nargin==3
    Q=q;
    if isstr(Q)
	Q=sscanf(Q,'%f',1);
    end
    Q=Q(1);
end
if isstruct(file)
    th2=file.th2;
    I=file.y;
    desc=file.desc;
    ddtt=file.ddtt;
    file=file.fname;
else
    [th2,I,desc,ddtt,file] = rraw(file);
end
if isempty(file)
   return
end
h=plot(th2,I*Q,s);
%Now check, if it is first plot
if length(findobj(gca,'type','line'))==1
   xlabel('2{\theta}');
   ylabel('Int.');
   i=max([findstr(file,'\') findstr(file,'/')]);;
   if i
      file=file(i+1:length(file));
   end
   title([upper(file),', ',desc]);
   set(gca,'xminortick','on', 'XLim', th2([1 end]));
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
