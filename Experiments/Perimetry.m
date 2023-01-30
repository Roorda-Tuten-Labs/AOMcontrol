function Perimetry

% --------------- Parameters --------------- %
% ------------------------------------------- %
% set some variable to global. most of these are first modified 
% by AOMcontrol.m
global SYSPARAMS StimParams VideoParams;

% ---- Quest set up (need these to be in CFG).
% tGuess = log10(0.5);
tGuess = log10(1);
% tGuessSD = log10(0.5);
tGuessSD = 3; % Quest assumes this is in log units, so this corresponds to 0.001 to 1;

% beta is the slope of a Weibull function. This parameter has been
% estimated from real data (20076R=1.6, 20053R=2.3, 20092L=2.2)
beta = 2.0;
% default parameters:
% 1-delta sets how high the function goes, i.e. the lapse rate
delta = 0.01;
% controls how low. A two alternative forced choice with 0.5 guessing rate
% should set gamma to 0.5. However, in our case we are measuring frequency
% of seeing. Set it to 0.03 or ~ the false alarm rate.
gamma = 0.03;


% now wait for ui to load
CFG = perimetry_CFG_gui();


% frequency of Seeing that we are trying to find.
pThreshold = CFG.pThreshold; 

% ---- Find user specified TCA ---- %
tca_green = [CFG.green_x_offset CFG.green_y_offset];

% ---- select cone locations ---- %
% --------------------------------------------------------------- %
choice = questdlg('Would you like to select cones?', ...
    'Cone selection choice', ...
    'Yes', 'No', 'Yes');
switch choice
    case('Yes')
        try
            [stim_offsets_xy, X_cross_loc, Y_cross_loc] = cone_select.main_gui(...
                tca_green, VideoParams.rootfolder, CFG);
            if ~isnan(stim_offsets_xy)
                cross_xy = [X_cross_loc, Y_cross_loc];
            else
                % if stim_offsets_xy return with NaN then we cannot proceed any
                % further. Therefore, we abort the mission here and now.
                return
            end
        catch
            % if cone_select toolbox is not installed, just select four locations
            % offset from the center of the raster by ten pixels
            cross_xy = [-10 10; 10 10; 10 -10; -10 -10];
        end
    case 'No'
        cross_xy = [0 0];
        stim_offsets_xy = [0];
end

n_unique_locs = length(stim_offsets_xy);
% set up randomized vectors for each of the two staircases
loc_IDs = repmat(1:n_unique_locs, [1, CFG.ntrials * 2]);
random_indexes = randperm(numel(loc_IDs));
random_IDs = loc_IDs(random_indexes);

% interleave two staircases for each selected location
random_staircases = zeros(size(random_IDs));
for loc = 1:n_unique_locs
    tmp_random_staircases = repmat(1:2, [1 CFG.ntrials]);
    random_indexes = randperm(numel(tmp_random_staircases));
    tmp_random_staircases = tmp_random_staircases(random_indexes);
    
    % find all indexes of current location and put randomized staircase 
    % number (1 || 2) at each position.
    random_staircases(random_IDs == loc) = ...
        tmp_random_staircases;
end

% --------------------------------------------------------- %
% force spot size to be odd.
if mod(CFG.stimsize, 2) == 0
    error('Stimulus size must be an odd number');
end

% total number of locations
CFG.num_locations = n_unique_locs;  
% ------------------------------------------------------------------ %

% -------set key/value bindings ---------- %
kb_StimConst = 'space';
kb_BadConst = 'uparrow';
kb_AbortConst = 'escape';

% no '.' in the file extension.
fext = 'buf';

% ----- now if cone_select.main_gui has been successful, initialize exp. 
% Do this here so that if video was not good, then will not update
% parameters in ICANDI.
[hAomControl, aom_fig_handle] = exp.initialize(CFG, fext);

% ---- Setup Mov structure ---- %
Mov = aom.generate_mov(CFG);
Mov.dir = StimParams.stimpath;
Mov.suppress = 0;
Mov.pfx = StimParams.fprefix;

% ---- Apply TCA offsets to cone locations ---- %
[aom2offx_mat, aom2offy_mat] = aom.apply_TCA_offsets_to_locs(...
    tca_green(1, :), cross_xy, stim_offsets_xy, ...
    length(Mov.aom2seq), CFG.system);

CFG.vidprefix = CFG.initials;

