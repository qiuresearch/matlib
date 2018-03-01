% Startup file for MOA softare.
% Edit to fit.
% Step 1. Adds MOA routines to the matlab search path.
% Step 2. Declares Intensity_Map, X_Distortion_Map, Y_distortion_Map,
%  Spec_to_Phos, X_lambda, X_cen, Y_cen, MaskD and MaskI as global variables for use by 
% MOA Routines.
% Step 3. Initializes Intensity_Map, X_Distortion_Map, Y_Distortion_Map to match a 
% particular detector.  These are usually stored in a .mat file.  
% Look in src/image_correction/EXISTING_CORRECTION_FILES for examples
%  For instance Correction_2K.mat is the correction file for the 2K detector.
% Step 4.  Print reminder to set X_lambda, Spec_to_Phos, X_cen and Y_cen.
% Step 5.  Set default MaskD and MaskI as all on.  This means images are unmasked.
% *************************************************
%  Note you must edit this file to match your system setup.
% *************************************************

% Step 1.
addpath /a/MOA/bin_linux;
addpath /a/MOA/src;
addpath /a/MOA/jlfns;
% eg. a=pwd; eval(sprintf('addpath %s',a));

% Step 2.
global Intensity_Map; global X_Distortion_Map; global Y_Distortion_Map;
global Spec_to_Phos; global X_Lambda; global X_cen; global Y_cen;
global MaskD; global MaskI;

% Step 3.
%load /a/MOA/src/correction_files/Correction_1KBin2.mat % Set up for 1K detector running in Bin 2. 
%fprintf(1, '\n Correction files for Gruner 1K loaded')
%load Correction_1KBin2.mat
load /a/MOA/src/correction_files/Correction_Medbin1.mat %Correction files for Medoptics
fprintf(1,'\n Correction files for Medoptics detector loaded')
%fprintf(1, '\n Correction files not loaded');

% Step 4.
fprintf(1,'\n Please initialize X_Lambda, Spec_to_Phos, X_cen and Y_cen.\n');

% Step 5.
MaskD = uint8(ones(size(Intensity_Map)));
MaskI = uint8(ones(size(Intensity_Map)));

