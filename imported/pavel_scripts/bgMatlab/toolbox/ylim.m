function a=ylim(varargin)
%YLIM Y limits.
%  YL = YLIM             gets the y limits of the current axes.
%  YLIM([XMIN XMAX]) or
%  YLIM [all] XMIN XMAX  sets the y limits.
%  YLMODE = YLIM('mode') gets the y limits mode.
%  YLIM(mode)            sets the y limits mode.
%                           (mode can be 'auto' or 'manual')
%  YLIM(AX,...)          uses vector of axes AX instead of current axes.
%  YLIM('all', ...)	  applies to all axes of the current figure.
%
%  YLIM sets or gets the YLim or YLimMode property of an axes.
%
%  See also PBASPECT, DASPECT, XLIM, ZLIM

%  $Id: ylim.m 26 2007-02-27 22:45:38Z juhas $
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
           set(hax, 'ylimmode', arg);
           return;
       elseif strcmp(arg, 'mode')
	   a=get(hax, 'ylimmode');
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
    set(hax, 'ylim', lims)
end
if nargout>0 | length(lims)==0
    a=get(hax, 'ylim');
    if iscell(a)
	a=cat(1,a{:});
    end
end