% ---- Quest set up ---- %
% set up a structure with quest objects. Two for each location
locs_Quest = struct([]);
for loc = 1:CFG.num_locations
    locs_Quest{loc} = struct([]);
    for s = 1:2 % two staircases per location
        q=QuestCreate(tGuess, tGuessSD, pThreshold, beta, delta, gamma);

        % This adds a few ms per call to QuestUpdate, but otherwise the pdf
        % will underflow after about 1000 trials.
        q.normalizePdf = 1; 

        locs_Quest{loc}{s} = q;
    end
end
% --------------- %

% ---- Setup response matrix ---- %
exp_data = {};
exp_data.trials = zeros(CFG.ntrials * 2, 1);
exp_data.location_ids = zeros(length(random_IDs), 2);
exp_data.offsets_pos = zeros(length(random_IDs), 2);
exp_data.intensities = zeros(length(random_IDs), 1); 
exp_data.uniqueoffsets = stim_offsets_xy;
exp_data.answer = zeros(CFG.ntrials * 2, 1);

% Save param values for later
exp_data.tca_green = tca_green;
exp_data.stimsize = CFG.stimsize;
exp_data.ntrials = CFG.ntrials;
exp_data.num_locations = CFG.num_locations;

exp_data.experiment = 'Color Naming Basic';
exp_data.subject  = ['Observer: ' CFG.initials];
exp_data.pupil = ['Pupil Size (mm): ' CFG.pupilsize];
exp_data.field = ['Field Size (deg): ' num2str(CFG.fieldsize)];
exp_data.presentdur = ['Presentation Duration (ms): ' num2str(...
    CFG.presentdur)];
exp_data.videoprefix = ['Video Prefix: ' CFG.vidprefix];
exp_data.videodur = ['Video Duration: ' num2str(CFG.videodur)];
exp_data.videofolder = ['Video Folder: ' VideoParams.videofolder];

% Create default stimulus
stim.createStimulus(CFG.stimsize, CFG.stimshape, 1, 'buf');

% --------------------------------------------------- %
% --------------- Begin Experiment ------------------ %
% --------------------------------------------------- %    
% Set initial while loop conditions
runExperiment = 1;
trial = 1;
PresentStimulus = 1;
GetResponse = 0;
good_trial = 0;
set(aom_fig_handle.aom_main_figure, 'KeyPressFcn','uiresume');

