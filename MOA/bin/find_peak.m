% function peak_data = Find_Peak( Data, q_range, mode);
%
%  A peak-finding function for X-ray powder data.
%  Data is a 2-column vector of  [q, I] form.
%  q_range is a 2-column vector of [q_low, q_high].
%  For each tuple of q_low(j),q_high(j), Find_Peaks looks through
%  Data in the range q_low to q_low in search of a relative maximum.
%  should it find one within the range it processes it as follows.
%   
%    Define the following elements of the peak_data class.
%           q_max = q-value with the maximum intensity
%           I_max = intensity at q_max
%           I_min_pos = For q > q_max the intensity drops to a local minimum value.
%           q_min_pos = q value corresponding to I_min_pos.
%           I_man_neg = For q < q_max the intensity drops to a local minimum value.
%           q_min_neg = q value corresponding to I_min_neg.
%           Full_Area = Integrated peak area from q_min_neg to q_min_pos.
%           Cap_Area = Integrated peak area within the FWHM of peak.
%           FWHM = maximum of FWHM on left and right sides.
%           description = a string describing the peak.
%
%   If there is no maximum in the range given then,
%          I_max= maximum intensity
%          Full_Area=Cap_Area=0
%          Everything else = NaN.
%
%  mode is an optional third parameter.
%  if mode = 'rough' then just grabs the highest point in the range.
%	Half_width will not be as accurate in this mode either.
%  if mode = 'quad' then does a quadratic fit to the points within 80% of the 
%  maximum.  Similarly, it does a linear fit to interpolate the halfwidth
%  default is 'quad'.

function peak_data = Find_Peak( Data, q_range, mode)

    if (nargin<3)
        mode='quad';
    end

for i=1: size(q_range,1) % step through each range.
   
   	% Load the relevant region of data into temp.
      temp=zeros(1,2); j = 1; k =1;
      while (j<=length(Data))&(Data(j,1)< q_range(i,1)) j=j+1; end;
      while (j<=length(Data))&(Data(j,1)< q_range(i,2)) 
       temp(k,:) = Data(j,:);
       k = k+1; j=j+1;   
      end
      
    % Locate the peak maximum
    [x,y] = real_max(temp,mode);
       peak_data(i).q_max=x;
       peak_data(i).I_max=y;
    
    if isnan(peak_data(i).q_max)
    Full_Area=0; Cap_Area=0;
    xnr=NaN; ynr=NaN; xnl=NaN; ynl=NaN; width=NaN; width_left=NaN; width_right=NaN;
    else
    % Locate the minima on the side of the maxima  
    [xnr,ynr]=slide_min(Data,x,+1,mode);
    [xnl,ynl]=slide_min(Data,x,-1,mode);
    
    % Calculate the FWHM values
    [width, width_left, width_right]=FWHM(Data,x,0.5*(y+ynl),0.5*(y+ynr));
    
    % Calculate the integrals
    [Full_Area, y_left, y_right] = integrate(Data,xnl,xnr);
    Full_Area= Full_Area - 0.5*(y_left+y_right)*(xnr-xnl);
    
    [Cap_Area, y_left, y_right] = integrate(Data,x-width_left, x+width_right);
    Cap_Area = Cap_Area - 0.5 *(y_left+y_right)*(width_left+width_right);   
    end   
    
    % Stuff results into class.
    peak_data(i).q_min_pos=xnr;
    peak_data(i).I_min_pos=ynr;
    peak_data(i).q_min_neg=xnl;
    peak_data(i).I_min_neg=ynl;
    peak_data(i).FWHM=width;
    peak_data(i).wl = width_left;
    peak_data(i).wr = width_right;
    peak_data(i).Full_Area=Full_Area;
    peak_data(i).Cap_Area=Cap_Area;
    peak_data(i).description='';
    
end


function [integral, y_left, y_right] = integrate(v, x_min, x_max)
% takes a set of points in the dual column vector v.
% integrates y.dx from x_min to x_max and returns value in integral
% returns value of function at x_min and x_max 

% Find start of region.
j_max=size(v,1);
j_min=1; while (j_min<j_max)&(v(j_min,1)<x_min) j_min=j_min+1;end
j=j_min+1;

integral=0;
% Do the main integral
while(j<j_max)&(v(j,1)<x_max)
       integral=integral+ v(j,2)*(v(j+1,1)-v(j-1,1))*0.5; 
       j=j+1;
end
j_max=j;

% Fix the ends.
integral=integral+ ( 0.5*( v(j_min,1)+v(j_min+1,1) ) - x_min )* v(j_min,2);
integral=integral+ ( x_max - 0.5*( v(j_max,1)+v(j_max+1,1) ) )* v(j_max,2);
temp=(x_min-v(j_min-1,1))/( v(j_min,1)-v(j_min-1,1) );
y_left = temp * v(j_min,2) + (1.0-temp)*v(j_min-1,2);
temp=(x_max-v(j_max,1))/( v(j_max+1,1)-v(j_max,1) );
y_right = temp * v(j_max+1,2) + (1.0-temp)*v(j_max,2);

