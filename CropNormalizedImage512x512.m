display('Select reference image to crop')
[filename, pathname] = uigetfile('*.avi;*.tif;*.tiff', ...
    'Select reference to crop (avi, tif or tiff)');

display('Drag rectangle over image and double click to crop area...')
searchRectLength = 511;
refImg = imread([pathname filename]);
f1 = figure;
set(gcf,'Position',[573.0000-400  437.6667  560.0000  420.0000])
imshow(refImg)
h = imrect(gca,[10 10 searchRectLength searchRectLength]);
addNewPositionCallback(h,@(p) title(mat2str(p,3)));
refRect = wait(h);
pos1 = getPosition(h);
imgCropped = imcrop(refImg,pos1);

idx=strfind(filename,'.tif');
if ~isempty(idx)
    filename = filename(1:idx-1);
end

refName = [filename, '_cropped.png'];
imwrite(imgCropped,[pathname refName])
display(['Saved: ' pathname refName])