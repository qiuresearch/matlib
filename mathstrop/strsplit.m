function result = strsplit(str, delimiter, varargin)
%STRSPLIT Split string into pieces.
%
%   STRSPLIT(SPLITSTR, STR, OPTION) splits the string STR at every occurrence
%   of SPLITSTR and returns the result as a cell array of strings.  By default,
%   SPLITSTR is not included in the output.
%
%   STRSPLIT(SPLITSTR, STR, OPTION) can be used to control how SPLITSTR is
%   included in the output.  If OPTION is 'include', SPLITSTR will be included
%   as a separate string.  If OPTION is 'append', SPLITSTR will be appended to
%   each output string, as if the input string was split at the position right
%   after the occurrence SPLITSTR.  If OPTION is 'omit', SPLITSTR will not be
%   included in the output.

%   Author:      Peter J. Acklam
%   Time-stamp:  2004-09-22 08:48:01 +0200
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

% 1) handle input parameters and set up default behaviors
   nargsin = nargin;
   error(nargchk(1, 3, nargsin));
   if (nargsin < 2)
     delimiter = ' ';
   end
   omit = 1;
   preserve_null = 0;
   
   parse_varargin(varargin);
   
% 2) find the appearance of the delimitor in the string first
   len_delimiter = length(delimiter);
   
   index_delimiter = strfind(str, delimiter);
   num_cells = length(index_delimiter);
   if (num_cells == 0)    % Return if no occurance found
     result = {str};
     return
   end

% 3) patch the    
   result=repmat({}, num_cells+1);

   if (omit == 1)
     i_offset = len_delimiter;
   else
     i_offset = 0;
   end
   
   index_delimiter = [-len_delimiter+1, index_delimiter, length(str)+1];

   for i_cell =1:(num_cells+1)
     result{i_cell} = str(index_delimiter(i_cell)+i_offset: ...
                          index_delimiter(i_cell+1)-1       );
     
   end

   if (preserve_null == 0)
     result = cellempty(result);
   end
   
