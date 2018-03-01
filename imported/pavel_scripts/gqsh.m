function o_fl=gqsh(varargin)
%GQSH     quick plot and search of data files
%    GQSH [files] [?P1] [!P2] [-r] [-u] [-a]
%    shows dialog box with files, whose description 
%    matches pattern P1 and does not contain P2, case ignored
%    -a   add matching files to those already listed
%    -r   cleares figure upon each replot
%    creates a file desript.ion which contains and desriptions
%    -u   forces update of descript.ion
%    FILES=GQSH  returns found files as a cell array
%    GQSH file   quickly plot the data file
%
%    Examples:
%    gqsh  *raw *pks  ?PSW20
%    gqsh  *ted ?'30z p2' -r


% constants and defaults
gc.dfile='descript.ion';
gc.figy=120;	%gqsh figure size in pixels
gc.ift={'.xls', '.zip', '.swp', '.dll', '.exe', '.gz', '.bz2' ...
    '.arj', '.lnk', '.obj', '.o', '.com'};
gc.ifn={gc.dfile, 'gqsh.m', 'tags'};
g_.rflag=0;
aflag=0;
needsupdate=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the simplest case:
if nargin==1 & exist(varargin{1},'file')
    [i1,name,ext]= fileparts(varargin{1});
    if ~(  any(strcmpi(name, gc.ifn)) | any(strcmpi(ext, gc.ift))  )
	plotfile(varargin{1}, g_);
    end
    return;
