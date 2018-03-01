function dataformat = dataformat_guess(filename);
   dataformat = [];
   [filedir, prefix, suffix] = fileparts(filename);

   switch upper(suffix)
      case '.MAR2300'
         dataformat = 'MAR345';
      case {'.TIF', '.TIFF'}
         dataformat = 'TIFF';
      case '.IQ'
         dataformat = 'IQ';
      otherwise
         dataformat = 'TIFF';
         showinfo(['TIFF format is assumed for file: ' filename]);
   end
   
   