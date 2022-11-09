function im = imageread(filename)
% read a bmp or buf image from file
%
% USAGE
% im = imageread(filename)
%
% INPUT 
% filename  name of file to read.
%
% OUTPUT
% im        image matrix.
%
% DESCRIPTION
% This function is used for reading images that will be displayed in the
% AOMcontrol matlab gui. Buf files are converted to 8-bit values for that
% purpose. Parse_Load_Buffers() handles loading of the full 10-bit buf
% files into memory.
%

fext = filename(size(filename,2)-2:size(filename,2));
switch fext
    case 'bmp'
        temp = imread(filename);
        if size(temp,3)
            im = temp(:,:,1);
        end
    case 'buf'
        fid = fopen(filename);
        dim = fread(fid, 2, 'int16');
        im = fread(fid, [dim(2) dim(1)], 'double');
        im = uint8(im*255);
        fclose(fid);
        clear fid; 
end
