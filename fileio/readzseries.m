function imgdata = readzseries(prefix, suffix, varargin)

verbose = 1;
istart = 1;
iend = -1;
istep = 1;
num_digits = 2;
if exist('varargin', 'var')
   parse_varargin(varargin);
end

if (iend == -1) % read all images
   fname = dir([prefix '*' suffix]);
   num_files = length(fname);
   iend = num_files;
   num_digits = ceil(log10(num_files+1));
   if (num_files == 0)
      showinfo('No files found!');
      return
   end
end

idata = 1;
%showinfo(['Files to 
for i=istart:istep:iend
   fname = sprintf([prefix '%0' num2str(num_digits) 'i' suffix], i);
   imgdata(:,:,idata) = imread(fname);
   idata = idata+1;
   disp(['   read image file: ' fname])
end
