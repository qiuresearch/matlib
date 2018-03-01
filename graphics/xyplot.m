function varargout = xyplot(varargin)
% --- Usage:
%        varargout = xyplot(varargin)
%
% --- Purpose:
%        plot a single data with varargin{2:end} as plotting
%        properties. Legend is automatially taken as the variable name
%        (if applicable).
% --- Parameter(s):
%        varargin - the first parameter must be the nxm data (m>=2)
%
% --- Return(s): 
%        varargout - the handle to the curve
% --- Example(s):
%
% $Id: xyplot.m,v 1.8 2011-12-06 06:27:46 xqiu Exp $
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
      xyplot(specdata.data);
   else
      hold all;
      for i=1:length(datafiles)
         specdata = specdata_readfile(datafiles{i});
         xyplot(specdata(1).data);
      end
   end
   legend(datafiles, 'interpreter', 'none');
   legend boxoff;
   return
end

if (length(varargin) > 1) % 2nd and higher inputs are plot options
   hl = plot(varargin{1}(:,1), varargin{1}(:,2), varargin{2:end});
else
   hl = plot(varargin{1}(:,1), varargin{1}(:,2));
   %dataname = strrep(inputname(1), '_', '-');
   %   if ~isempty(dataname)
   %   legend_add(hl, dataname);
   %end
end

if (nargout ~= 0)
   varargout{1} = hl;
end
