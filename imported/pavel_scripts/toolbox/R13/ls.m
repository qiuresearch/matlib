function l=ls(varargin)
%LS List directory.
%   LS displays the results of the 'ls' command on UNIX.  You can
%   pass any flags to LS as well that your operating system supports.
%   On UNIX, ls returns a \n delimited string of file names.
%
%   On all other platforms, LS executes DIR and takes at most one input
%   argument. 
%
%   See also DIR.

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision: 5.13 $  $Date: 2000/06/01 01:25:35 $

if isunix
    if nargin == 0
        [s,l] = unix('ls');
    else
        if iscellstr(varargin)
            args = strcat(varargin,{' '});
        else
            error('Inputs must be strings.');
        end
        [s,l] = unix(['ls ', args{:}]);
    end
else
   c = computer;
   if strcmp(c(1:2),'PC') | strcmp(c(1:3),'MAC') | isvms
      if nargin == 0
         args = '';
      elseif nargin == 1
         args = varargin{1};
      else
         error('Too many input arguments.')
      end
      if nargout == 0
	  dir( args )
      else
	  l = dir( args );
      end
   end
end
