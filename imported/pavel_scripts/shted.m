function H=shted(File, varargin)
%SHTED     plot mted data file
%H=SHTED(FILE, OPT1, OPT2 ...) or
%H=SHTED(RTED_STRUCT, OPT1, OPT2 ...)
%SHTED CUR  plots current running measurement
%OPTIONS can be specified in the following way
%   'e'        plot eps only
%   'd'        plot D only
%   'ed'       plot eps and D (default)
%   'e3:5'     plot 3:5 columns of eps
%   'sSTYLE'   use a different linestyle (see PLOT)
%   's1'       use the first color from current axis ColorOrder
%   'k'	       convert temperature to Kelvins
%   'pX'       power eps by X

%1998 by Pavol

rdesc='mted_output.tmp';        %descriptor file defined in mted.h

%defaults:
file='';
opt='ed';
style0='';
style='';
kelvin=0;
color=[];
pow=1;
if nargin>0
    file=File;
end
for i=1:length(varargin)
    curarg=varargin{i};
    if length(curarg)>0 & curarg(1)=='-'
	curarg(1)=[];
    end
    switch curarg(1)
    case {'e','d'},
	opt=curarg;
    case 'k',
	kelvin=1;
    case 's',
	style=curarg(2:end);
	style0=style;
	ind=find(style>'0' & style<='9');
	if length(ind)
	    colnum=sscanf(style(ind(1):end), '%i', 1);
	    color=ncol(colnum);
	    style(ind)='';
	end
    case 'p',
	[p0,cnt]=sscanf(curarg(2:end), '%f', 1);
	if cnt==1 & p0~=0
	    pow=p0;
	end
    otherwise,
	error(sprintf('Unknown option %s', curarg))
    end
end

ismeas=0;
%Take care of current measurement...
if isstr(file) & strcmp(file, 'cur') & exist('cur')~=2
    dname=['\\Compaq315\c\WINDOWS\TEMP\' rdesc];
    dfid=fopen(dname);
    if dfid==-1
       disp('Sorry, no measurement running...');
       return
    end
    file=fgetl(dfid);
    isdone=strcmp(fgetl(dfid),'done');
    fclose(dfid);
    if isdone
       delete(dname)
    end
    switch lower(file(1))
	case 'c', file=['\\Compaq315\c' file(3:end)];
	case 'd', file=['\\Compaq315\d' file(3:end)];
	case 'g', file=['\\Gateway325\c' file(3:end)];
    end
    ismeas=1;
end

warning off
if isstruct(file)
   t=file.t;
   e=file.k;
   d=file.d;
   f=file.f;
   desc=file.desc;
   file=file.fname;
else
   [t,e,d,f,desc,file]=rted(file);
   if isempty(file), return, end
end
warning on
i=max( find(file=='\' | file=='/') );
if i
   file=file(i+1:end);
end
if kelvin
    t=t+273.15;
end
e=e.^(pow);
if pow==1
    eytxt='{\epsilon_r}';
elseif pow==-1
    eytxt='1/{\epsilon_r}';
else
    eytxt=['{\epsilon_r^{' sprintf('%.3g',pow) '}}'];
end

he=[]; hd=[];
if ismeas
    delete(findobj(gcf,'type','line','tag','shtedcurline'));
end
firstplot=isempty(findobj(gca,'type','line')) |...
          strcmp(get(gca,'nextplot'),'replace');
if strcmp('ed', opt(1:min(2,end))) | strcmp('de', opt(1:min(2,end)))
   ecol=eval(opt(3:end),'[]');
   if isempty(ecol); ecol=1:size(e,2); end
   dcol=ecol;
   hax(1)=subplot(211);
   he=plot(t,e(:,ecol),style);
   if firstplot
       ylabel(eytxt)
       title(strrep([file ' ' desc],'_','\_'));
   end
   hax(2)=subplot(212);
   hd=plot(t,d(:,dcol),style);
   if firstplot
       ylabel('D');
       xlabel('T (°C)');
   end
elseif strcmp('e', opt(1:min(1,length(opt))))
   hax=gca;
   ecol=eval(opt(2:end),'[]');
   dcol=[];
   if isempty(ecol); ecol=1:size(e,2); end
   he=plot(t,e(:,ecol),style);
   if firstplot
      xlabel('T (°C)');
      ylabel(eytxt)
      title(strrep([file ' ' desc],'_','\_'));
   end
elseif strcmp('d', opt(1:min(1,length(opt))))
   hax=gca;
   dcol=eval(opt(2:end),'[]');
   ecol=[];
   if isempty(dcol); dcol=1:size(d,2); end
   hd=plot(t,d(:,dcol),style);
   if firstplot
      xlabel('T (°C)');
      ylabel('D')
      title(strrep([file ' ' desc],'_','\_'));
   end
else
   error(sprintf('Unknown option %s', opt)); 
end
set(hax, 'XMinorTick', 'on', 'YMinorTick', 'on');
if ~ismeas
   %set(hax, 'ygrid', 'on')
   mi=5*round(min(t)/5);
   mx=5*round(max(t)/5);
else
   set([he hd], 'tag', 'shtedcurline')
   hpb=findobj(gcf, 'type', 'uicontrol', 'tag', 'shtedPushButton');
   if isempty(hpb)
      set(gcf, 'toolbar', 'figure')
      hpb=uicontrol('Style', 'Pushbutton',...
		    'Units', 'Normalized',...
		    'Position', [.85 0 .15 .05],...
		    'String', 'Refresh',...
		    'tag', 'shtedPushButton');
   end
   scbk=['shted cur ' opt ' s' style0];
   if kelvin
      scbk=[scbk ' k'];
   end
   set(hpb, 'Callback', scbk);
   if isdone
      set(hpb, 'String', 'Finished!',... 
	       'Callback', 'delete(gcbo)');
   end
   mi=5*floor(min(t)/5);
   mx=5*ceil(max(t)/5);
end
if ~isempty(color)
    set([he hd], 'color',color);
else
    if isempty(style)
	colorinstyle=0;
    else
	colorinstyle=any(style=='y' | style=='m' | style=='c' |...
	    style=='r' | style=='g' | style=='b' | style=='w' | style=='k');
    end
    if ~colorinstyle
	colore=ncol(ecol);
	colord=ncol(dcol);
	for i=1:length(he)
	    set(he(i),'Color',colore(i,:))
	end
	for i=1:length(hd)
	    set(hd(i),'Color',colord(i,:))
	end
    end
end
if ~isequal(mi, mx)
   set(hax, 'XLim', [mi mx]);
end

if nargout>0
   H=[he hd];
else
   figure(gcf)
end
