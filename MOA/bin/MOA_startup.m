% Startup file used for MOA package
% Step 2. Declares Intensity_Map, X_Distortion_Map, Y_distortion_Map,
%  Spec_to_Phos, X_lambda, X_cen, Y_cen, MaskD and MaskI as global variables
% Step 3. Loads Correction_1KBin2.mat to allow image distortion and correction.
% Step 4.  Print reminder to set X_lambda, Spec_to_Phos, X_cen and Y_cen.
% Step 5.  Set default MaskD and MaskI as all on.

% Step 1.
%addpath n:/toombes/matlab/MOA_L/bin
%addpath n:/toombes/matlab/MOA_L/data
%addpath n:/toombes/matlab/MOA_L/testing
%addpath c:/MATLAB6P1/MOA_L/bin
%addpath c:/MATLAB6P1/MOA_L/data
%addpath c:/MATLAB6P1/MOA_L/testing
%addpath c:/MATLAB6P1/MOA_L/lwkfns

fprintf(1,'\n Welcome to the MOA package!\n\n');

% Step 1. Add path (now incorporated into startup.m

% Step 2.
global Intensity_Map X_Distortion_Map Y_Distortion_Map MaskD MaskI MaskIfile;
global Spec_to_Phos X_Lambda X_cen Y_cen Calib_Data;

%Spec_to_Phos = 1000; X_Lambda = 1.0; X_cen = 0; Y_cen = 0;

% Step 3.
%disp('Loading correction map data: Correction_1KBin2.mat')
%load ~/matlib/MOA/data/Correction_1KBin2.mat ;

% Step 4.
fprintf(1,'\n Please loading correction map data if necessary')
fprintf(1,'\n Please initialize X_Lambda, Spec_to_Phos, X_cen and Y_cen.\n');

% Step 5.
%MaskD = uint8(ones(size(Intensity_Map)));
%MaskI = uint8(ones(size(Intensity_Map)));
%MaskOnes=uint8(ones(size(Intensity_Map)));
