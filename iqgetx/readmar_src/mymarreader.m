function im_matrix=mymarreader(varargin)
%   mymarreader can directly read mar345 data file, and output image matrix.
%
%   mymarreader(FILENAME)          reads the mar345 data file FILENAME with extension .mar2300,
%                                  and the image will show automatically.
%
%   mymarreader(FILENAME, OUTPUT)   reads the mar345 data file FILENAME with extension .mar2300,
%                                   and save the image as the image file OUTPUT.

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
        im2 = reshape(im, sqrt(im_y), sqrt(im_y));
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
    


