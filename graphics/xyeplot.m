function varargout = xyeplot(x,y,e,varargin)
% --- Usage:
%        varargout = xyeplot(x,y,e,varargin)
% --- Purpose:
%        plot data with error bar
% --- Parameter(s):
%        x - nxm (m~=2) data matrix. If m=3, y=x(:,2), e=x(:,3). 
%                                    If m>=4, y=x(:,2), e=x(:,4)
%        y - optional
%        e - optional
%
%        varargin - 'aspect': 0.23 - ratio of the tee relative to
%                   error bar
% --- Return(s):
%        varargout - varargout{1}: handle to the data graphic object
%                    varargout{2}: handle to the error bar object
%
% --- Example(s):
%
% $Id: xyeplot.m,v 1.8 2014/02/27 14:14:42 schowell Exp $
%

verbose=1;
if (nargin < 1)
   fprintf('nargin == %d\n',nargin)
   help xyeplot
   return
end

aspect = 0.23; % the ratio of the tee relative to the error bar
parse_varargin(varargin);

xlog = 0;
if strcmpi(get(gca, 'XScale'), 'log')
   xlog = 1;
   aspect = 0.05;
end
ylog=0;
if strcmpi(get(gca, 'YScale'), 'log')
   ylog = 1;
end

% initialize the data

[num_rows, num_cols] = size(x);
if (num_rows == 1)  % if row major
   x=x';
   num_rows = num_cols;
   num_cols = 1;
end

switch num_cols
   case 1
      y=reshape(y, length(y),1);
      e=reshape(e, length(e),1);
   case 2
       display('using standard error');
      y=x(:,2);
      e=sqrt(abs(y));
      x=x(:,1);
   case 3
       display('using col 3 as error');
      y=x(:,2);
      e=x(:,3);
      x=x(:,1);
    otherwise
       display('using col 4 as errer');
      y=x(:,2);
      e=x(:,4);
      x=x(:,1);
end

if (length(x) ~= length(y)) || (length(y) ~= length(e))
   showinfo('Dimension mismatch, abort!');
   return
end

%
hold all
hd = plot(x,y);

% construct the error bar
x_lim = get(gca, 'XLim');
y_lim = get(gca, 'YLim');
%x_lim = [min(x), max(x)];
%y_lim = [min(y), max(y)];

xlog =1;

if (xlog == 0)
   width = e/(y_lim(2)-y_lim(1))*(x_lim(2)-x_lim(1))*aspect;
else
   width = x.*(e/(y_lim(2)-y_lim(1))*(x_lim(2)-x_lim(1))*aspect/29);
end

n = length(e)*9;
xdata(1:9:n) = x-width;
xdata(2:9:n) = x+width;
xdata(3:9:n) = nan;
xdata(4:9:n) = x;
xdata(5:9:n) = x;
xdata(6:9:n) = nan;
xdata(7:9:n) = x-width;
xdata(8:9:n) = x+width;
xdata(9:9:n) = nan;

ydata(1:9:n) = y-e;
ydata(2:9:n) = y-e;
ydata(3:9:n) = nan;
ydata(4:9:n) = y-e;
ydata(5:9:n) = y+e;
ydata(6:9:n) = nan;
ydata(7:9:n) = y+e;
ydata(8:9:n) = y+e;
ydata(9:9:n) = nan;

% plot it
he = plot(xdata, ydata, 'Color', get(hd, 'Color'));

switch nargout
   case 0
   case 1
      varargout{1} = hd;
   case 2
      varargout{1} = hd;
      varargout{2} = he;
   otherwise
end
