function mf = makeframe(frame,geom,q)

% function mf = makeframe(frame[,geom,[q]])
%
% Takes the figure in the currently active window, quantifies
% it to use only q colors and then writes it 
% into a file __MovieD/<frame>. The size of the images defaults 
% to 240x192 pixels, unless width and height are specified
% in the optional vector geom. For best results, the user
% should make sure that all images are on the same scale, though 
% technically it is not necessary. For best compression, image
% sizes should be multiples of 8 (pixels).
%
% To create multiple movies in parallel, create a subdirectory 
% for each movie in which you execute the makeframe and makemovie
% commands.
%
% Internally, various intermediate files (all in __MovieD) are
% written and destroyed.
%
% See also makemovie.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% written by ALW 11/24/95                          %
% updated to Matlab 5 by Don Bovee 4/97            %
%                                                  %
%      modified by ALW, 05/15/98 for Win95 & NT    %
% last modified by ALW, 03/22/00 for Linux         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Site dependent settings -------------------------------------------------
%

packagedir = '/home/fs1/wiegmann/matlab/Movie/';

%
% No editing needed beyond this point ---------------------------------
%
% ---------------------------------------------------
% however, you may want to include your architecture
% and or system paths here.
% ---------------------------------------------------
comp = computer;
if    sum(comp(1:3) ~= 'ALP') & ...
      sum(comp(1:3) ~= 'SGI') & ...
      sum(comp(1:3) ~= 'HP7') & ...
      sum(comp(1:3) ~= 'SUN') & ...
      sum(comp(1:3) ~= 'SOL') & ...
      sum(comp(1:3) ~= 'PCW') & ...
      sum(comp(1:3) ~= 'LNX')
  disp('makeframe currently set up for SUN SPARC, SUN SOLARIS,')
  disp('Intel PCs (Win 95, NT, Linux), DEC ALPHA, SGI and HP only')
  mm = -1 ; error = -2;
  return
elseif sum(comp(1:3) == 'PCW')
  packagedir = pjtbxdir('tbx'); 
  pnmcut     = [packagedir,computer,'\pnmcut'];
  ppmtogif   = [packagedir,computer,'\ppmtogif'];
  ppmquant   = [packagedir,computer,'\ppmquant'];
  rm         = ['del '];
else
  if exist('q') ...
	& sum(comp(1:3) ~= 'SOL') ...
	& sum(comp(1:3) ~= 'SUN') ...
	& sum(comp(1:3) ~= 'ALP') ...
	& sum(comp(1:3) ~= 'HP7') ...
	& sum(comp(1:3) ~= 'LNX')
    disp (['Quantification not yet implemented for',comp]);
    q = 0;
  end
  pnmcut     = [packagedir,computer,'/pnmcut'];
  ppmtogif   = [packagedir,computer,'/ppmtogif'];
  ppmquant   = [packagedir,computer,'/ppmquant'];
  if exist('/usr/bin/rm')
    rm         = ['/usr/bin/rm ']; % let string end in space!
  elseif exist('/usr/ucb/rm')
    rm         = ['/usr/ucb/rm ']; % let string end in space!
  elseif exist('/bin/rm')
    rm         = ['/bin/rm ']; % let string end in space!
  else disp('Having trouble finding rm, proceed with fingers crossed')
    rm         = ['rm ']; 	   % let string end in space!
  end
end %if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% REALLY NO EDITING needed beyond this point ---------------------------------
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Mdir       = '__MovieD'; % NEED SAME as in makemovie.m
%was: if exist(Mdir) == 0, [s,w] = unix(['mkdir ',Mdir]); firstframe = 1; end; 
% Exist finds any __MovieD in the path, this works on CWD
firstframe = mkdir(Mdir) ==1;
eval(['cd ',Mdir]);

framest = num2str(frame);

% default, possible to input these
width = 240;
height= 192;

if exist('geom'),
  if (size(geom) ~= 2)
    disp(['makeframe: incorrect geometry input size ',...
	    num2str(size(geom))]);
    error = -4;
    eval(['cd ..']);
    unix([rm,' -R ',Mdir]);
    return
  else
    if geom(1) <= 0
      disp(['makeframe: incorrect geometry input (x non-positive): ',...
	      num2str(geom(1))]);
      error = -8;
      eval(['cd ..']);
      unix([rm,' -R ',Mdir]);
      return
    end
    if geom(2) <= 0
      disp(['makeframe: incorrect geometry input (y non-positive): ',...
	      num2str(geom(2))]);
      error = -8;
      eval(['cd ..']);
      unix([rm,' -R ',Mdir]);
      return
    end
  end
  width  = geom(1);
  height = geom(2);
end;
if ~exist('q')
  q = 0;
end

oldPaperUnits    = get(gcf,'PaperUnits');
oldPaperPosition = get(gcf,'PaperPosition'); 

set(gcf,'PaperUnits','points')
PaperSize        = get(gcf,'PaperSize'); %size needed in points
set(gcf,'PaperPosition',[0 PaperSize(2)-height width height])

%make MATLAB flush the event queue and draw the screen, then print
drawnow 
print -dppmraw image.ppm

%restore settings for current figure
set(gcf,'PaperUnits',   oldPaperUnits)
set(gcf,'PaperPosition',oldPaperPosition)

geom = [' 0 0 ',int2str(width),' ',int2str(height),' '];

if exist('firstframe') 
  save width width -ascii
  save height height -ascii
  [s,w] = unix(['echo "',num2str(width),'x',...
	  num2str(height),'" > firstframesize']);
  [s,w] = unix(['echo "',num2str(width),' ',...
	  num2str(height),'" > framesize']);
else
  [s,w] = unix(['echo "',num2str(width),' ',...
	  num2str(height),'" >> framesize']);
end

inf = [framest,'.ppm'];
outf = [framest];
if q
  [s,w] = unix([...
    ppmquant,' ',num2str(q),' image.ppm | ',  ...
    pnmcut,geom,' | ',...
    ppmtogif,' > ',outf]);
else
  [s,w] = unix([...
    pnmcut,geom,' image.ppm | ',...
    ppmtogif,' > ',outf]);
end
[s,w] = unix([rm,' image.ppm ', inf]);
cd ..
mf = 0;

