function varname = str2varname(str)
% --- Usage:
%        
% --- Purpose:
%        
% --- Parameter(s):
%        
% --- Return(s):
%        
% --- Example(s):
%
% $Id: str2varname.m,v 1.1 2013/08/17 13:52:28 xqiu Exp $
%

% 1) check how is called
verbose = 1;

%
varname = strtrim(str);

varname = strrep(varname, ' ', '_');
varname = strrep(varname, '%', '_');
varname = strrep(varname, '#', '_');
varname = strrep(varname, '/', '_');
varname = strrep(varname, '-', '_');
varname = strrep(varname, '+', '');

if (varname(1) >= '0') && (varname(1) <= '9')
   varname = ['v' varname];   
end

