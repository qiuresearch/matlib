function hplot = cryst_peaks_show(peakdata, yrange, varargin)
% peakdata is supposed to be [h,k,l,Q]

%if isempty(varargin)
[num_rows, num_cols] = size(peakdata);

for i=1:num_rows
   plot([peakdata(i,4), peakdata(i,4)], yrange, 'b-');
   text(peakdata(i,4), yrange(1), sprintf('[%i%i%i]',peakdata(i,1), ...
                                          peakdata(i,2), peakdata(i,3)), ...
        'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top', varargin{:});
end
