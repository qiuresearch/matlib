function [hsel,hrest]=geth(typ, Ind)
%GETH      smart mouse-based text or line objects selection
%[HSEL,HREST]=GETH('T[EXT]') or
%[HSEL,HREST]=GETH('L[INE]')
%   HSEL  - handles to selected objects
%   HREST - handles to objects not selected
%   click right mouse button to finish selecting
%HSEL=GETH('T[EXT]', 'ALL')  get all text objects
%HSEL=GETH('L[INE]', 1:3)  select last 3 line objects
%GETH T[EXT] IND  shows text objects indexes and does nothing

% 1997 by Pavol

types={'text', 'line'};

ind=[];
if nargin==0
    loopit=1;
    while loopit
	if wfbp~=1
	    return;
	end
	typ=get(gco,'type');
	if any(strmatch(typ, types))
	    loopit=0;
	    set(gco,'selected','on')
	end
    end
end
if nargin>1
    ind=Ind;
end

switch (typ),
case 't',	typ = 'text';
case 'l',	typ = 'line';
case { 'text', 'line' },	%do nothing
otherwise,
    error('type must be t[ext] or l[ine]');
end

set(0,'ShowHiddenHandles','on')
hall=findobj(gca, 'type', typ);
if isempty(hall)
    return;
end
set(0,'ShowHiddenHandles','off')

if sum(strcmp(ind,{'ind', 'idx', 'index'}))
    if any( strcmp(typ, {'line', 'l'}) )
	ht=zeros(size(hall));
	xl=get(gca,'xlim');
	yl=get(gca,'ylim');
	for i=1:length(hall)
	    h=hall(i);
	    x=get(h,'xdata');
	    y=get(h,'ydata');
	    idx=(x>=xl(1) & x<=xl(2) & y>=yl(1) & y<=yl(2));
	    if any(idx)
		x=x(idx); y=y(idx);
	    end
	    [ignore,j]=min(abs(x-((xl(2)-xl(1))*(i-.5)/length(hall)+xl(1))));
	    ht(i)=text(x(j),y(j), sprintf('%i', i), 'color', get(h,'color'));
	end
	set(ht,'VerticalAlignment', 'bottom')
	figure(gcf); pause
	delete(ht)
    elseif any( strcmp(typ, {'text', 't'}) )
	for i=1:length(hall)
	    s0{i}=get(hall(i),'string');
	    s1=s0{i};
            if iscell(s1)
               s1=s1{1}; 
            elseif size(s1,1)
               s1=s1(1,:);
            end
	    set(hall(i),'string',sprintf('^{%i)} %s', i, s1));
	end
	drawnow;
	figure(gcf);
	pause;
	for i=1:length(hall)
	    set(hall(i),'string',s0{i});
	end
    end
    return;
elseif strcmp(ind,'all')
    hsel=hall;
    hrest=[];
    return;
end

if isempty(ind)
    while 1==wfbp
	if any(gco==hall)
	    if strcmp(get(gco,'selected'), 'off')
		set(gco,'selected','on');
	    else
		set(gco,'selected','off');
	    end
	end
    end
    hsel=findobj(hall,'flat','selected','on');
    hrest=findobj(hall,'flat','selected','off');
    set(hsel,'selected','off')
else
    if isstr(ind)
	ind=eval(ind);
    end
    if all(ind==floor(abs(ind))) 
	ind(ind<1 | ind>length(hall))=[];
	hsel=hall(ind);
	hrest=hall;
	hrest(ind)=[];
    else
	error('IND must be vector of positive integers')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function button = wfbp
%WFBP   Replacement for WAITFORBUTTONPRESS that has no side effects.

fig = gcf;

% Now wait for that buttonpress, and check for error conditions
waserr = 0;
eval(['if nargout==0,', ...
      '   waitforbuttonpress,', ...
      'else,', ...
      '   keydown = waitforbuttonpress;',...
      'end' ], 'waserr = 1;');

if(waserr == 1)
   error('Interrupted');
end

if nargout>0
   if keydown
      char = get(fig, 'CurrentCharacter');
      button = abs(get(fig, 'CurrentCharacter'));
   else
      button = get(fig, 'SelectionType');
      if strcmp(button,'open')
         button = b(length(b));
      elseif strcmp(button,'normal')
         button = 1;
      elseif strcmp(button,'extend')
         button = 2;
      elseif strcmp(button,'alt')
         button = 3;
      else
         error('Invalid mouse selection.')
      end
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
