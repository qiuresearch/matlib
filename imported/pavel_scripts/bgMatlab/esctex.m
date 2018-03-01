function s2 = esctex( s )
%ESCTEX      escape tex control characters with backslashes
%  S1 = ESCTEX(S)
%
%  Example:
%    title(esctex('nice_data_file.dat'))

%  $Id: esctex.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TeXchars = '\^_{}%';
s2 = s;
for c = TeXchars
    s2 = strrep(s2, c, [ '\' c ]);
end
