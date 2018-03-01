function a = xlim(varargin)
%XLIM X limits.
%  XL = XLIM             gets the x limits of the current axes.
%  XLIM([XMIN XMAX]) or
%  XLIM [all] XMIN XMAX  sets the x limits.
%  XLMODE = XLIM('mode') gets the x limits mode.
%  XLIM(mode)            sets the x limits mode.
%                           (mode can be 'auto' or 'manual')
%  XLIM(AX,...)          uses vector of axes AX instead of current axes.
%  XLIM('all', ...)	  applies to all axes of the current figure.
%
%  XLIM sets or gets the XLim or XLimMode property of an axes.
%
%  See also PBASPECT, DASPECT, YLIM, ZLIM.

%  $Id: xlim.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lims=[];
hax=gca;
for i=1:length(varargin)
   arg=varargin{i};
   if isstr(arg)
       if i==1 & strcmp(arg, 'all')  %change all axis in gca
           hax=findobj(gcf, 'type', 'axes');
	   ileg=strcmp(get(hax,'tag'),'legend');
	   hax(ileg)=[];
       elseif strcmp(arg, 'auto') | strcmp(arg, 'manual')
           set(hax, 'xlimmode', arg);
           return;
       elseif strcmp(arg, 'mode')
	   a=get(hax, 'xlimmode');
	   return;
       else
	   x=eval(arg, '[]');
           lims=[lims x(:).'];
       end
   elseif i==1 & ishandle(arg)
       hfound=findobj(arg, 'flat', 'type', 'axes');
       if length(hfound)==prod(size(arg))
           hax=hfound;
       else
           lims=[lims arg(:).'];
       end
   else
       lims=[lims arg(:).'];
   end
end
lims=lims(1:min(2,end));

if length(lims)>0
    set(hax, 'xlim', lims)
end
if nargout>0 | length(lims)==0
    a=get(hax, 'xlim');
    if iscell(a)
	a=cat(1,a{:});
    end
end
