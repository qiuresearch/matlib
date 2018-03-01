function res = gyration_debye(data, range)
%        res = gyration(data, range)
% 
% Selects out data for which    - range(1) < q < range(2).
%                               - if no range then uses all data.
% Fits the data to the form,
%       log(I) = log(Io) - q^2 * Rg^2/3
%
% In res returns,
%       res.rg = [Rg, error]
%       res.i0 = [I(Q=0), error]
%       res.data = data fitted.  data(:,1)=q^2; data(:,2) = log(I)
%       res.fit  = curve-fit      fit(:,1)=q^2;  fit(:,2) = predicted log(I)
%       res.chi2 = 
%
% Dependencies - lin_reg

verbose =1;
if nargin > 1 % Use full range if no limit given.
   i_min = locate(data(:,1), range(1));
   i_max = locate(data(:,1), range(2));
   data = data(i_min:i_max, :);
end

[num_rows, num_cols] = size(data);
if (num_rows < 3)
   showinfo('Not enough points in selected Q range, abort!');
   res.rg=[NaN, NaN];
   return
end

fitres = xyfit(data, 'debyeRg', [50,data(1,2)]);

% Bundle all the information into the res (compatible with gyration.m)

res.rg = [fitres.par_fit(1), fitres.par_error(1)];
res.i0 = [fitres.par_fit(2), fitres.par_error(2)];
res.data = fitres.data;
res.fit = [fitres.x0, fitres.y0_fit];
res.chi2 = fitres.chi2;
