function mm = makemovie(framevec,title,fps,reps,movieformat)

% function mm = makemovie(framevec,title[,framespersec[,reps[,movieformat]]])
%
% makemovie takes the files __MovieD/<framevec(:)>.ppm (usually) created
% with makeframe and writes them either into a file <title>.mpg, or
% into a file <title>.gif. The first is an MPEG movie, the second a
% gif89a movie, with white background set transparent, framespersec 
% frames per second (default 10) and reps repetitions (default 1),
% viewable with NETSACPE or animate.
% 
% Selectable movieformats are 'gif', 'mpg' or 'all', movies are written 
% accordingly. On exit, the __MovieD and all files in it are removed. 
% 
% If called without arguments, makemovie returns the directory that the 
% movie package is installed in.
%
% To create multiple movies in parallel, create a subdirectory
% for each movie in which you execute the makeframe and makemovie
% commands.
%
% See also makeframe, moviedemo

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
% No more editing needed beyond this point ---------------------------------
%

% ---------------------------------------------------
% however, you may want to include your architecture
% and or system paths here.
% --------------------------------------------------
comp = computer;
if    sum(comp(1:3) ~= 'ALP') & ...
      sum(comp(1:3) ~= 'SGI') & ...
      sum(comp(1:3) ~= 'HP7') & ...
      sum(comp(1:3) ~= 'SUN') & ...
      sum(comp(1:3) ~= 'SOL') & ...
      sum(comp(1:3) ~= 'LNX') & ...
      sum(comp(1:3) ~= 'PCW')
  disp('makemovie currently set up for SUN SPARC, SUN SOLARIS,')
  disp('Intel PCs (Win 95, NT and Linux), DEC ALPHA, SGI and HP only')
  mm = -1 ; error = -2;
  return
  % windows differs from UNIX: \/, command names
elseif sum(comp(1:3) == 'PCW'), 
  packagedir = pjtbxdir('tbx');
  encoder    = [packagedir,computer,'\mpeg_encode ']; % -float_dct 
  merge      = [packagedir,computer,'\gifmerge -255,255,255 '];
  ppmtogif   = [packagedir,computer,'\ppmtogif '];
  giftopnm   = [packagedir,computer,'\giftopnm '];
  rm         = ['del  '];  % let string end in space!
  mv         = ['move '];  % let string end in space!
else
  encoder    = [packagedir,computer,'/mpeg_encode ']; % -float_dct 
  merge      = [packagedir,computer,'/gifmerge -255,255,255 '];
  ppmtogif   = [packagedir,computer,'/ppmtogif '];
  giftopnm   = [packagedir,computer,'/giftopnm '];
  if exist('/usr/bin/rm')
    rm         = ['/usr/bin/rm ']; % let string end in space!
  elseif exist('/bin/rm')
    rm         = ['/bin/rm ']; % let string end in space!
  elseif exist('/usr/ucb/rm')
    rm         = ['/usr/ucb/rm ']; % let string end in space!
  else disp('Having trouble finding rm, proceed with fingers crossed')
    rm         = ['rm ']; 	   % let string end in space!
  end
  if exist('/usr/bin/mv')
    mv         = ['/usr/bin/mv ']; % let string end in space!
  elseif exist('/bin/mv')
    mv         = ['/bin/mv ']; % let string end in space!
  elseif exist('/usr/ucb/mv')
    mv         = ['/usr/ucb/mv ']; % let string end in space!
  else disp('Having trouble finding mv, proceed with fingers crossed')
    mv         = ['mv ']; 	   % let string end in space!
  end
end %if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% REALLY NO EDITING needed beyond this point ---------------------------------
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0, mm = packagedir; return; end;
M1 = ['makemovie: error --- could not open movie directory.   '
      '           please run makeframe first                  '
      '           returning to calling routine, no movie made.'];

if exist('fps'), 
  if fps == 'all' | fps == 'gif' | fps == 'mpg',
    tmp = fps;
    if exist('reps')
      fps = reps;
      if exist('movieformat')
        reps = movieformat;
      end
    else
      fps = [];
    end
    movieformat = tmp;
  end
end

if exist('fps'), 
  delay = round(100/fps);
  if delay ~= 100/fps, 
    disp(['warning: requested frames per second ',...
	  num2str(fps),' changed to ',num2str(100/delay)])
  end
else delay = 10; 
end; 
if ~exist('reps'), 
  reps = 1; 
