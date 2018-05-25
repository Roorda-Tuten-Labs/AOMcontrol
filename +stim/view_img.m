function view_img()
% View image files (bmp or buf) in a matlab figure window.
%
% USAGE
% stim.view_img()
%
% OUTPUT
% A separate figure will display each selected image file.
%

if nargin < 1
    [im_files, path] = uigetfile({'*', 'All files (*)';...
        '*.buf', 'buf files (*.buf)';...
        '*.bmp', 'bmp files (*.bmp)'}, ...
        'Select image(s) to view', 'MultiSelect', 'on');
end

for f = 1:length(im_files)
    
    filename = fullfile(path, im_files{f});
    im = imageread(filename);

    figure();
    imshow(im);
end