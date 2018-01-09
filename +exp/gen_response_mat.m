function exp_data = gen_response_mat(CFG, Ntrials, labels, videofolder,...
    stim_offsets_xy)

% ---- Setup response matrix ---- %
exp_data = {};
exp_data.trials = zeros(Ntrials, 1);
exp_data.coneids = zeros(Ntrials, 1);
exp_data.offsets = zeros(Ntrials, 2);
exp_data.intensities = zeros(Ntrials, 1); 
exp_data.uniqueoffsets = stim_offsets_xy;
exp_data.answer = zeros(Ntrials, CFG.nscale);

% Save param values for later

exp_data.experiment = 'Color Naming Basic';
exp_data.subject  = ['Observer: ' CFG.initials];
exp_data.pupil = ['Pupil Size (mm): ' CFG.pupilsize];
exp_data.field = ['Field Size (deg): ' num2str(CFG.fieldsize)];
exp_data.presentdur = ['Presentation Duration (ms): ' num2str(CFG.presentdur)];
exp_data.videoprefix = ['Video Prefix: ' CFG.vidprefix];
exp_data.videodur = ['Video Duration: ' num2str(CFG.videodur)];
exp_data.videofolder = ['Video Folder: ' videofolder];
exp_data.brightness_scaling = CFG.brightness_scaling;
exp_data.stimsize = CFG.stimsize;
exp_data.ntrials = CFG.ntrials;
exp_data.num_locations = CFG.num_locations;
exp_data.Nscale = CFG.nscale;
exp_data.cnames = labels;
exp_data.seed = 45245801;

end