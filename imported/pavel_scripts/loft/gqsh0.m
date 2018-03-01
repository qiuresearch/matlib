function gqsh0(arg, guiflag)
%GQSH0      GUI quick showing of data files...
%    GQSH0 directory_name [replace]
%    replace option will clear figure for any
%    new selection

if nargin==0
    arg='';
    gqsh_replace_flag=0;
elseif nargin==1
    if strncmp(arg, 'replace', length(arg)) & exist(arg)~=2
	gqsh_replace_flag=1;
	arg='';
    else
	gqsh_replace_flag=0;
    end
else
    switch(guiflag)
	case 'plotselected',
	plotselected;
	return;
	otherwise,
	if strncmp(guiflag, 'replace', length(guiflag))
	    gqsh_replace_flag=1;
	end
    end
end
warning off
if exist(arg)==7 
    argdir=[arg '\'];
elseif exist(arg)==2
    plotfile(arg)
    return;
elseif any(arg=='\') | any(arg=='/' | any(arg==':'))
    i=max(find(arg=='\' | arg=='/' | arg==':'));
    argdir=arg(1:i);
    arg=arg(i+1:length(arg));
else
    argdir=cd;
end
warning on
argdir=strrep(argdir,'/','\');
if argdir(end)~='\'
    argdir=[argdir '\'];
end
orgdir=cd;
cd(argdir);
d=dir(arg);
cd(orgdir);
if isempty(d)
    disp('File not found');
    return
end

%remove directories...
isd=cat(1,d.isdir);
d=d(~isd);
if isempty(d)
    return
end
%sort by extensions
names=sortrows(char(d.name));
ext=setstr(' '*ones(size(names)));
m=size(names,2);
[i,j]=find(names=='.');
for a=1:length(i)
    ext(i(a),1:m-j(a))=names(i(a),(j(a)+1):m);
end
[ext,i]=sortrows(ext);
names=names(i,:);
if strncmp(names(1,:),'..',2)
    names(1,:)=[];
    ext(1,:)=[];
end
%update directory list
[ffig, hlb]=getgqshhandles;
figure(ffig)
s.gqsh_replace_flag=gqsh_replace_flag;
set(ffig, 'Name', upper(argdir),'userdata',s);
set(hlb, 'string', lower(names), 'value', 1)
plotselected;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotselected
%plot if called from listbox
[ffig, hlb]=getgqshhandles;
argdir=get(ffig,'Name');
s=get(ffig,'userdata');
i=get(hlb, 'Value');
argname=get(hlb,'string');
argname=[argdir deblank(argname(i,:))];
pfig=findobj('type','figure');
pfig=pfig(pfig~=ffig);
if isempty(pfig)
    pfig=figure;
else
    figure(pfig(1));
end
plotfile(argname,s.gqsh_replace_flag);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotfile(filename,gqsh_replace_flag)
%this one does the job...
if nargin==1
    gqsh_replace_flag=0;
end
if gqsh_replace_flag
    clf;
end
idot=find(filename=='.');
if isempty(idot)
    ext='';
else
    idot=idot(end);
    ext=filename(idot+1:end);
end
switch(ext)
    case 'pol', shpol(filename);
    case 'raw', shraw(filename);
    case 'pks', data=rpks(filename);
		pkplt(data);
		ind=max([0 find(filename=='\' | filename=='/')]);
		filename=filename(ind+1:end);
		filename=strrep(filename,'_','\_');
		title([filename ', ' data.desc]);
    case {'ted','lcr'}, 
		shted(filename);
    case 'fed', shfed(filename);
    case 'm',	run(filename(1:idot-1));
    case {'dat','asc'},
		[data,head]=rhead(filename);
		if ~isempty(findstr(head,'eps1'))
		    shted(filename);
		else
		    if(size(data,2)>1 & min(size(data)>1))
			plot(data(:,1),data(:,2));
		    else
			plot(data);
		    end
		    filename=strrep(filename,'\','\\');
		    filename=strrep(filename,'_','\_');
		    title(filename);
		end
    otherwise,  reset(cla);
		text(.5,.5,'Don''t know how to plot this file',...
		    'HorizontalAlignment','Center','FontSize',14,...
		    'Color','r');
		filename=strrep(filename,'\','\\');
		filename=strrep(filename,'_','\_');
		title(filename);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ffig, hlb]=getgqshhandles
%find object handles or create objects...
hhmode = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');
ffig=findobj('type','figure','tag','gqsh0 file figure');
set(0,'showhiddenhandles',hhmode);
if isempty(ffig)
    ffig=figure('units','normalized','IntegerHandle','off',...
	'position',[0.0050    0.4083    0.13    0.5500],...
	'menubar','none','tag','gqsh0 file figure','menubar','none',...
	'numbertitle','off','HandleVisibility','off');
    set(ffig,'units','default');
end
hlb=findobj(ffig,'type','uicontrol','tag','file list box');
if isempty(hlb)
    hlb=uicontrol('parent',ffig,'style','listbox','units','normalized',...
	'position',[0 0 1 .95], 'tag', 'file list box',...
	'callback','gqsh0(0,''plotselected'')' );
end