total_number_of_trials = CFG.ntrials * 2 * n_unique_locs;
% Start the experiment
while(runExperiment ==1)
    uiwait;
    resp = get(aom_fig_handle.aom_main_figure,'CurrentKey');
    disp(resp);
    
    % if abort key triggered, end experiment safely.
    if strcmp(resp, kb_AbortConst)
        runExperiment = 0;
        uiresume;
        TerminateExp;
        message = ['Off - Experiment Aborted - Trial ' num2str(trial) ...
            ' of ' num2str(CFG.ntrials * 4)];
        set(aom_fig_handle.aom1_state, 'String', message);
            
    % check if present stimulus button was pressed
    elseif strcmpi(resp, kb_StimConst)
        if PresentStimulus == 1
            % play sound to indicate start of stimulus
            % sound(cos(90:0.75:180));            
            beep;
            
            % figure out which location is being teseted
            test_loc = random_IDs(trial);
            
            % decide which staircase is active for that location
            active_staircase = random_staircases(trial);
            
            % find test location offsets
            % test_offsets = stim_offsets_xy(test_loc, :);
            
            % find the intensity to use for the given location
            % Pelli (1987) recommend QuestQuantile.
            % Don MacLeod via Ally Boehm recommend QuestMean, which we will
            % used. The evidence backing this up comes from King-Smith et 
            % al. (1994).
            % Quest keeps track of intensities in log10 units
            Quest_intensity = 10 .^ QuestMean(...
                locs_Quest{test_loc}{active_staircase});
            
            % make sure test_intensity stays between AOM limits of 0 and 1
            if Quest_intensity > 1 
                test_intensity = 1;
            elseif Quest_intensity < 0
                test_intensity = 0;
            else
                test_intensity = Quest_intensity;
            end

            % create new stimuli for each trial with new intensity
            stim.createStimulus(CFG.stimsize, CFG.stimshape, ...
                test_intensity, 'buf');            

            % update system params with stim info. Parse_Load_Buffers will 
            % load the specified frames into ICANDI.
            if SYSPARAMS.realsystem == 1
                StimParams.sframe = 2;
                StimParams.eframe = 4;                
                Parse_Load_Buffers(0);
            end

            % ---- set movie parameters to be played by aom ---- %
            % Select AOM power 100% for most experiments unless set 
            % otherwise with intensity variable at top of file.
            Mov.aom2pow(:) = 1;
            Mov.aom0pow(:) = 1;

            % tell the aom about the offset (TCA + cone location)
            % Centers will always be the same. The position of the spots is
            % changed by moving it in the bmp file. The bmp file is always
            % rendered to the same size.
        
            Mov.aom2offx = aom2offx_mat(1, :, test_loc);
            Mov.aom2offy = aom2offy_mat(1, :, test_loc);

            % change the message displayed in status bar
            message = ['Running Experiment - Trial ' num2str(trial) ...
                       ' of ' num2str(total_number_of_trials)];
            Mov.msg = message;
            Mov.seq = '';
            
            % send the Mov structure to app data
            setappdata(hAomControl, 'Mov', Mov);
                        
            % update save name of video
            VideoParams.vidname = [CFG.vidprefix '_' sprintf('%03d', trial)];

            % use the Mov structure to play a movie
            PlayMovie;

            % update loop variables
            PresentStimulus = 0;
            GetResponse = 1;

        else
            % Repeat trial. Not sure it ever gets down here.   
            GetResponse = 1;
            good_trial = 0;
            
            % Play sound.
            beep
            
            PresentStimulus = 1;
            % Update message
            message1 = [Mov.msg ' Repeat trial'];
            set(aom_fig_handle.aom1_state, 'String', message1);

        end 
            
    elseif GetResponse == 1

        if strcmpi(resp, kb_BadConst)
            message1 = [Mov.msg ' Repeat trial']; 
            GetResponse = 0;
            good_trial = 0;

        elseif strcmpi(resp, 'rightarrow')
            message1 = [Mov.msg ' Seen'];   
            GetResponse = 0;
            good_trial = 1;
            seen_flag = 1;
            
        elseif strcmpi(resp, 'leftarrow')
            message1 = [Mov.msg ' Not Seen'];
            GetResponse = 0;
            good_trial = 1;
            seen_flag = 0;
            
        % if abort key triggered, end experiment safely.
        elseif strcmp(resp, kb_AbortConst)
            runExperiment = 0;
            uiresume;
            TerminateExp;
            message = ['Off - Experiment Aborted - Trial ' ...
                num2str(trial) ' of ' num2str(total_number_of_trials)];
            set(aom_fig_handle.aom1_state, 'String', message);

        else                
            % All other keys are not valid.
            message1 = [Mov.msg ' ' resp ' not valid response key'];
        end

        % display user response.
        set(aom_fig_handle.aom1_state, 'String', message1);

        if GetResponse == 0
            % save response
            if good_trial
                
               % update the quest object for tested location based on 
               % whether the stimuls was seen
               locs_Quest{test_loc}{active_staircase} = QuestUpdate(...
                   locs_Quest{test_loc}{active_staircase}, ...
                   log10(test_intensity), seen_flag);      
               
                % add trial data to record
                exp_data.trials(trial) = trial;
                exp_data.location_ids(trial, :) = test_loc;
                exp_data.offsets_pos(trial, :) = stim_offsets_xy(test_loc, :);
                exp_data.intensities(trial) = 10 .^ test_intensity;
                exp_data.answer(trial) = seen_flag;

                %sound(cos(0:0.5:90));
                beep;
                pause(0.2);

                %update trial counter
                trial = trial + 1;
                
                % if trial is greater than ntrials, terminate exp.
                if trial > (total_number_of_trials)
                    runExperiment = 0;
                    set(aom_fig_handle.aom_main_figure, 'keypressfcn','');
                    TerminateExp;
                    message = 'Off - Experiment Complete';
                    set(aom_fig_handle.aom1_state, 'String', message);
                end
            end
            PresentStimulus = 1;
        end
    end
end

% add all of the Quest objects
exp_data.locs_Quest = locs_Quest;

% save data
filename = ['data_multicone_thresh',strrep(strrep(strrep(datestr(now), ...
    '-',''), ' ','x'),':',''),'.mat'];
save(fullfile(VideoParams.videofolder, filename), 'exp_data');

% Plot the staircases
figure;
hold on;
count = 1;
for loc = 1:n_unique_locs
    
    for s = 1:2
        intensities = 10 .^ exp_data.locs_Quest{loc}{s}.intensity(1:CFG.ntrials);
        response = exp_data.locs_Quest{loc}{s}.response(1:CFG.ntrials);

        threshold_estimate = 10 .^ QuestMean(exp_data.locs_Quest{loc}{s});
        disp(threshold_estimate);   

%         subplot(ceil(n_unique_locs / 4), 4, count);
        hold on;
        text(10*loc, 0.25*s, num2str(round(threshold_estimate, 3)));
%         plot(response, 'rx');
        plot(intensities, 'k.-');
    end
    count = count + 1;
end

end
