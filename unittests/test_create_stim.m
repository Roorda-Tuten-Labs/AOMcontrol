clearvars;
addpath('../')

stimsize = 3;
deltasize = floor(stimsize / 2);

stim1 = [...
    0 0; 0 10; 0 20; 0 30; 0 40; 0 50;...
    30 0; 30 10; 30 20; 30 30; 30 40; 30 50;] + deltasize + 1;
stim2 = [0 0; 5 5;] + deltasize + 1;
stim3 = [0 0; 11 0] + deltasize + 1;
stim4 = [0 0] + deltasize + 1;

all_locations = {};
all_locations{1} = stim1;
all_locations{2} = stim2;
all_locations{3} = stim3;
all_locations{4} = stim4;
for s = 1:length(all_locations)    
    
    trial_stim_loc = all_locations{s};
    
    max_loc_xy = max(trial_stim_loc) + deltasize;
    if length(max_loc_xy) == 1
        max_loc_xy = [max_loc_xy max_loc_xy];
    end
    max_loc_xy(1) = max_loc_xy(1) + 3;    
    stim.create_Ncone_stim(trial_stim_loc, max_loc_xy, 1, stimsize, 4, ...
        'bmp');
    
    IRimg = imread('tempStimulus/frame2.bmp');
    Greenimg = imread('tempStimulus/frame4.bmp');

    assert(size(IRimg, 1) >= size(Greenimg, 1))
    assert(size(IRimg, 2) >= size(Greenimg, 2))

    figure();
    subplot(2, 1, 1)
    imshow(IRimg)
    subplot(2, 1, 2)
    imshow(Greenimg);
end

