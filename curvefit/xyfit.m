function fitres = xyfit(data, func_type, par_init, fitopts)
% --- Usage:
%        fitres = xyfit(data, func_type, par_init, fitopts)
% --- Purpose:
%    A general fitting program uses "lsqcurvefit" to fit curves and
%    get the uncertainties of the fitted parameters
%
%
% --- Parameter(s):
%    data --
%    func_type -- a string specifying which function to fit:
%     'linear':       y=par(1)*x+par(2);
%     'exponential':  y = par(1)*exp(par(2)*x) [+par(3)];
%     'gauss':        y =par(3)/par(2)/sqrt(2*pi)*exp(-0.5/par(2)/par(2)*(x-par(1)).^2)+ par(4);
%     'coreshell':    y=
%
% --- Return(s):
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: xyfit.m,v 1.8 2015/02/23 03:31:20 xqiu Exp $
%

verbose = 1;
% 1) initialize the variables

% get fitting options
fitopts_tmp = optimset('Display', 'notify-detailed', 'MaxIter', 500, 'Algorithm', ...
                       'trust-region-reflective', 'DerivativeCheck', ...
                       'off', 'Jacobian', 'off', 'DiffMinChange',1e-3); 
%'DiffMinChange', ...
%                       1e-18, 'DiffMaxChange', 1e-6, 'Tolx', 1e-7, ...
%                       'TolFun', 1e-9);
hf = eval(['@' func_type '_xyfit']);
if nargout(hf) == 1
    fitopts_tmp.Jacobian = 'off';
end
fitopts_tmp.lower = [];
fitopts_tmp.upper = [];
fitopts_tmp.plot = 0;

if exist('fitopts', 'var') && ~isempty(fitopts)
    fitopts = struct_assign(fitopts, fitopts_tmp, 'append', 1);
else
    fitopts = fitopts_tmp;
end

% get fitting data
fitres.data = data;
[num_rows, num_cols] = size(data);
switch num_cols % determine X value and the error bar
    case 1
        fitres.x0=1:rows;
        fitres.y0=reshape(data, 1, num_rows);
        fitres.dy0=linspace(1,1,num_rows);
    case 2
        fitres.x0=data(:,1);
        fitres.y0=data(:,2);
        fitres.dy0=linspace(1,1,num_rows)';
    case 3
        fitres.x0=data(:,1);
        fitres.y0=data(:,2);
        fitres.dy0=data(:,3);
    otherwise
        fitres.x0=data(:,1);
        fitres.y0=data(:,2);
        fitres.dy0=data(:,4);
end
if isfield(fitopts, 'xmin')
    i_min = locate(fitres.x0, fitopts.xmin);
else
    i_min = 1;
end
if isfield(fitopts, 'xmax')
    i_max = locate(fitres.x0, fitopts.xmax);
else
    i_max = num_rows;
end

fitres.x=fitres.x0(i_min:i_max);
fitres.y=fitres.y0(i_min:i_max);
fitres.dy=fitres.dy0(i_min:i_max);

x=fitres.x;
y=fitres.y;
dy=fitres.dy;

% get fitting function
eval(['fitres.fitfunc = @' func_type, '_xyfit;']);

% [fitres.par_names, fitres.par_init]=feval(fitres.fitfunc);
[fitres.par_names]=feval(fitres.fitfunc);
if exist('par_init', 'var') && ~isempty(par_init)
    fitres.par_init = par_init;
end
fitres.y_init=feval(fitres.fitfunc, fitres.par_init, x);

% check fit upper and lower bounds
if ~isempty(fitopts.upper)
    if (length(fitopts.upper) < length(fitres.par_init))
        showinfo('Not enough upper bound elements provided!', 'warning');
        fitopts.upper((length(fitopts.upper)+1):length(fitres.par_init)) = Inf;
    end
    fitres.par_init = min(fitopts.upper(1:length(fitres.par_init)), fitres.par_init);
end
if ~isempty(fitopts.lower)
    if (length(fitopts.lower) < length(fitres.par_init))
        showinfo('Not enough lower bound elements provided!', 'warning');
        fitopts.lower((length(fitopts.lower)+1):length(fitres.par_init)) = -Inf;
    end
    fitres.par_init = max(fitopts.lower(1:length(fitres.par_init)), fitres.par_init);
end

% 2) Do the fit

% normalize y by the weight, and pass dy as a additional parameter
% to fitfun, so that we are minimizing [(y-f(x))/weight]^2. In this
% case, the CHI**2 and Jacobian already normalized.

%if ~isempty(fitopts.upper) || ~isempty(fitopts.lower)
%    fitopts.LargeScale = 'on';
%    fitopts.Algorithm = 'trust-region-reflective';
%    fitopts.LevenbergMarquardt = 'off';
%end
% if there is upper or lower bounds, but the algorithm is not Trust-Region

if (~isempty(fitopts.upper) || ~isempty(fitopts.lower)) && ...
       ischar(fitopts.Algorithm) && ~strcmpi(fitopts.Algorithm, 'trust-region-reflective')
   [fitres.par_fit,  resnorm, residue, exitflag, output, lambda, ...
    jacobian] = lsqcurvefit(fitres.fitfunc, fitres.par_init, x, y./ ...
                            dy, [], [], fitopts, dy);
   
else
   [fitres.par_fit,  resnorm, residue, exitflag, output, lambda, ...
    jacobian] = lsqcurvefit(fitres.fitfunc, fitres.par_init, x, y./ ...
                            dy, fitopts.lower, fitopts.upper, fitopts, dy);
end

% find the uncertainties of the fitted parameters
fitres.chi2 = resnorm/(length(fitres.x)-length(fitres.par_init));
fitres.par_varcovar = inv(transpose(jacobian)*jacobian);
fitres.par_error = sqrt(diag(fitres.par_varcovar)*fitres.chi2);

% evaluate the fitted functional values
fitres.y_fit=feval(fitres.fitfunc, fitres.par_fit, x);
fitres.y0_fit=feval(fitres.fitfunc, fitres.par_fit, fitres.x0);

% plot
if (fitopts.plot == 1)
    clf; hold all
    errorbar(fitres.x0, fitres.y0, fitres.dy0, fitres.dy0);
    plot(fitres.x0, fitres.y0_fit);
end

% If fun returns a vector (matrix) of m components and x has length n,
% where n is the length of x0, then the Jacobian J is an m-by-n matrix
% where J(i,j) is the partial derivative of F(i) with respect to
% x(j). (Note that the Jacobian J is the transpose of the gradient of
% F.