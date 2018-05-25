function view_img()
%
% USAGE
% view_stim_img(im_path)

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