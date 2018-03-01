function b = titlestr(a)
% TITLESTR Convert a string with underscores to a string that can be
%   displayed in figures without recognizing underscores as subscript
%   flags.

if ~ischar(a)
    error('Invalid input argument.');
end
b = a;
c = findstr(a,'_');
for i = length(c):-1:1;
    b = [b(1:c(i)-1),'\',b(c(i):end)];
end
    
    
