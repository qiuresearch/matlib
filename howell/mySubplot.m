% --- Usage:
%        mySubplot
%
% --- Purpose:
%        plots each iteration of plot commands in a new subplot of
%        the same figure.  It will always use 3 columns of
%        subplots.  The default is two rows but can be changed
%        using maxSubplot
%
% --- Parameter(s):
%        maxSubplot - maxSubplot/3 = number of rows to be used
%        (will round to the nearest value of 3 since it always uses
%        3 columns)
%
% --- Return(s): 
%
% --- Example(s):
%        maxSubplot = 9;
%        for i = 1:30
%          mySubplot
%          hold all
%          plot(x1,y1)
%          plot(x2,y2)
%          plot(x3,y3)
%        end
%
% --- Code:
%        if exist('maxSubplot','var')
%            maxSubplot = 3 * round (maxSubplot/3);
%        else
%            maxSubplot = 6;
%        end
%            
%        if 0 == mod(i-1,maxSubplot)
%            figure
%        end
%        subplot(maxSubplot/3,3,mod(i-1,maxSubplot)+1)
%      
% $Id: mySubplot.m,v 1.1 2013/05/06 19:00:16 schowell Exp $

if exist('maxSubplot','var')
    maxSubplot = 3 * round (maxSubplot/3);
else
    maxSubplot = 6;
end
    
if 0 == mod(i-1,maxSubplot)
    figure
end
subplot(maxSubplot/3,3,mod(i-1,maxSubplot)+1)