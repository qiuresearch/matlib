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

function report = gyration(data, range)

    if (nargin<2) % Use full range if no limit given.
        range(1)= min(data(:,1))^2-1;
        range(2)= max(data(:,1))^2+1;
    end
    
    % Select from data points within our range.
    sl=length(data);
    dp=0; fit_data(1,2)=0;
    for j=1:sl
        qs = data(j,1)*data(j,1);
        if ((qs>range(1))&(qs<range(2)))
        dp=dp+1; fit_data(dp,1)=qs; fit_data(dp,2)=log(data(j,2));    
        end    
    end
    
    % Check we have enough points within range to fit.
    if (dp<3)
        printf('Not enough points within range to fit');
        report.Rg=NaN; 
        return;
    end
    
    % Fit a straight line to the data using lin_reg
    dx = [ones(dp,1), fit_data(:,1)];
    y = fit_data(:,2);
    [x, covar] = lin_reg(dx,y);
    
    % Extract the fit parameters in terms of the Guinier fit.
    % x(1) = log(Io), x(2) = -Rg^2/3
    % covar(1,1) = var(log(Io));  covar(2,2) = var(x(2));
    Io = exp(x(1)); Io_error = sqrt(covar(1,1))* Io;
    Rg = sqrt( -3 * x(2)); Rg_error = sqrt(covar(2,2)) * 1.5 / Rg;
        
    % Generate the fit as well.
    y_fit = dx * x;
    fit = [ [0 ; dx(:,2)], [x(1); y_fit] ];
    
    % Bundle all the information into the report
    report.Rg = Rg; report.Rg_error = Rg_error;
    report.Io = Io; report.Io_error = Io_error;
    report.data = fit_data;
    report.fit  = fit ; 