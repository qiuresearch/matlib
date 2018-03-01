function s2 = esctex( s )
% ESCTEX   escape tex control characters with backslashes
%   S2 = ESCTEX(S)

texchars = '\^_{}%';
s2 = s;
for c = texchars
    s2 = strrep(s2, c, [ '\' c ]);
end
