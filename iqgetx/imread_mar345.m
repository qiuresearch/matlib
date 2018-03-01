function im_matrix=imread_mar345(varargin)
%   slurp_mar345 can directly read mar345 data file, and output image matrix.
%
%   slurp_mar345(FILENAME)          reads the mar345 data file FILENAME, and
%                                   the image will show automatically.
%
%   slurp_mar345(FILENAME, OUTPUT)  reads the mar345 data file FILENAME, and
%                                   save the image as the image file OUTPUT.

    if exist(varargin{1}, 'file')
        [pathstr,name,ext] = fileparts(varargin{1});
    else
        disp('Error using mymarreader');
        disp('1st argument must be a string of filename with extension .mar2300.');
        return;
    end
    if strcmp(ext, '.mar2300') 
        im = readmar(varargin{1});
        [im_x im_y] = size(im);
        im2 = reshape(im, sqrt(im_y), sqrt(im_y))';
        im_matrix = uint16(im2);
        if numel(varargin) == 2
            cmap = colormap(jet);
            imwrite(im2, cmap, varargin{2});
        end
    else
        disp('Error using mymarreader');
        disp('1st argument must be a string of filename with extension .mar2300.');
        return;
    end
end
