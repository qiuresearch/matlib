function ok = savepng(hf, pngfile)
%        ok = savepng(hf, pngfile)
% save figure "hf" to PNG file "pngfile"
%

if nargin < 1
   help savepng
   return
end

%
if ischar(hf)
  hf = evalin('caller',  hf);
end

if strcmpi(get(hf(1), 'Type'), 'axes')
   f_tmp = figure('visible', 'off');
   hf = copyobj(hf, f_tmp);
   hf = f_tmp;
   legend show; legend boxoff
end

% print
print(hf, '-dpng', '-noui',  pngfile);
disp(sprintf('Saving figure into PNG file: %s', pngfile))

if exist('f_tmp');
   close(f_tmp)
end

