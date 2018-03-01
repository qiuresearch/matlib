function gqsh(varargin)
%GQSH     quick plot and search of data files
%    GQSH [files] [-pP1] [-nP2] [-r] [-u] [-a]
%    shows dialog box with files, whose description 
%    matches PATTERN and does not contain P2, case is ignored
%    -a   add matching files to those already listed
%    -r   cleares figure upon each replot
%    creates a file desript.ion which contains and desriptions
%    -u   forces update of desript.ion
%
%    Examples:
%    gqsh  *raw *pks  -pPSW20
%    gqsh  *ted -p'30z p2' -r


% constants and defaults
gc.dfile='descript.ion';
gc.figy=120;	%gqsh figure size in pixels
gc.ift={'.xls', '.zip', '.swp', '.dll', '.exe', '.gz',...
    '.arj', '.lnk', '.obj', '.o'};
gc.ifn={gc.dfile, 'gqsh.m'};
g_.rflag=0;
aflag=0;
needsupdate=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fn=[];	% file name
pp={}; np=0;	% positive pattern with length
pn={}; nn=0;	% negative pattern with length
gc.arg=cd;
if gc.arg(end)~='\'
    gc.arg(end+1)='\';
end
j=length(gc.arg);
k=0; sep='';
for i=1:nargin
    arg=varargin{i};
    if strmatch('-p', arg)
	np=np+1;
	pp{np}=arg(3:end);
    elseif strmatch('-n', arg)
	nn=nn+1;
	pn{nn}=arg(3:end);
    elseif strcmp('-cplotselected', arg)
	plotselected(gc);
	return
    elseif strcmp('-a', arg)
	aflag=1;
    elseif strcmp('-r', arg)
	g_.rflag=1;
    elseif strcmp('-u', arg)
	needsupdate=1;
    else
	k=k+1;
	x=dir(arg);
	fn=[fn; x ];
	gc.arg=[gc.arg sep arg];
	sep=';';
    end
end
if k==0
    gc.arg=[gc.arg '*.*' ];
    fn=dir;
else
    gc.arg(j)='\';
end
for i=1:np
    gc.arg=[gc.arg ' -p' pp{i} ];
end
for i=1:nn
    gc.arg=[gc.arg ' -n' pn{i} ];
end
pp=lower(pp);
pn=lower(pn);

%remove directories...
isd=cat(1,fn.isdir);
fn=fn(~isd);
%sort by extensions
names=sort(cellstr(lower(char(fn.name))));
ext=names;
for i=1:length(ext)
    [i1,i2,ext{i}]= fileparts(names{i});
end
[ext,i]=sort(ext);
names=names(i);
if strncmp(names{1},'..',2)
    names(1)=[];
    ext(1)=[];
end
if isempty(names{1})
    names(1)=[];
    ext(1)=[];
end
j=[];
for i=1:length(names)
    if any(strcmpi(names{i}, gc.ifn)) | any(strcmpi(ext{i}, gc.ift))
	j=[j i];
    end
end
names(j)=[]; ext(j)=[];

%get file descriptions
out={}; outnames={};
if exist(gc.dfile)==2
    [d.name, d.desc] = textread(gc.dfile,'%s%[^\n\r]');
    d.name=lower(d.name);
    for i=1:length(names)
	j=strcmpi(names{i}, d.name);
	if all(j==0)
	    needsupdate=1;
	    break
	end
	j=find(j); j=j(1);
	%check pattern matching
	ok = 1;
	ip=1; while ok & ip<=np;
	    ok = ok & length(findstr(lower(d.desc{j}), pp{ip}));
	    ip=ip+1;
	end
	ip=1; while ok & ip<=nn;
	    ok = ok & ~length(findstr(lower(d.desc{j}), pn{ip}));
	    ip=ip+1;
	end
	if ok
	    out={out{:}, sprintf('%-15s %.63s', d.name{j}, d.desc{j})};
	    outnames={outnames{:}, d.name{j} };
	end
	%done
    end
else
    needsupdate=1;
