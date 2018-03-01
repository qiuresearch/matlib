%  function result = mask(imag, range)
%
%  Lets User edit existing mask, or makes a fresh mask.
%
%  Displays image 'imag' using existing default mask, MaskD.
%  User can,
%           r - select region of interest with mouse
%           z - zoom in or out.
%           e - mask out data in roi
%           i - include data in roi
%           n - negate mask
%           f - make a fresh mask.
%           d - make the presently displayed mask the default mask, MaskD.    
%           q - quit giving mask in 'result'
% When the user is happy with their mask, they quit and the mask is returned in
% result.
% If 'range' is specified, this is the intensity range used but it is optional.
% If no image is put in a blank mask the same size as the correction files is generated.
% If MaskD is a different size to imag then a blank mask is used as the template.
%
%  Dependencies - axes2pix.m, intline.m, roipoly1_mod1.m, show_special.m

function result = mask(imag, range)
global Intensity_Map; global MaskD;

%  Return a blank mask if no image is supplied.  ie. include all points.
if (nargin==0) result = uint8(ones(size(Intensity_Map))); return; end;

% Set the range of intensities by hand if no range given.
if (nargin==1) 
   range = 0;
   range(1)=double(min(imag(:)));
   range(2)=double(max(imag(:)));
end

% Initialize MaskD before starting mouse loop.
% If MaskD is inapproriate for imag then reset immediately.
MaskStore = MaskD;
if (size(MaskD,1)~=size(imag,1)) | (size(MaskD,2)~=size(imag,2))    
    MaskD = uint8(ones(size(imag)));
end

% Initialize Region of interest before starting Mouse loop
MaskElement=uint8(zeros(size(imag)));
polygon_x=0;polygon_y=0;

% Initialize Zoomed Viewing range, arange.
arange = [0, size(imag,2), 0, size(imag,1)];
show_image(imag,range,arange,polygon_x,polygon_y);

% Print out User Commands
instructions;

command=0;  % Ascii number of command.
haxes = gca;
% Keep adding or subtracting bits from the mask until told to quit.
while( command ~= 81)
 
   axes(haxes);
   [x,y,command]=ginput(1); % Get a command. 
   if isempty(command) command = 0; end;
   
   if (command == 1); command = command + 81; end
   if (command == 2); command = command + 67; end
   if (command == 3); command = 81; end
   
   fprintf(1, 'command: %i\n', command);
   switch command
        case {82,114}  % Select a region of interest - r,R
           disp('Select a polygon region now...')
            [Mask_Element,polygon_x,polygon_y] = roipoly_mod1(imag,range,arange);
            hold on; plot(polygon_x,polygon_y,'w'); hold off;
            
        case {69,101}  % Eliminate the region of interest - e,E
            MaskD = bitand(MaskD, uint8(1.0-double(Mask_Element)));
            show_image(imag,range,arange,polygon_x,polygon_y);
            
        case {73,105}  % Include the region of interest - i,I.
            MaskD = bitor(MaskD,Mask_Element);
            show_image(imag,range,arange,polygon_x,polygon_y);
         
        case {78,110}  % Negate the present mask - n,N
            MaskD = uint8(1.0 - double(MaskD));  
            show_image(imag,range,arange,polygon_x,polygon_y);
          
        case {70,102}  % Make a fresh mask - f,F
            MaskD = uint8(ones(size(imag)));
            MaskElement=uint8(zeros(size(imag)));
            polygon_x=0;polygon_y=0;
            arange = [0, size(imag,2), 0, size(imag,1)];
            show_image(imag,range,arange,polygon_x,polygon_y);
            
        case {90,122}  % Zoom in or out of present image - z,Z
            fprintf(1,'\n **********************************\n');
            fprintf(1,'Zooming  -  Use the microscope feature on Figure.\n');
            fprintf(1,'Press a Key to Return to Regular Operation\n');
            fprintf(1,'************************************ \n');
            arange = [0, size(imag,2), 0, size(imag,1)];
            show_image(imag,range,arange,polygon_x,polygon_y);  
            zoom on; pause; zoom reset
            arange = axis;
            instructions;
        case {81,113}  % Command Quit - q,Q
            command = 81;  
   end
  
end            
  
% Restore old MaskD and give result.
result = MaskD;
MaskD = MaskStore;

function instructions
% Print out the user instructions.
    fprintf(1,'\n Mask.m --> Generate a Mask file\n');
    fprintf(1,'Select one of the following commands.\n');

    fprintf(1,'\n(r,R)  - Select a region of interest.');
    fprintf(1,'\n       - Mark polygon with left mouse button.  Finish selection with right mouse button.\n\n');
    
    fprintf(1,'\n(e,E)  - Eliminate data within current ROI.\n');
    fprintf(1,'\n(i,I)  - Include data within current ROI.\n');
    fprintf(1,'\n(n,N)  - Negate the current mask.\n');
    fprintf(1,'\n(f,F)  - Start with a fresh mask where all points are included.\n'); 
    fprintf(1,'\n(z,Z)  - Zoom \n');  
    fprintf(1,'Mouse mode: left click: (r,R); middle click (e,E); right click: quit\n!');
 
function show_image(imag,range,arange,polygon_x,polygon_y)
% Display the image and the current polygon of interest.
   show(imag,range,arange); 
   hold on; plot(polygon_x,polygon_y,'w'); hold off;
   arange;
   
