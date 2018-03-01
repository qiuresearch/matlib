function varargout = xyerror(varargin)
% --- Usage:
%        varargout = xyerror(varargin)
%
% --- Purpose:
%        generate an errorbar plot of a single data with varargin{2:end}
%         as plotting properties. Legend is automatially taken as the
%         variable name (if applicable).
% --- Parameter(s):
%        varargin - the first parameter must be the nxm data (m>=2)
%        the third column of the data is taken as the errorbars
%
% --- Return(s): 
%        varargout - the handle to the curve
% --- Example(s):
%
% $Id: xyerror.m,v 1.1 2013/05/17 15:02:28 schowell Exp $
%
if isempty(varargin)
   help xyplot
   return
end

% if data file names are passed as string or cell arrays
if iscell(varargin{1}) || ischar(varargin{1})
   datafiles = varargin{1};
   if ischar(datafiles)
      specdata = specdata_readfile(datafiles);
      xyerror(specdata.data);
   else
      hold all;
      for i=1:length(datafiles)
         specdata = specdata_readfile(datafiles{i});
         xyerror(specdata(1).data);
      end
   end
   legend(datafiles, 'interpreter', 'none');
   legend boxoff;
   return
end

if (length(varargin) > 1) % 2nd and higher inputs are plot options
   hl = errorbar(varargin{1}(:,1), varargin{1}(:,2), varargin{1}(:,3),varargin{2:end});
else
   hl = errorbar(varargin{1}(:,1), varargin{1}(:,2),varargin{1}(:,3));
   %dataname = strrep(inputname(1), '_', '-');
   %   if ~isempty(dataname)
   %   legend_add(hl, dataname);
   %end
end

if (nargout ~= 0)
   varargout{1} = hl;
end
