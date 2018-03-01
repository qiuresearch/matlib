function [im, header] = imread_spe(imfile)
% routine to read the image data from X6B at NSLS
% chem.sunysb.edu:8192
% niudao

   verbose = 1;
   
   fid = fopen(imfile, 'r');
   [headerarr, count]=fread(fid,4100,'uint8');

   header.all = headerarr;

   header.width = headerarr(7)+headerarr(8)*256;
   header.height = headerarr(19)+headerarr(20)*256;

   usercomment = char(headerarr(101:600)');
   usercomment(find(usercomment<' ')) = ' ';
   usercomment(find(usercomment>'}')) = ' ';
   usercomment =strsplit(usercomment, ' ');
   if (length(usercomment) > 16)
      header.expotime = str2num(usercomment{3});
      header.ion1 = str2num(usercomment{4});
      header.ion2 = str2num(usercomment{5});
      header.totalcount = str2num(usercomment{6});
      header.date = strjoin(usercomment(16:end), ' ');
   else
      header.expotime = 1;
      header.ion1 = 1;
      header.ion2 = 1;
      header.totalcount= 1;
      header.date = 'No Date';
      showinfo(['no user comment fields available in ' imfile '!']);
   end
   
   [immat, count]=fread(fid,2084*2084,'int32');
   im=reshape(immat, 2084, 2084);
   im=im';
   fclose(fid);
   
   
   