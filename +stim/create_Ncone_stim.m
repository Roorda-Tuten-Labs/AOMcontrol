function stimulus = create_Ncone_stim(locs_xy, max_locs_xy, intensity,...
    stimsize, frameN, extension)
% create_Ncone_stim(locs_xy, max_locs_xy, intensity, stimsize, ...
%    frameN)
%
%

if nargin < 5
    frameN = 4;
end
if nargin < 6
    extension = 'buf';
end

% force spot size to be odd.
if mod(stimsize, 2) == 0
    stimsize = stimsize + 1;
end
% halfwidth of stimulus
deltasize = floor(stimsize / 2);

% add each location (cone) to the stimulus image to be displayed
stimulus = zeros(max_locs_xy(1), max_locs_xy(2));
for loc = 1:size(locs_xy)
    % find x position
    x = locs_xy(loc, 1);
    xs = x - deltasize:x + deltasize;   
    % find y position
    y = locs_xy(loc, 2);
    ys = y - deltasize:y + deltasize;   
    
    % add location to stimulus with given intensity
    stimulus(xs, ys) = intensity;
end

% change from x, y cartesian space to image space with 0,0 at top left.
stimulus = flipud(rot90(stimulus));

% save images
savedir = fullfile(pwd, 'tempStimulus');
if isdir(fullfile(pwd, 'tempStimulus')) == 0
    mkdir(fullfile(pwd, 'tempStimulus'));
end

% create IR image
if size(stimulus, 1) >= 10 || size(stimulus, 2) >= 10
    % create a canvas that is the same size as the green channel or bigger.
    if size(stimulus, 1) >= 10 && size(stimulus, 2) >= 10
        % both green dimensions are greater than 10x10 IR decrement
        IRimage = ones(size(stimulus));
    else
        % only one green dimension is greater than 10x10 IR.
        % figure out which dimension is smaller.
        if size(stimulus, 1) < 10
            IRimage = ones(10, size(stimulus, 2));
        else
            IRimage = ones(size(stimulus, 1), 10);
        end
    end
    % find the center of the image
    center = int8(ceil(size(IRimage) ./ 2));
    if length(center) == 1
        center = [center center];
    end
    % put the 9x9 decrement in the center of the image
    IRimage(center(1)-4:center(1)+4, center(2)-4:center(2)+4) = 0;    
else
    IRimage = zeros(10, 10);
end

if strcmpi(extension, 'bmp')
    imwrite(IRimage, fullfile(savedir, 'frame2.bmp'));  
    imwrite(stimulus, fullfile(savedir, ['frame' num2str(frameN) ...
        '.bmp']));
elseif strcmpi(extension, 'buf')
    stim.write_to_buf_file(IRimage, 2, savedir,'frame')
    stim.write_to_buf_file(stimulus, frameN, savedir, 'frame')
end