end
if needsupdate
    d.name={}; d.desc={};
    out={}; outnames={};
    fprintf( 'updating descriptions...\ndatdesc * > %s\n', gc.dfile);
    [s,r]=dos('datdesc *');
    fid=fopen(gc.dfile, 'wt');
    if fid ~= -1
	fwrite(fid, r);
	fclose(fid);
    end
    c_cr=sprintf('\r'); c_nl=sprintf('\n');
    r(r==c_cr)='';
    inl=[0 find(r==c_nl)];
    for i=1:length(inl)-1
	s0=deblank(r(inl(i)+1:inl(i+1)-1));
	jb=find(s0==' '); jnb=find(s0~=' ');
	jnb=jnb(jnb>jb(1)); jnb=jnb(1);
	d.name{i}=lower(s0(1:jb(1)-1));
	d.desc{i}=s0(jnb:end);
    end
    for i=1:length(names)
	j=strcmpi(names{i}, d.name);
	%check pattern matching
	ok = 1;
	ip=1; while ok & ip<=np;
	    ok = ok & length(findstr(lower(d.desc{j}), pp{ip}));
	    ip=ip+1;
	end
	ip=1; while ok & ip<=nn;
	    ok = ok & ~length(findstr(lower(d.desc{j}), pn{ip}));
	    ip=ip+1;
	end
	if ok
	    out={out{:}, sprintf('%-15s %.63s', d.name{j}, d.desc{j})};
	    outnames={outnames{:}, d.name{j} };
	end
	%done
    end
end

%update directory list
[ffig, hlb]=getgqshhandles(gc);
figure(ffig)
set(ffig, 'Name', gc.arg, 'UserData', g_);
out0 = get(hlb, 'String');
outnames0 = get(hlb, 'UserData');
if isempty(outnames0)
    out0 = {};
end
if aflag
    out = {out0{:}, out{:}};
    outnames = {out0{:}, outnames{:}};
end
if isempty(out)
    set(hlb, 'string', 'No Match', 'style', 'text',...
	'HorizontalAlignment', 'left', 'UserData', out)
else
    set(hlb, 'string', out, 'style', 'listbox', 'value', 1, ...
	    'UserData', outnames)
end
%plotselected(gc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotselected(gc)
%plot if called from listbox
[ffig, hlb]=getgqshhandles(gc);
g_=get(ffig, 'UserData');
i=get(hlb, 'Value');
outnames=get(hlb,'UserData');
if isempty(outnames)
    return
end
pfig=findobj('type','figure');
pfig=pfig(pfig~=ffig);
if isempty(pfig)
    pfig=figure;
else
    figure(pfig(1));
end
plotfile(outnames{i}, g_);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotfile(filename, g_)
%this one does the job...
[i1,i2,ext]= fileparts(filename);
st='';
if g_.rflag
    clf
end
switch(ext)
    case '.pol', shpol(filename);
    case '.raw', shraw(filename);
    case '.pks', data=rpks(filename);
		pkplt(data);
		ind=max([0 find(filename=='\' | filename=='/')]);
		filename=filename(ind+1:end);
		st=[filename ', ' data.desc];
    case {'.ted','.lcr'},
		shted(filename);
    case '.fed', shfed(filename);
    case '.m',	run(filename(1:idot-1));
    case {'.dat','.asc'},
		[data,head]=rhead(filename);
		if ~isempty(findstr(head,'eps1'))
		    shted(filename);
		else
		    if(size(data,2)>1 & min(size(data)>1))
			plot(data(:,1),data(:,2));
		    else
			plot(data);
		    end
		    st=filename;
		end
    otherwise,  reset(cla);
		text(.5,.5,'Don''t know how to plot this file',...
		    'HorizontalAlignment','Center','FontSize',14,...
		    'Color','r');
		st=filename;
end
if ~isempty(st)
    st=strrep(st,'_','\_');
    st=strrep(st,'\','\\');
    st=strrep(st,'{','\{');
    st=strrep(st,'}','\}');
    title(st);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ffig, hlb]=getgqshhandles(gc)
%find object handles or create objects...
hhmode = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','off');
cfig=gcf;
set(0,'showhiddenhandles','on');
ffig=findobj('type','figure','tag','gqsh file figure');
set(0,'showhiddenhandles',hhmode);
if isempty(ffig)
    pos=get(cfig, 'Position');
    pos=[pos(1) pos(2)-gc.figy-27 pos(3) gc.figy];
    if pos(2)<0, pos(2)=0; end
    ffig=figure('units','pixels','IntegerHandle','off',...
	'position', pos,...
	'menubar','none','tag','gqsh file figure','menubar','none',...
	'numbertitle','off','HandleVisibility','off', 'Name', gc.arg);
    set(ffig,'units','default');
end
hlb=findobj(ffig,'type','uicontrol','tag','file list box');
if isempty(hlb)
    hlb=uicontrol('parent',ffig,'style','listbox','units','normalized',...
	'FontName','Lucida Console', 'FontSize', 9,...
	'position',[0 0 1 .95], 'tag', 'file list box',...
	'callback','gqsh(''-cplotselected'')' );
end
