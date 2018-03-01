function sam_concen = aes_getconcen(xlsdata, atomnames, varargin)

verbose = 1;
rawdata = 0;
row_range = 1:length(xlsdata.concen(:,1));
col_range = 1:length(xlsdata.concen(1,:));

parse_varargin(varargin);

% if atomnames are provided
if exist('atomnames', 'var')
    if ischar(atomnames)
        atomnames = {atomnames};
    end
    col_range = [];
    for i=1:length(atomnames)
        icol = find(strncmpi(atomnames{i}, xlsdata.atomnames, ...
                             length(atomnames{i})));
        if isempty(icol)
            showinfo(['No entries found for atom: ' atomnames{i}]);
            col_range(i) = 1;
        else
            col_range(i) = icol(end);
        end
    end
end

% return the array
if (rawdata == 0)
    sam_concen = [xlsdata.samx(row_range,1), xlsdata.concen(row_range, col_range)];
else
    sam_concen = [xlsdata.samx(row_range,1), xlsdata.data(row_range, col_range)];
end
