function a=zlim(varargin)
%ZLIM Z limits.
%  ZL = ZLIM             gets the z limits of the current axes.
%  ZLIM([XMIN XMAX]) or
%  ZLIM [all] XMIN XMAX  sets the z limits.
%  ZLMODE = ZLIM('mode') gets the z limits mode.
%  ZLIM(mode)            sets the z limits mode.
%                           (mode can be 'auto' or 'manual')
%  ZLIM(AX,...)          uses vector of axes AX instead of current axes.
%  ZLIM('all', ...)	  applies to all axes of the current figure.
%
%  ZLIM sets or gets the ZLim or ZLimMode property of an axes.
%
%  See also PBASPECT, DASPECT, XLIM, YLIM.

% $Id: zlim.m 26 2007-02-27 22:45:38Z juhas $
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
           set(hax, 'zlimmode', arg);
           return;
       elseif strcmp(arg, 'mode')
	   a=get(hax, 'zlimmode');
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
    set(hax, 'zlim', lims)
end
if nargout>0 | length(lims)==0
    a=get(hax, 'zlim');
    if iscell(a)
	a=cat(1,a{:});
    end
end
