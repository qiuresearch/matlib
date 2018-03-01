%TO DO: edit all of these short descriptions
%
%General Functions and Utilities.
%  ccnt          - centers plot points and texts to center of mass
%  crad          - deletes plot points and texts behind specified radius
%  crsshair      - crosshair for reading (x,y) values from a plot
%  cutoff        - GUI for colormap cut off 
%  gqsh          - GUI for quick view of data files
%  linreg        - least squares line fit
%  lsla          - DIR with description of data files 
%  phconst       - definitions of physical constants
%  pickxy        - wizard for picking up data points from scanned plots
%  pdens         - density of cylindrical sample, sizes in mm
%  pidens        - density of cylindrical sample, sizes in Inch
%  pycno         - calculates density from pycnometer measurement
%  rdf           - calculates radial distribution function
%  rdiary        - function for executing diary file
%  rhead         - read data from ASCII file with header
%  whead         - write data to ASCII file with header
%
%Directories and Settings.
%  nto           - set path to NbTaO
%  pdata         - set path to DATA
%  prop          - setup proposal
%  prtg          - run Portuguese magor
%  tk            - setup tk dir
%
%XRD Data Manipulation.
%  d2th2         - converts D to TH2
%  dspace        - calculates plane spacing for a given lattice
%  dt2k12        - calculates CuK1, CuK2 dublet distance in 2 TH
%  finspsw       - prepares ATOM lines for finax input for PSW xrd simulations
%  fnarea        - calculates area under fnpeak, without background
%  fnpeak        - function for fitting Gauss or Lorenz peak with or
%  gfpk          - [GUI] fit of the Lorentz [default] or Gaussian peak with
%  npkar         - area under Lorenz, Gauss or Pseudo-Voigt multi-peak function
%  npkfit        - curve fit of Lorenz, Gauss or Pseudo-Voigt multi-peaks
%  npkfitfn      - curve fit function - returns sum of squares 
%  npkfn         - Lorenz, Gauss or Pseudo-Voigt multi-peak function
%  pkplt         - draw stems without circles, line
%  pprec         - corrects perovskite XRD peaks file to the Si standard
%  racq          - read ACQ file used by some X-ray systems
%  rjcp          - reads JCP format of the PDF card
%  rmclay        - removes clay background from XRD data
%  rpks          - reads data from rigaku PKS file
%  rraw          - reads data from rigaku RAW file
%  shraw         - plot of XRD spectra from RAW file
%  shraws        - put several raws into 1 axis
%  th2d          - calculates d spacing from 2theta
%  xinorm        - normalizes xrd intensity
%  xrdpeak       - xrd peaks fitting script
%
%Dielectric Data Manipulation.
%  dieldif       - find diffuseness of dielectric peaks
%  diepk         - find maxima of the dielectric peaks
%  dielrep       - report on peaks and diffuseness of the dielectric data
%  fvogfit       - function for Vogel-Fulcher fit
%  rpol          - reads RT66 polarization data
%  rted          - reads old or new formats of permitivity data
%  shpol         - plot of polarization curver from RT66 system
%  shfed         - plots fed data file
%  shted         - plot mted data file
%  tcted         - calculate Curie temperature from dielectric data
%  vogelfit      - fit of the Vogel-Fulcher relation to the dielectric data
%  wted          - write to permitivity data file
