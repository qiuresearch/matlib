function HL=shraws(varargin)
%SHRAWS    put several raws into 1 axis
%SHRAWS file1 file2 ... [-sub[i]] [-move[YS]] [-log|lin|sqrt]
%    -log|lin|sqrt  specifies the y-axis scale
%    -sub[i]  will use i-column subplot, for every file
%    -norm norms maximum intensity to 100
%    -move[YS] implies -norm and also shifts all plots by YS [100]

scale='lin';
howto='   ';
normit=0;
rawnames={};
nnames=0;
for i=1:length(varargin)
    carg=varargin{i};
    if isnumeric(carg)
	clen=prod(size(carg));
	for j=1:clen
	    rawnames{j+nnames}=sprintf('Z%05i.RAW', carg(j));
	end
    elseif carg(1)=='-'
	clen=0;
	carg(1)='';
	if strmatch(carg, {'lin', 'log', 'sqrt'}, 'exact')
	    scale=carg;
	elseif strmatch('sub', carg)
	    howto=carg;
	elseif strmatch('move', carg)
	    yshift = sscanf(carg(5:end), '%f', 1);
	    if isempty(yshift)
		yshift = 100;
	    end
	    howto = 'move';
	    normit = 1;
	elseif strcmp(carg, 'norm')
	    normit = 1;
	else
	    error(sprintf('Unknown switch -%s', carg));
	end
    else
	rawnames{1+nnames}=upper(carg);
	clen = 1;
    end
    nnames = nnames + clen;
end

%read the data
for i=1:nnames
    adat(i) = rraw(rawnames{i});
    if normit
	adat(i).y = 100 * adat(i).y / max(adat(i).y);
    end
end

hl=zeros(nnames,1);
if strcmp(howto(1:3),'sub')
   if length(howto)==3
      howto=[howto '1'];
   end
   subcols=sscanf(howto(4:end), '%i', 1);
   subrows=ceil(nnames/subcols);
   for i=1:nnames
      subplot(subrows, subcols, i);
      dat=adat(i);
      switch(scale)
	 case 'log',  dat.y=log10(dat.y); hl(i)=shraw(dat); ylabel('log(Int)')
	 case 'sqrt', dat.y=sqrt(dat.y); hl(i)=shraw(dat); ylabel('sqrt(Int)')
	 otherwise,   hl(i)=shraw(dat);
      end
   end
else
   orghold=ishold;
   if ~orghold
       cla; hold on;
   end
   t2min=inf;
   t2max=-inf;
   for i=1:nnames;
      dat=adat(i);
      switch(scale)
	 case 'log',  dat.y=log10(dat.y);
	 case 'sqrt', dat.y=sqrt(dat.y);
      end
      t2min=min(t2min,dat.th2(1));
      t2max=max(t2max,dat.th2(end));
      if strcmp(howto, 'move')
	  dat.y = dat.y + (nnames-i)*yshift;      
	  text(.025*(t2max-t2min)+t2min,(0.8+(nnames-i)) * yshift,...
		[dat.fname sprintf('\n') dat.desc], ...
		'VerticalAlignment', 'top', 'color', ncol(i));
      end
      hl(i)=plot(dat.th2,dat.y,'color',ncol(i));
   end
   if ~orghold
       hold off
   end
   %Now check, if these were first plots
   if length(findobj(gca,'type','line'))==nnames
      xlabel('2{\theta}');
      switch(scale)
	  case 'log',  ylabel('log(Int)')
	  case 'sqrt', ylabel('sqrt(Int)')
	  otherwise,   ylabel('Int')
      end
      set(gca,'xlim',[t2min t2max]);
      set(gca,'xminortick','on');
   if nnames==1
      file=rawnames{i};
      k=max([findstr(dat.fname,'\') findstr(dat.fname,'/')]);
      if k
         file=dat.fname(k+1:length(dat.fname));
      end
      title([upper(file),', ',dat.desc]);
      end
   end
end
if nargout>0
    HL=hl;
end
