function ax2png(file, dim, varargin)
% AX2PNG      export current axis to a PNG file
% AX2PNG(FILE, AXSIZE, P1, P2, ...)  AXSIZE=[WIDTH,HEIGTH] is an optional
%   argument for specifying the size of exported image in Inches
%   P1, P2  are optional arguments for the PRINT function
%
% Example:
%   ax2png('figure.png', [3,4], '-r300')
%   will export the current axis to figure.png with a size of
%   3 Inches x 4 Inches and resolution of 300 DPI
%
%   See also PRINT

if isstr(dim)
    dim = eval(dim);
end
a0 = gca;
f = figure('visible','off');

a = copyobj(a0, f);
set(a, 'Units', 'Inches', 'Position', [.55 .45 dim(1:2)])
set(f, 'Units', 'Inches', 'PaperPosition', [.5 .5 dim(1:2)+[.75 .75]])
pa = {file, '-dpng', varargin{:} };
print(pa{:})
close(f)
