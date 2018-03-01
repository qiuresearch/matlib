function res = rgfit(data, range)
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
if nargin==0;
    help rgfit
    return;
end
verbose =1;
if ( nargin > 1) % Use full range if no limit given.
   i_min = locate(data(:,1), range(1));
   i_max = locate(data(:,1), range(2));
   data = data(i_min:i_max, :);
end

[num_rows, num_cols] = size(data);
if (num_rows < 3)
   showinfo('Not enough points in selected Q range, abort!');
   res.rg=[NaN, NaN];
   res.i0= [NaN, NaN];
   return
end

% convert to Guinier representation
data(:,1) = data(:,1) .* data(:,1);
i_negative = find(data(:,2) <= 0);
if ~isempty(i_negative)
   data(i_negative,2) = NaN;
end
data(:,2) = log(data(:,2));

% Fit a straight line to the data using lin_reg

% dy is set using: d/dy(y) = dy/y
switch num_cols
   case 2
      dy = ones(length(data(:,2)),1);
      data(:,3) = dy;
   case 3
      dy = data(:,3)./exp(data(:,2));
      data(:,3) = dy;
   otherwise
      dy = data(:,4)./exp(data(:,2));
      data(:,4) = dy;
end
[x, covar, chi2] = linfit_reg(data(:,1),data(:,2), dy);
% use algebra method if 'linreg' gives warning
if isnan(x(1))
   showinfo('linfit_reg failed, try algebra method, error bar incorrect!');
   [x, covar, chi2] = linfit_alg(data(:,1), data(:,2), dy);
end

% Extract the fit parameters in terms of the Guinier fit.
% x(1) = -Rg^2/3, x(2) = log(Io), 
% covar(1,1) = var(x(1));  covar(2,2) = var(x(2));
rg = sqrt( -3 * x(1,1)); 
rg_error = sqrt(covar(1,1))*1.5/rg;
i0 = exp(x(2,1)); i0_error = sqrt(covar(2,2))*i0;

% Generate the fit
y_fit =  x(1,1)*data(:,1) + x(2,1);
fit = [ [0 ; data(:,1)], [x(2,1); y_fit] ];

% Bundle all the information into the res
res.rg = [rg, rg_error];
res.i0 = [i0, i0_error];
res.data = data;
res.fit  = fit;
res.chi2 = chi2;
