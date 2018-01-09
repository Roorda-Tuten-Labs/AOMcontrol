function [intensities_rand, offset_rand] = gen_random_sequence(CFG)
%
% USAGE
% [intensities_rand, offset_rand] = exp.gen_random_sequence(CFG)

% ---- Set intensities ---- %
% Intensity levels. Usually set to 1, can be a vector with multiple 
% intensities that will be randomly presented.
if CFG.run_intensity_sequence
    intensities = [0.2, 0.4, 0.8];
    if CFG.nscale < 1
        % scale 5 intensities in case where only doing brightness
        intensities = [0.1, 0.2, 0.3, 0.5, 0.75];
    end
else%if ~CFG.run_intensity_sequence && ~run_calibration
    intensities = 1;
end

if CFG.run_calibration
    intensities = [0, 0.25, 0.5, 0.75, 1];
end

nintensities = length(intensities);

% this section is essentially meaningless if intensities above is only a
% single value (1) as it is typically set.

add_blank_trials = 0;
fraction_blank = CFG.fraction_blank;
if fraction_blank > 0 && ~CFG.run_calibration
    add_blank_trials = 1;
end


% first handle case where adding in blank trials
if add_blank_trials && ~CFG.run_calibration
    n_blank_trials_per_cone = ceil(CFG.ntrials * fraction_blank);
    CFG.ntrials = CFG.ntrials + n_blank_trials_per_cone;
end
sequence = reshape(ones(CFG.ntrials, 1) * (1:CFG.num_locations), 1, ...
    CFG.num_locations * CFG.ntrials);
sequence_with_intensities = repmat(sequence, 1, nintensities);

intensities_sequence = repmat(intensities, CFG.ntrials .* CFG.num_locations, 1);
intensities_sequence = reshape(intensities_sequence, 1, ...
                               length(sequence_with_intensities));

if add_blank_trials && ~CFG.run_calibration
    % now that intensities sequence has been updated, add 0 intensity to
    % intensities variable
    
    % -- this is where 0 intensities are added to the sequence -- %
    % new total number of trials with blanks added
    total = length(intensities_sequence);
    
    % number of blanks across the dataset
    nblanks = n_blank_trials_per_cone * CFG.num_locations * nintensities;
    
    % find indexes so that each cone receives same number of blanks
    blank_indexes = 1:total/nblanks:total;
    
    % now switch intensites to 0 for each cone at desired rate
    intensities_sequence(blank_indexes) = 0;
end

% now randominze
if CFG.run_calibration
    % dont actually randomize
    randids_with_intensity = 1:numel(sequence_with_intensities);
else
    randids_with_intensity = randperm(numel(sequence_with_intensities));
end
offset_rand = sequence_with_intensities(randids_with_intensity);
intensities_rand =  intensities_sequence(randids_with_intensity);