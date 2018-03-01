%  function tag_vals = get_tag(filename)
%  A cruddy hack to import tags from TV6 1K version.
%  filename is the name of the TV6 TIFF file.
%  tag_vals is an array of 8 doubles.
%  Assuming the TIFF file was written by TV6, these should be the values of the 
%  average and instantaneous values of the ATOD card.
%  If this doesn't work, hack get_tag.c and get_tag_mex.c 
%  You may also want to do a bit dump on get_tag.

function tag_vals = get_tag(filename)

    temp = get_extra_tiff_tags(filename);
    temp2= temp.user_variables ;
    tag_vals = temp2([1:8]);
    
