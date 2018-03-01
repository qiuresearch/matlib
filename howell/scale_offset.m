function [mt_data, scale, offset, X2] = scale_offset(in_data, rf_data, varargin)
%     """
%     determine the scale and/or offset to match the input data to the reference 
%     data by minimizing the X2 calculation
%     \chi^2 = \frac{1}{N_q-1}\sum_{i=1}^{N_q} \frac{\left[cI_{s_i}(Q) + I_c - I_{e_i}(Q)\right]^2}{\sigma_i^2(Q)}
%     
%     Parameters
%     ----------
%     in_data:
%         input data to match to the rf_data (should be Nx2 np.array)
%     rf_data:
%         reference data for matching the in_data (should be Nx3 np.array)
% 
%     Returns
%     -------
%     mt_data: version of in_data matched to the reference data
%     scale:   scale factor applied to the input data
%     offset:  offset applied to the input data
%     X2:      X^2 comparison between the reference data and matched input data
%     
%     See also
%     --------
%     match_poly, match_lstsq, scale
% 
%     """
%     $Id: scale_offset.m,v 1.1 2015/07/02 01:18:36 schowell Exp $
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
do_hist = 0;
scale = 0;
offset =0;
all=0;
parse_varargin(varargin);
if (scale == 0) && (offset == 0) && (all == 0)
   scale = 1;
end

% limit reference data to the region of the input data
if min(rf_data(:,1)) < min(in_data(:,1))
    rf_data = rf_data(rf_data(:,1) >= min(in_data(:,1)),:);
end
if max(rf_data(:,1)) > max(in_data(:,1))
    rf_data = rf_data(rf_data(:,1) <= max(in_data(:,1)),:);
end

in_data_int = [rf_data(:,1), interp1(in_data(:,1), in_data(:,2:end), rf_data(:,1))];
if exist('match_range','var')
     % backup the interpolated data
    if exist('keep_int', 'var')' in_data_int_bk = in_data_int'; end
    % 2) get the common range or use the X-ray
    [~, imin] = min(abs(rf_data(:,1)- match_range(1)));
    [~, imax] = min(abs(rf_data(:,1)- match_range(2)));
    rf_data = rf_data(imin:imax,:);
    in_data_int = in_data_int(imin:imax,:);
end

sigma2 = rf_data(:,3) .* rf_data(:,3);
a = sum( rf_data(:,2) ./ sigma2 );
b = sum( in_data_int(:,2) ./ sigma2 );
c = sum( 1 ./ sigma2 );
d = sum( rf_data(:,2) .* in_data_int(:,2) ./ sigma2 );
e = sum( in_data_int(:,2) .* in_data_int(:,2) ./ sigma2 );
if (all == 1) || ((scale ==1) && (offset == 1))
    offset = (a*e - b*d)/(c*e - b*b);
    scale = (c*d - b*a)/(c*e - b*b);
elseif (scale == 1)
    scale = d / e ;
    offset = 0;
else
    scale = 1;
    offset = (a - b) / c;
end

mt_data = [in_data(:,1), scale * in_data(:,2:end) + offset];
mt_data_int = [in_data_int(:,1), scale * in_data_int(:,2:end) + offset];
X2 = get_x2(rf_data, mt_data_int, 'do_hist', do_hist);
if exist('keep_int','var'); 
    if exist('match_range', 'var');
        mt_data = [in_data_int_bk(:,1), scale * in_data_int_bk(:,2:end) + offset];
    else
        mt_data = mt_data_int; 
    end
end