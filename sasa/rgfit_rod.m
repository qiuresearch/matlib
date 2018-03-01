function report = gyration_rod(data, range)
% function  report = gyration(Ival,range)
%
% Ival contains a scattering curve of I versus q.
%       q=Ival(:,1) ; I = Ival(:,2)
% Selects out data for which    - range(1) < q^2 < range(2).
%                               - if no range then uses all data.
% Fits the data to the form,
%       log(I) = log(Io) - q^2 * Rg^2/3
%
% In report returns,
%       report.Rg = Radius of gyration
%       report.Rg_error = Error in Radius of gyration.
%       report.Io = Peak Scattering Intensity
%       report.Io_error = Uncertainty in Io
%       report.data = data fitted.  data(:,1)=q^2 ; data(:,2) = log(I)
%       report.fit = curve-fit      fit(:,1)=q^2 ;  fit(:,2) = predicted log(I)
%
% Dependencies - lin_reg

if ( nargin > 1) % Use full range if no limit given.
   i_min = locate(data(:,1), range(1));
   i_max = locate(data(:,1), range(2));
   data = data(i_min:i_max, :);
end

% get guinner data
data = guinier_rod(data);
[num_rows, num_cols] = size(data);

% Fit a straight line to the data using lin_reg
dx = [ones(num_rows,1), data(:,1)];
dx = data(:,1);
[x, covar] = linfit_reg(dx,data(:,2));

% Extract the fit parameters in terms of the Guinier fit.
% x(1) = log(Io), x(2) = -Rg^2/2
% covar(1,1) = var(log(Io));  covar(2,2) = var(x(2));
i0 = exp(x(2)); i0_error = sqrt(covar(1,1))* i0;
rg = sqrt( -2 * x(1)); rg_error = sqrt(covar(2,2)) / rg;

% Generate the fit
y_fit = dx * x(1)+x(2);
fit = [ [0 ; dx], [x(2); y_fit] ];

% Bundle all the information into the report
report.rg = rg; report.rg_error = rg_error;
report.i0 = i0; report.i0_error = i0_error;
report.data = data;
report.fit  = fit ;
