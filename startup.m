% $Id: startup.m,v 1.30 2016/10/26 15:21:56 xqiu Exp $

%% set up matlab path
matlib_dir=fileparts(mfilename('fullpath'));
addpath(fullfile(matlib_dir, 'atoms'))
addpath(fullfile(matlib_dir, 'biophysics'))
addpath(fullfile(matlib_dir, 'electrostatics'))
addpath(fullfile(matlib_dir, 'fluidynamics'))
addpath(fullfile(matlib_dir, 'graphics'))
addpath(fullfile(matlib_dir, 'iqgetx'))
addpath(fullfile(matlib_dir, 'sasa'))
addpath(fullfile(matlib_dir, 'fileio'))
addpath(fullfile(matlib_dir, 'curvefit'))
addpath(fullfile(matlib_dir, 'spectroscopy'))
addpath(fullfile(matlib_dir, 'sqtools'))
addpath(fullfile(matlib_dir, 'osmotic'))
addpath(fullfile(matlib_dir, 'cnt_graphene'))
addpath(fullfile(matlib_dir, 'mathstrop'))
addpath(fullfile(matlib_dir, 'strucellop'))
addpath(fullfile(matlib_dir, 'howell'))
addpath(fullfile(matlib_dir, 'imported'));
addpath(fullfile(matlib_dir, 'imported', 'MinMaxSelection'));
if verLessThan('matlab', '8.4') % matlab2014b
    addpath(fullfile(matlib_dir, 'imported', 'GUILayout-v1p17'))
    addpath(fullfile(matlib_dir, 'imported', 'GUILayout-v1p17', 'layout'));
    addpath(fullfile(matlib_dir, 'imported', 'GUILayout-v1p17', 'Patch'));
    addpath(fullfile(matlib_dir, 'imported', 'GUILayout-v1p17', 'layoutHelp'));
else
    addpath(fullfile(matlib_dir, 'imported', 'GUILayout-v2p31'))
    addpath(fullfile(matlib_dir, 'imported', 'GUILayout-v2p31', 'layout'));
    addpath(fullfile(matlib_dir, 'imported', 'GUILayout-v2p31', 'layoutdoc'));
end

addpath(fullfile(matlib_dir, 'MOA', 'bin'))

%% Plot default color and line orders
global colororder symbolorder

colororder = [ ...
    0      0      1.0; ...  % Blue
    0      0.50   0; ...    % Green
    1.00   0      0; ...    % Red
    0      0      0; ...    % Black
    0.75   0      0.75; ... % Magenta
    0      0.75   0.75; ... % Teal
    0.75   0.75   0; ...    % Yellow-Brown
    0.8    0      0.4; ...  % Mauve
    0.3    0      0.6; ...  % Purple
    0.8    0.4    0; ...    % Burnt Orange
    ];

%colororder = [...
%        0.21960784,  0.38039216,  0.54117647; ...  % blue
%        0.85098039,  0.23921569,  0.24313725; ...  % red
%        0.29411765,  0.42352941,  0.1372549 ; ...  % green
%        0.39215686,  0.26666667,  0.45882353; ...  % violet
%        0.89411765,  0.71372549,  0.18823529; ...  % yellow
%        0.71764706,  0.36078431,  0.21960784; ...  % brown
%        0.41960784,  0.67058824,  0.84313725; ...  % light blue
%        0.81960784,  0.32941176,  0.68627451; ...  % light red
%        0.69411765,  0.74901961,  0.22352941; ...  % light green
%        0.49411765,  0.45490196,  0.81960784; ...  % light purple
%        ];
%
%     colororder = [ ...
%         0      0      1.0; ...  % Blue
%         0      0.50   0; ...    % Green
%         1.00   0      0; ...    % Red
%         0.75   0      0.75; ... % Magenta
%         0      0.75   0.75; ... % Teal
%         0.75   0.75   0; ...    % Yellow-Brown
% %         0.3    0.75   0; ...    % Green 2
%         0.4    0      0.4; ...  % Eggplant
%         0.7    0.9    0; ...    % Yellow-Green
%         1.0    0.75   0; ...    % Yellow-Orange
%         0      0.3    0.6; ...  % Blue 2
% %         0.25    0.4    0; ...   % Earth Green
%         0.5    0.5    0.5; ... % gray1
%         0.75    0.75    0.75; ... % gray3
%         0.8    0      0.4; ...  % Mauve
%         0.3    0      0.6; ...  % Purple
%         0.8    0.4    0; ...  % Burnt Orange
% %         0.4    0.5    0; ...    % Camo Green
% %         0.4    0.2    0; ...  % Brown
%         % 1.0    1.0    0.; ... % this color is difficult to see
%         % 1.0    0.5    0; ...  % this color is looks too similar to 1 0 0
%         ];

symbolorder = {'s', 'o', '>', 'd', '^', 'p', '<', 'h', 'V', 'x', '*', '+'};
%symbolorder = {'s', 'o', '^', 'd', 'x', 'V', 'p', '<', '*', 'h', '+'};

lineorder= {'-', '--', '-.', ':'};

% not sure why these were defined (SH)
colororder = repmat(colororder, 7, 1); % breaks lineorder (too many colors)
symbolorder = repmat(symbolorder, 1, 7);

% redefine color: did not find a way to change the predefined
% color names (such as red, green, etc)

set(0, 'DefaultAxesColorOrder', colororder, 'DefaultAxesLineStyleOrder', ...
    lineorder);

%% general formatting

format short g;
figure_format('normal');
warning off;

if exist('mymatlabrc', 'file')
    mymatlabrc
end

%% User specific settings
if strfind(pwd,'schowell')
    set(0, 'defaultlinelinewidth', 2)
    matlabpool local 2
    com.mathworks.services.Prefs.setBooleanPref('ColorsUseSystem',0);
    com.mathworks.services.Prefs.setColorPref('ColorsBackground',java.awt.Color(7/255,54/255,66/255));
    com.mathworks.services.Prefs.setColorPref('ColorsText',java.awt.Color(133/255,153/255,0/255));
    com.mathworks.services.Prefs.setColorPref('Colors_M_Comments',java.awt.Color(181/255,137/255,0/255));
    com.mathworks.services.Prefs.setColorPref('Colors_M_Keywords',java.awt.Color(38/255,139/255,210/255));
    com.mathworks.services.Prefs.setColorPref('Colors_M_Strings',java.awt.Color(42/255,161/255,152/255));
end
