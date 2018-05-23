function IRimage = create_IR_stim(stimulus)
% Create an IR decrement with padding if necessary.
%
% USAGE
% IRimage = create_IR_stim(stimulus) 
% 
% INPUT
% stimulus  Stimulus image matrix. This is used to set the size of the
%           IRimage.
%
% OUTPUT
% IRimage   An image matrix for IR. It will produce a 9x9 decrement. If the
%           stimulus image is larger in either dimension than 9x9 the
%           IRimage will be padded with ones. This is because the IRimage
%           must be at least as large as the stimulus (green/red channel)
%           for proper delivery since the IR channel is used to predict the
%           target location. See AOMcontrol wiki for more details.
%


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
    IRimage = zeros(9, 9);
end