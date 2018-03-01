function o_fl=gqsh(varargin)
%GQSH     quick plot and search of data files
%    GQSH [files] [?P1] [!P2] [-r] [-u] [-a]
%    shows dialog box with files, whose description 
%    matches pattern P1 and does not contain P2, case ignored
%    -a   add matching files to those already listed
%    -r   cleares figure upon each replot
%    creates a file desript.ion which contains and desriptions
%    -u   forces complete update of descript.ion
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
gset.rflag=0;
gset.aflag=0;
gset.upall=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the simplest case:
if nargin==1 & exist(varargin{1},'file')
    [i1,name,ext]= fileparts(varargin{1});
    if ~(  any(strcmpi(name, gc.ifn)) | any(strcmpi(ext, gc.ift))  )
	plotfile(varargin{1}, g_);
    end
    return;
end
gc.fn={};	% file name
gc.fd={};	% file directory
gc.pp={}; gc.np=0;	% positive pattern with length
gc.pn={}; gc.nn=0;	% negative pattern with length
PWD = strrep(cd, '\', '/');
if PWD(end)~='/'
    PWD(end+1)='/';
end
gc.arg=PWD;
gc.argc=0; sep='';
for i=1:nargin
    arg=varargin{i};
    if strcmp('-cplotselected', arg)
	plotselected(gc);
	return
    elseif strmatch('?', arg)
	gc.np=gc.np+1;
	gc.pp{gc.np}=arg(2:end);
    elseif strmatch('!', arg)
	gc.nn=gc.nn+1;
	gc.pn{gc.nn}=arg(2:end);
    elseif strcmp('-a', arg)
	gset.aflag=1;
    elseif strcmp('-r', arg)
	gset.rflag=1;
    elseif strcmp('-u', arg)
	gset.upall=1;
    else
	gc.argc=gc.argc+1;
	gc.arg=[gc.arg sep arg];
	sep=';';
	%add to the file name structure
	xn=dir(arg);
	xn=xn(~cat(1,xn.isdir));
	gc.fn={gc.fn{:} {xn.name}};
	%add to the directory list
	xd = fileparts(arg);
	if isempty(xd) | ~exist('xd', 'dir')
	    xd = PWD;
	end
	xcd = cell(length(xn), 1);
	for i=1:length(xn)
	    xcd{i} = xd;
	end
	gc.fd = { gc.fd{:}; xcd{:} };
    end
end
if gc.argc==0
    if gc.np+gc.nn > 0
	gqsh('*', varargin{:});
	return
    else
	gc.arg= '';
	gset.aflag=1;
	gc.fn={};
	gc.fd ={};
    end
end
for i=1:gc.np
    gc.arg=[gc.arg ' ?' gc.pp{i} ];
end
for i=1:gc.nn
    gc.arg=[gc.arg ' !' gc.pn{i} ];
end
gc.pp=lower(gc.pp);
gc.pn=lower(gc.pn);

gc = gqshGetDescriptions(gc, gset);
gc = gqshMatchPattern(gc);
gc = gqshSort(gc);

function gc = gqshGetDescriptions(gc, gset)
%this adds extra field
% 'de'  file description

gc.de = cell(size(gc.fn));
c_cr=sprintf('\r'); c_nl=sprintf('\n');
todo = ones(size(gc.fn));
orgwd = cd;
while any(todo)
    cwd = find(todo); cwd = cwd(1);
    cwd = gc.fd{cwd(1)};
    idx = strcmpi(gc.fd, cwd);
    cd(cwd);
    cfn = gc.fn{idx}; %current file names
    cde = cell(size(cfn)); % current descriptions
    if gset.upall & exist(gc.dfile, 'file')
	delete(gc.dfile)
	fprintf( 'rebuilding descriptions in %s...\ndatdesc * > %s\n', ...
	    cwd, gc.dfile);
	s=dos([ 'datdesc * > ' gc.dfile ]);
    end
    clear d
    d.get = {};
    if exist(gc.dfile, 'file')
	[d.name, d.desc] = textread(gc.dfile,'%s%[^\n\r]');
	d.name=lower(d.name);
	for i=1:length(cfn)
	    j=strcmpi(cfn{i}, d.name);
	    if all(j==0)
		d.get = {d.get{:} d.name};
		d.gind = [d.gind;i];
	    else
		j=find(j); j=j(end);
		cde{i}=d.desc{j};
	    end
	end
    else
	d.get = cfn;
	d.gind = 1:length(cfn);
    end
    % take care of updating...
    if length(d.get) > 0  &  ~gset.upall
	rsp = [ tempname() '.rsp' ];
	dtmp = [ rsp(1:end-3) '.out' ];
	frsp = fopen(rsp, 'wt');
	for i=1:length(d.get)
	    fprintf('%s\n', d.get{i});
	end
	fclose(frsp);
	fprintf( 'updating descriptions...\ndatdesc - < @filelist\n');
	s=dos([ 'datdesc - < ' rsp ' > ' dtmp ]);
	fin = fopen(dtmp, 'rt');
	fou = fopen(gc.dfile, 'wat');
	if fou == -1
	    error(['unable to write ' gc.dfile])
	end
	fwrite(fou, fread(fin));
	fclose(fou);
	fclose(fin);
	[d.name, d.desc] = textread(dtmp, '%s%[^\n\r]');
	d.name=lower(d.name);
	%potialto
	for i=g.ind(:)'
	    j=strcmpi(cfn{i}, d.name);
	    if all(j==0)
		cde{i}='';
	    else
		j=find(j); j=j(end);
		cde{i}=d.desc{j};
	    end
	end
	delete(rsp); delete(dtmp); 
    end
    %now cde is resolved, so
    gc.de(idx) = cde;
    todo(idx) = 0;
end
cd(orgwd)
%end of function...


function gc = gqshMatchPattern(gc)
%this one keeps only entries that match pp pn patterns
ok = ones(size(gc.fn));
sa = [ char(gc.de) char(9*ok(:)) ];
M = size(sa,1);
N = size(sa,2);
st = sa'; st = st(:);
for ip=1:gc.np
    ok1 = 0*ok;
    k = findstr(st, gc.pp{ip});
    m = ceil( k/N );
    ok1(m) = 1;
    ok = ok & ok1
end
for in=1:gc.nn
    k = findstr(st, gc.pn{in});
    m = ceil( k/N );
    ok(m) = 0;
end
gc.fn=gc.fn(ok);
gc.fd=gc.fd(ok);
gc.de=gc.de(ok);

function gc = gqshSort(gc)
%adds extra field gc.fe for extensions

[gc.fn, i] = sort(gc.fn);
gc.fd=gc.fd(i);
gc.de=gc.de(i);

gc.fe = gc.fn;
for i = 1:length(gc.fe)
    [i1,i2,gc.fe{i}] = fileparts(gc.fn{i});
end
[gc.fe, i] = sort(lower(gc.fe));
names=sort(lower({gc.fns.name}'));
ext=names;
for i=1:length(ext)
    [i1,i2,ext{i}]= fileparts(names{i});
end
[ext,i]=sort(ext);
gc.fd=gc.fd(i);
gc.fn=gc.fn(i);
gc.de=gc.de(i);









%%% AQUI %%%
names=names(i);
% neviem naco to tu je
% if length(names)
%     if isempty(names{1})
% 	names(1)=[];
% 	ext(1)=[];
%     end
% end
j=[];
for i=1:length(names)
    if any(strcmpi(names{i}, gc.ifn)) | any(strcmpi(ext{i}, gc.ift))
	j=[j i];
    end
end
names(j)=[]; ext(j)=[];




	end
	if ok
	    g.desc={g.desc{:}, sprintf('%-15s %.63s', d.name{j}, d.desc{j})};
	    g.file={g.file{:}, d.name{j} };
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
set(ffig, 'Name', s_ffig, 'UserData', gset);
out0 = get(hlb, 'String');
outnames0 = get(hlb, 'UserData');
if isempty(out0)
    out0 = {}; outnames0 = {};
end
if gset.aflag
    g.desc = {out0{:}, g.desc{:}};
    g.file = {outnames0{:}, g.file{:}};
end
if isempty(g.desc)
    s_hlb='';
    if gc.argc>0
	s_hlb='No Match';
    end
    set(hlb, 'string', s_hlb, 'style', 'text',...
	'HorizontalAlignment', 'left', 'UserData', g.desc)
else
    set(hlb, 'string', g.desc, 'style', 'listbox', 'value', 1, ...
	    'UserData', g.file)
end
if nargout
    o_fl = g.file';
end
if gc.argc>0
end
%plotselected(gc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotselected(gc)
%plot if called from listbox
[ffig, hlb]=getgqshhandles(gc);
gset=get(ffig, 'UserData');
i=get(hlb, 'Value');
g.file=get(hlb,'UserData');
if isempty(g.file)
    return
end
pfig=findobj('type','figure');
pfig=pfig(pfig~=ffig);
if isempty(pfig)
    pfig=figure;
else
    figure(pfig(1));
end
plotfile(g.file{i}, gset);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotfile(filename, gset)
%this one does the job...
[i1,i2,ext]= fileparts(filename);
st='';
hplt=[];
if gset.rflag
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
case '.m',  run(filename(1:idot-1));
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
	    if strcmp(ln{1}, 'CHARGE');
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
