function result = buffer_mix(volume, target, buf1, buf2)
% --- Usage:
%        result = buffer_mix(volume, target, buf1, buf2)
% --- Purpose:
%        mix two solutions to get "volume" of "target"
%        concentration with concentration "buf1" and "buf2"
%        buffers. 
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: buffer_mix.m,v 1.1 2013/08/18 04:16:03 xqiu Exp $

% v1*buf1 + (volume-v1)*buf2 = volume*target
% vl*(buf1-buf2) = volume*(target-buf2)
v1 = volume*(target-buf2)/(buf1-buf2);
v2 = volume-v1;

disp(['buffer 1: ' num2str(v1) ' ul'])
disp(['buffer 2: ' num2str(v2) ' ul'])
