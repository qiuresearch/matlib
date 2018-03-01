%  function result = correct(image)
%
%  Performs image intensity and distortion correction using the 
% global variables Intensity_Map, X_Distortion_Map and Y_Distortion_Map
% along with the functions, correct_distortion and correct_intensity.

function result = correct(image)

global Intensity_Map X_Distortion_Map Y_Distortion_Map;

if (size(image,1)==size(Intensity_Map,1))& ...
   (size(image,2)==size(Intensity_Map,2))
   
   result=correct_intensity(image,Intensity_Map);
   
   if (size(image,1)==size(X_Distortion_Map,1))& ...
      (size(image,2)==size(X_Distortion_Map,2))& ...
      (size(image,1)==size(Y_Distortion_Map,1))& ...
      (size(image,2)==size(Y_Distortion_Map,2))
      
      result=correct_distortion(result,X_Distortion_Map,Y_Distortion_Map);
   else
      error('Global Variables X_Distortion_Map or Y_Distortion_Map not initialized');	
   end   
else
   error('Global Variable Intensity_Map not correctly defined.');
end