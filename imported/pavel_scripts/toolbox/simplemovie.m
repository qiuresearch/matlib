% SIMLEMOVIE A basic example of how the movie package works.
%            type 'type smplemovie' to see the actual program.
%

% Originally written by ALW, 11/27/95
%
% Last modified by ALW 10/11/98

% use matlab's peak function to create single images, on a coarse grid

[X,Y,F] = peaks;
indx    = [1:2:size(X,1)];
indy    = [1:2:size(X,2)];
figure(1); clf;colormap('hot')

frames = 7;
for i = 1:frames;
  factor = cos((i-0.5)*pi/frames);
  surf(X(indx,indy),Y(indx,indy),factor*F(indx,indy));
  % This usually creates figures with MANY colors, at
  % least more than 256!
  shading interp
  axis([-3 3 -3 3 -7 7])
  axis off
  view([-1 -1 1])
  disp(['Creating frame ',num2str(i)]);
  % Create frames with 512 x 320
  % quantify the image to have only 256 colors,
  % the max allowed in the gif format.
  makeframe(i,[512,320],256); 
end

% make movie: create files demoq.gif, the gif movie
% has 5 frames per sec and 20 repetitions.

makemovie([1:frames,frames:-1:1],'demo',5,20,'all');

disp(' ')
disp('======================')
disp('done with simplemovie.')
disp('======================')
disp(' ')
disp('compare demo.gif and demo.mpg with the originals...')