end
fn=[];	% file name
pp={}; np=0;	% positive pattern with length
pn={}; nn=0;	% negative pattern with length
gc.arg=strrep(cd, '\', '/');
if gc.arg(end)~='/'
    gc.arg(end+1)='/';
end
gc.argc=0; sep='';
for i=1:nargin
    arg=varargin{i};
    if strmatch('?', arg)
	np=np+1;
	pp{np}=arg(2:end);
    elseif strmatch('!', arg)
	nn=nn+1;
	pn{nn}=arg(2:end);
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
	gc.argc=gc.argc+1;
	x=dir(arg);
	fn=[fn; x ];
	gc.arg=[gc.arg sep arg];
	sep=';';
    end
end
if gc.argc==0
    if np+nn > 0
	gc.arg='*';
	gc.argc=1;
	fn=dir;
    else
	gc.arg= '';
	aflag=1;
	fn=dir('file_that_does_not_exist');
    end
end
for i=1:np
    gc.arg=[gc.arg ' ?' pp{i} ];
end
for i=1:nn
    gc.arg=[gc.arg ' !' pn{i} ];
end
pp=lower(pp);
pn=lower(pn);

%remove directories...
isd=cat(1,fn.isdir);
fn=fn(~isd);
%sort by extensions
names=sort(lower({fn.name}'));
ext=names;
for i=1:length(ext)
    [i1,i2,ext{i}]= fileparts(names{i});
end
[ext,i]=sort(ext);
names=names(i);
if length(names)
    if strncmp(names{1},'..',2)
	names(1)=[];
	ext(1)=[];
    end
    if isempty(names{1})
	names(1)=[];
	ext(1)=[];
    end
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
	    break;
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
elseif gc.argc > 0
    needsupdate=1;
end
if needsupdate
    d.name={}; d.desc={};
    out={}; outnames={};
    fprintf( 'updating descriptions...\ndatdesc * > %s\n', gc.dfile);
    [s,r]=dos('bash -c "datdesc *"');
    fou=fopen(gc.dfile, 'wt');
    if fou ~= -1
	fwrite(fou, r);
	fclose(fou);
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
if gc.argc==0
    s_ffig = get(ffig, 'Name');
    if isempty(s_ffig)
	s_ffig = 'GQSH';
    end
else
    s_ffig = gc.arg;
    figure(ffig)
end
set(ffig, 'Name', s_ffig, 'UserData', g_);
out0 = get(hlb, 'String');
outnames0 = get(hlb, 'UserData');
if isempty(out0)
    out0 = {}; outnames0 = {};
end
if aflag
    out = {out0{:}, out{:}};
    outnames = {outnames0{:}, outnames{:}};
end
if isempty(out)
    s_hlb='';
    if gc.argc>0
	s_hlb='No Match';
    end
    set(hlb, 'string', s_hlb, 'style', 'text',...
	'HorizontalAlignment', 'left', 'UserData', out)
else
    set(hlb, 'string', out, 'style', 'listbox', 'value', 1, ...
	    'UserData', outnames)
end
if nargout
    o_fl = outnames';
end
if gc.argc>0
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
% pfig=findobj('type','figure');
% pfig=pfig(pfig~=ffig);
% if isempty(pfig)
%     pfig=figure;
% else
%     figure(pfig(1));
% end
plotfile(outnames{i}, g_);
% figure(ffig)
% set(ffig, 'CurrentObject', hlb)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotfile(filename, g_)
%this one does the job...
[i1,name,ext]= fileparts(filename);
st='';
hplt=[];
if g_.rflag
    clf
end
%get line number of this plot
if ~ishold
    nplt=1;
else
    nplt=length(findobj(gca,'type', 'line', 'Visible', 'on')) + 1;
end
switch(lower(ext))
case '.raw', shraw(filename);
case '.pks', data=rpks(filename);
	    pkplt(data);
	    st=[filename ', ' data.desc];
case '.m',  run(name);
case {'.gsas','.gdat'},
	    [th, y, ignore, desc] = rgsas(filename);
	    hplt = plot(th,y);
	    st=[filename ', ' desc];
otherwise,  %dummy loop so we can give it a break
	for i_ignore=1:1
	    %try to identify the file
	    fin=fopen(filename, 'rt');
	    ln{1}=fgetl(fin);
	    %charge files
	    if any( strcmp(ln{1}, {'CHARGE', 'PIEZO'}) );
		fclose(fin);
		shpol(filename);
		break;
	    %aids PDF file
	    elseif length(ln{1})==80 & ...
		ln{1}(80)=='1' & any(ln{1}(79)=='AMOTHRCX')
		fclose(fin);
		data = raids(filename);
		if nplt > 1
		    imx = max(ylim);
		    hplt = pkplt(data, 'n', imx);
		else
		    hplt = pkplt(data);
		end
		break;
	    end
	    %mted file
	    for i=2:4;
		ln{i}=fgetl(fin);
	    end
	    if strmatch(sprintf('f:\t'), ln{3}) & strmatch('Sample', ln{4})
		fclose(fin);
		shted(filename);
		break;
	    end
	    %mfed file
	    if ( strmatch('f ', ln{3}) & sum(findstr(ln{3}, ' D')) ) | ...
	       ( strmatch('f ', ln{4}) & sum(findstr(ln{4}, ' D')) )
		fclose(fin);
		shfed(filename);
		break;
	    end
	    %old lcr-type file
	    for i=5:10;
		ln{i}=fgetl(fin);
	    end
	    if strcmp(ln{10}, 'TEMPMEAS');
		fclose(fin);
		shted(filename);
		break;
	    end
	    %guess as data file with header;
	    fseek(fin,0,'bof');
	    [data,head]=rhead(fin,0);
	    fclose(fin);
	    st=filename;
	    if prod(size(data)) < 2
		reset(cla);
		text(.5,.5,'Don''t know how to plot this file',...
		    'HorizontalAlignment','Center','FontSize',14,...
		    'Color','r');
	    elseif size(data,2)>1
		hplt = plot(data(:,1),data(:,2:end));
	    else
		hplt = plot(data);
	    end
	end
end
if nplt>1 & ~isempty(hplt)
    set(hplt, 'Color', ncol(nplt));
end
if ~isempty(st)
    %st=strrep(st,'_','\_');
    %st=strrep(st,'{','\{');
    %st=strrep(st,'}','\}');
    %st=strrep(st,'\','\\');
    title(st, 'Interpreter', 'none');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ffig, hlb]=getgqshhandles(gc)
%find object handles or create objects...
hhmode = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','off');
set(0,'showhiddenhandles','on');
ffig=findobj('type','figure','tag','gqsh file figure');
set(0,'showhiddenhandles',hhmode);
if isempty(ffig)
    cfig=gcf;
    pos=get(cfig, 'Position');
    pos=[pos(1) pos(2)-gc.figy-27 pos(3) gc.figy];
    if pos(2)<0, pos(2)=0; end
    ffig=figure('units','pixels','IntegerHandle','off',...
	'position', pos,'IntegerHandle','off', ...
	'menubar','none','tag','gqsh file figure','menubar','none',...
	'numbertitle','off','HandleVisibility','off');
    set(ffig,'units','default');
end
hlb=findobj(ffig,'type','uicontrol','tag','file list box');
if isempty(hlb)
    hlb=uicontrol('parent',ffig,'style','listbox','units','normalized',...
	'FontName','Lucida Console', 'FontSize', 9,...
	'position',[0 0 1 1], 'tag', 'file list box',...
	'callback','gqsh(''-cplotselected'')' );
end
