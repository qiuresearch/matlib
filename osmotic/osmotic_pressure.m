function pressure = osmotic_pressure(concen, pegtype, temperature, datasource)
% --- Usage:
%        pressure = osmotic_pressure(concen, pegtype, temperature, datasource)
% --- Purpose:
%        get the tabulated osmotic pressure.
%
% --- Parameter(s):
%        concen   - weight fraction of PEG
%        pegtype  - "PEG8K", 'PEG20K' ...
%        temperature - 20 (default)
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: osmotic_pressure.m,v 1.7 2014/08/06 15:24:04 xqiu Exp $
%

verbose = 1;

if ~exist('pegtype', 'var')
   pegtype = 'PEG8K';
end
if ~exist('temperature', 'var')
   temperature = 20; % in Celsius
end
if ~exist('datasource', 'var')
   datasource = 'default';
end

%
if strcmpi(upper(pegtype), 'PEG8K')
   switch upper(datasource)
      case 'DEFAULT'         % formula from Don Rau in 2008
         a = 5.0524318;
         b = 15.665571;
         c = -46.830966;
         d = 86.938468;
         e = -63.994989;
         switch temperature
            case 5
               a2 = -0.1820;
               b2 = 1.0609;
               c2 = -0.0037512;
            case 20
               a2 = 0;
               b2 = 1;
               c2 = 0;
            case 35
               a2 = 0.24453;
               b2 = 0.92118;
               c2 = 0.0048257;
            case 50
               a2 = 0.58531;
               b2 = 0.81549;
               c2 = 0.011244;
            otherwise
               exist_temps = [5, 20, 35, 50]; 
               itemp = locate(exist_temps, temperature);
               
               showinfo(['This temperature is not measured, so will be calculated based on ' ...
                         'yet!!! ']);
         end
         
         % calculate the pressure
         pressure = a+concen.*(b+concen.*(c+concen.*(d+e*concen)));
         pressure = a2+pressure.*(b2+c2*pressure);
      
      case 'NIH2013'  % the data from Don Rau on 01/25/2013
         a1=5.7818;
         a2=4.3391;
         a3=13.6354;
         a4=-50.4488;
         a5=47.6053;
         
         switch temperature
            case 25
               b1=0;
               b2=1;
               b3=0;
            case 20
               b1=-.0734916;
               b2=1.0240757;
               b3=-.00148241;
            otherwise
               showinfo(['This temperature is not measured']);
         end
         % 12/2012, from Don: Michel and Kaufman for peg8k temperature correction,
                  % particularly at high pressures (units in dyne/cm^2)
                  % Log(Pi(20o)) = -.0734916 + 1.0240757* log(Pi(25o)) - .00148241* log(Pi(25o))^2
         pressure=a1+a2*concen+a3*concen.^2+a4*concen.^3+a5*concen.^4;
         pressure=b1+b2*pressure+b3*pressure.^2;
         end

end

if strcmpi(upper(pegtype), 'PEG20K')
   switch upper(datasource)
      case 'DEFAULT'
         switch temperature
            case 20  % data from NIH website in 2011 (appear low at high [PEG])
               a = 1.57;
               b = 2.75;
               c = 0.21;
            case 25  % manually corrected from 20C data above
               a=1.57;
               b=2.75;
               c=0.216;
            otherwise
         end
         pressure = a+b*(concen*100).^c;
   
      case 'NIH2008'  % 09/27/2012: pressures are too low at >30% [PEG])
                      %This data was originally from Don Rau in 2008
         a =   5.068385;
         b =  11.515383;
         c = -13.958688;
         d = 0;
         e = 0;
         switch temperature
            case 20
               a2 = -0.073492;
               b2 =  1.024076;
               c2 = -0.0014824;
            case 25
               a2 = 0;
               b2 = 1;
               c2 = 0;
            otherwise
               showinfo('This temperature is not characterized yet!!!');
         end

         % calculate the pressure
         pressure = a+concen.*(b+concen.*(c+concen.*(d+e*concen)));
         pressure = a2+pressure.*(b2+c2*pressure);
      
      case 'NIH2013' % data from Don Rau on 01/25/2013
         a1=3.5225;
         a2=36.2823;
         a3=-153.0262;
         a4=323.828;
         a5=-258.1159;
         
         switch temperature
            case 25
               b1=0;
               b2=1;
               b3=0;
            case 20
               b1=-.0734916;
               b2=1.0240757;
               b3=-.00148241;
            otherwise
               showinfo(['This temperature is not measured']);
         end
         pressure=a1+a2*concen+a3*concen.^2+a4*concen.^3+a5*concen.^4;
         pressure=b1+b2*pressure+b3*pressure.^2;
         
   end
end % if strcmpi(upper(datatype, 'PEG20K');

% convert from log(dyne/cm^2) to log(Pascal)
pressure = pressure - 1;
