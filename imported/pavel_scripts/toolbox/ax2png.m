function ax2png(file, dim, varargin)
% ax2png(file, dim[, print_args])
% dim = [width height]

if isstr(dim)
    dim = eval(dim);
end
a0 = gca;
f = figure('visible','off');

a = copyobj(a0, f);
set(a, 'Units', 'inches', 'Position', [.55 .45 dim(1:2)])
set(f, 'Units', 'inches', 'PaperPosition', [.5 .5 dim(1:2)+[.75 .75]])
pa = {file, '-dpng', varargin{:} };
print(pa{:})
delete(f)