else tempreps = reps;
  reps = round(reps);
  if tempreps ~= reps
    disp(['warning: requested repetitions ',...
	  num2str(tempreps),' changed to ',num2str(reps)])    
  end; 
end
   
merge = [merge, ' -',num2str(delay),' -l',num2str(reps)];

Mdir   = '__MovieD';
mm     = 0; 
errors = 0;

framevec = framevec(:);
images   = size(framevec,1); 

patterncounter = images;
pattern        = '';
while patterncounter  > 18,
  pattern = [pattern,'IBBPBBPBBPBBPBBPBB'];
  patterncounter= patterncounter -18;
end
restpat = 'IBBPBBPBBPBBPBBPB';
pattern = [pattern,restpat(1:patterncounter-1),'I']; 

titleg  = [title,'.gif'];
title   = [title,'.mpg'];

if ~exist('movieformat'),
  movieformat = 'all';
else
  if movieformat ~= 'gif' & movieformat ~= 'mpg' & movieformat ~= 'all',
    error(['unknown format: ',movieformat])
  end
end

if movieformat == 'all' | movieformat == 'mpg',
  if size(dir(title),1)
    disp(['File ',title,' exists, '...
	  'is renamed to ',title,'.orig'])
    if size(dir([title,'.orig']),1)
      dos([rm,' ', title,'.orig']);
    end
    dos([mv,' ',title,' ',title,'.orig']);
  end
end

if movieformat == 'all' | movieformat == 'gif',  
  frames = '';
  for frame = framevec'
    framestr = num2str(frame);
    frames = [frames,' ',framestr];
  end % if
  if size(dir(titleg),1)
    disp(['File ',titleg,' exists, '...
	  'is renamed to ',titleg,'.orig'])
    if size(dir([titleg,'.orig']),1)
      dos([rm,' ', titleg,'.orig']);
    end
    dos([mv,' ',titleg,' ',titleg,'.orig']);
  end
end

eval(['cd ',Mdir],['errors = 1;']);
if errors == 1, 
  disp(M1); 
  return; 
end;

if movieformat == 'all' | movieformat == 'gif'
  [s,w] = dos([merge,' ',frames,' > ',titleg]);
  dos([mv, ' ',titleg,' ..']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The parameters for the MPEG movie are
% written (and could be changed) here!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if movieformat == 'all' |movieformat == 'mpg'
  load width
  load height
  fp = fopen('movie.par','w');
  fprintf(fp,'# parameter file for mpeg movie\n\n');
  fprintf(fp,'PATTERN              %s\n',pattern);
  fprintf(fp,'OUTPUT               %s\n\n',title);
  fprintf(fp,'YUV_SIZE             %dx%d\n\n',width,height);
  fprintf(fp,'BASE_FILE_FORMAT     PNM\n');
  fprintf(fp,'INPUT_CONVERT        %s *\n',giftopnm); 
  fprintf(fp,'GOP_SIZE             30\n');
  fprintf(fp,'SLICES_PER_FRAME     1\n\n');
  fprintf(fp,'INPUT_DIR            .\n\n');
  fprintf(fp,'INPUT                \n');
  for i = 1:images
    fprintf(fp,'%s\n',num2str(framevec(i)));
  end
  fprintf(fp,'END_INPUT            \n\n');
  fprintf(fp,'PIXEL                HALF\n');
  fprintf(fp,'RANGE                10\n\n');
  fprintf(fp,'PSEARCH_ALG          LOGARITHMIC\n');
  fprintf(fp,'BSEARCH_ALG          CROSS2\n\n');
  fprintf(fp,'IQSCALE              8\n');
  fprintf(fp,'PQSCALE              10\n');
  fprintf(fp,'BQSCALE              25\n\n');
  fprintf(fp,'REFERENCE_FRAME      DECODED\n');
  fprintf(fp,'FORCE_ENCODE_LAST_FRAME\n');
  fclose(fp);

  [s,w] = dos([encoder,' movie.par ']);
  dos([mv, ' ',title,' ..']);
end

% clean up __MovieD
if 1 == 0 % disable if desired for debugging puposes
  files = dir;
  for i = 1:size(files,1)
    if ~ files(i).isdir,
      dos([rm ,files(i).name]);
    end
  end;
  chdir('..') 
  dos(['rmdir ',Mdir]);
else 
  chdir('..') 
end