function [width, width_left, width_right] = FWHM(v, x_max, y_left, y_right)
% takes a set of points in the dual column vector v.
%  starts from the value x_max
% proceeds to the left and right of x_max until the function equals y_left 
% and y_right.  
% calculates the two half-widths and returns the greater one.

% Get starting position
j_max=size(v,1);
j_start=1; while(v(j_start,1)<x_max)&(j_start<j_max) j_start=j_start+1; end

% Do Right hand
j_right=j_start+1;
while(v(j_right,2)>y_right) j_right=j_right+1; end
frac=(v(j_right-1,2)-y_right)/(v(j_right-1,2)-v(j_right,2));
if (frac>1)|(frac<0) frac=0.5; end;
width_right= frac*v(j_right,1) + (1-frac)*v(j_right-1,1) - x_max;

% Do Left Hand
j_left=j_start-1;
while(v(j_left,2)>y_left) j_left=j_left-1; end
frac=(v(j_left+1,2)-y_left)/(v(j_left+1,2)-v(j_left,2));
if (frac>1)|(frac<0) frac=0.5; end;
width_left= x_max -frac*v(j_left,1) - (1-frac)*v(j_left+1,1);

% Return greater FWHM
width=max(width_left, width_right);


function [x,y] = slide_min(v, x_max, sign, mode)
%  takes a set of points in the dual column vector v.
%  and starts from the value x=x_max.
%  if sign > 0 proceeds to x> x_max until a local minimum found.
%  if sign < 0 proceeds to x< x_max until a local minimum found.
%  if mode='rough' settles with nearest integer value of x and returns y
%  if mode='quad' does a quadratic fit of minimum and returns x,y pair.

    % get our starting point and direction right
    j_max=size(v,1)-1;
    if (sign>0) 
        sign=1; j=1; while (v(j,1)<=x_max)&(j<j_max) j=j+1; end; j=j+1;     
    else    
        sign = -1; j=j_max; while((v(j,1)>=x_max)&(j>1)) j=j-1; end; j=j-1;
    end
    
    % Find the Minimum
    while(j<j_max)&(j>2)&(v(j,2)>v(j+sign,2)) j=j+sign; end
    
    if strcmp(mode,'rough')
        x = v(j,1); y=v(j,2);
    elseif strcmp(mode,'quad')
        x1=v(j-sign,1)-v(j,1); y1=v(j-sign,2)-v(j,2);
        x2=v(j+sign,1)-v(j,1); y2=v(j+sign,2)-v(j,2);
        a=(y1*x2-x1*y2);
        b=(y1*x2*x2-y2*x1*x1);
        xmin= -0.5 * b / a;
        ymin = -a * xmin * xmin / (x1*x2*(x2-x1));
        x=xmin+v(j,1);
        y=ymin+v(j,2);
        
    end

function [x,y]= real_max(v, mode)
% takes a set of points in the dual column vector v.
% locates the maximum value x,y.  
% If no local maximum exists x set to NaN.
% If mode='rough' then integer value returned.
% If mode='quad' then points greater than 80% intensity are fitted to a 
% quadratic cap.

    if strcmp(mode,'rough')
     [Y,j] = max(v(:,2));
     if (j==1)|(j==size(v,1)) x= NaN ;y= Y; return;
     else 
        x = v(j,1) ; y = v(j,2); 	
     end
    end
    
    
    if strcmp(mode,'quad')
     % Find the maximum and minimum values.
     % If there is not a local maximum in range return immediately.
     [Imax,j] = max(v(:,2)); if (j==1)|(j==size(v,1)) x= NaN ;y= Imax;return;end
 
     Imin=min(v(:,2));      
     % Accumlate all the data within 20% of the peak.
     cutoff = 0.8 * Imax + 0.2*Imin; npoint = 0; k=j;
     while (k<=size(v,1))&(v(k,2)>cutoff)
                npoint=npoint+1;
                A(npoint,1)=1;A(npoint,2)=v(k,1);A(npoint,3)=v(k,1)*v(k,1);
                B(npoint)=v(k,2);
                k=k+1;
     end
     k=j-1;
     while (k>=1)&(v(k,2)>cutoff)
                npoint=npoint+1;
                A(npoint,1)=1;A(npoint,2)=v(k,1);A(npoint,3)=v(k,1)*v(k,1);
                B(npoint)=v(k,2);
                k=k-1;
     end
      
     % Fit the peak
          % 1 point only in peak data set
            if (npoint<2) x=A(1,2); y=B(1); 
          % 2 points in peak data set.  Just take average 
            elseif (npoint<3) 
                x=(A(1,2)+A(2,2))*0.5; y=0.5*(B(1)+B(2));  
          % 3 points or more.  Time to fit.  
            else	
              [y, j] = max(B); x = A(j,2);  % Set up an acceptable default.
              C = inv(A' * A) * A' * B'; 
	           if (abs(C(3))>0)
                         qtrial = -C(2)/(2.0*C(3));
                  if (( qtrial>min(A(:,2)) )&( qtrial < max(A(:,2)) )) 
                    Itrial = C(1) + C(2)*qtrial + C(3)*qtrial*qtrial;
                    x=qtrial; y=Itrial;
                  end 
               end
            end      
   
    end
           
            
 