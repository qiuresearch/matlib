function varargout = iqfit_writesetup(siqfit, prefix, varargin)
%        varargout = iqfit_writesetup(siqfit, prefix, varargin)
% --- Purpose:
%    save the setup file
%
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: xypro_savesetup.m,v 1.1 2013/08/22 15:29:07 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

saveiq = 0;
parse_varargin(varargin);

% 2)

if ~exist('prefix', 'var') || isempty(prefix)
   prefix = 'iqfit_res';
end
setupfile = [prefix '.hst'];
iosetup = fopen(setupfile, 'w');

header{1} = ['# iqfit parameters written @ ', datestr(now)];
header{2} = ['# By program iqfit_writesetup.m'];
header{3} = '# Note: the line may be too long, but do NOT cut it!';
fprintf(iosetup, '%s\n', header{:});

% use the first one as the general hst
fprintf(iosetup, 'sOpt.normconst = %g;\n', siqfit(1).normconst);

fprintf(iosetup, ['#L num        prefix          Ion     n(mM)    Dmax(A)   ' ...
                  'mw    qmin     qmax    guinier        legend\n']);

for i = 1:length(siqfit)
   str = sprintf('%4i %20s %8.2f %8.4f %7.1f %7.1f %8.4f %8.4f  [%0g,%0g]  %s\n', i, ...
                 siqfit(i).prefix, siqfit(i).I, siqfit(i).n, ...
                 siqfit(i).dmax, siqfit(i).molweight, siqfit(i).qmin, ...
                 siqfit(i).qmax, siqfit(i).guinier_range(:), siqfit(i).title);

   fprintf(iosetup, str);

   if (saveiq == 1) % save data: I(Q), S(Q)
   end
end
fclose(iosetup);
showinfo(['successfully saved the iqfit parameters to <' setupfile '>']);
