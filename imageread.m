function im = imageread(filename)
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
