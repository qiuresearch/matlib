function data = roundsig(data, n);
% round to number of significant digits

factor = 10^(-ceil(log10(data))+n);
data = round(data*factor)/factor;
