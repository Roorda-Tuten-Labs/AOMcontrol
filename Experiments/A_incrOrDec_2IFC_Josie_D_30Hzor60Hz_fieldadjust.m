% Motion Perception experiment for AOMcontrol: 2 Interval FC 3 Gains Quest Staircase_Josie_D
% everything is in aom1 channel. so no dual stimuli mode.

% This version uses randn  (normalized distribution)
% 2 stimuli: retina-contingent, & RWstim
% 1. SET THE STARTING difConStart YOU WANT TO TEST.
%    The RWstim goes on a random walk, the diffusion constant is 'difCon',
%     which gets updated with every trial via Quest Staircase
% 2. SET THE logGuessSpeed
% 3. SET THE GAINS.
%    The rw stimulus has gain = 0, it goes on the random walk
%    The retina-contingent stimulus has a gain of any value between -3.0 to 2.0

% USEFUL INFO
% You can set gains to negative. or you can use angleseq to make it
% negative. If your angles are only 0 and 180, negative gain is easier

function A_incrOrDec_2IFC_Josie_D_30Hzor60Hz_fieldadjust

global SYSPARAMS StimParams VideoParams;

% Not sure what this does, exactly
if exist('handles','var') == 0
    handles = guihandles;
end

startup;

% Get experiment config data stored in appdata for 'hAomControl'
hAomControl = getappdata(0,'hAomControl');

%------HARD-CODED PARAMETER FOLLOWS----------------------------------
use_params = input('Do you want to use previous params? y/n:  ','s');

if use_params == 'n'
    
    % Experiment parameters -- BASIC
    expParameters.subjectID = GetWithDefault('Subject ID','Test'); % Videos will save starting with this prefix
    [expParameters.aosloFPS] = GetWithDefault('Is this 30Hz or 60Hz exp?', 30); %UCB frame rate, in Hz fast scanner is 16kHz. Slow scanner is 30Hz. Discrete stim at dif time points gives illusion that motion: Strobascopic display properties
    
    if expParameters.aosloFPS == 60
        [expParameters.doublingFieldTF] = GetWithDefault('Are you doubling the vertical field? 1--yes, 0--n', 1);
        if expParameters.doublingFieldTF == 1
            [expParameters.field_Y_adjust] =1/2;
        elseif expParameters.doublingFieldTF == 0
            [expParameters.field_Y_adjust] =1;
        end
    else
        [expParameters.field_Y_adjust] =1;
    end
    
    % Experiment parameters -- STIMULUS & VIDEO
    expParameters.testDurationMsec    = 1500; %'Each Stimulus Timing: enter duration in msc'
    [expParameters.breakDuration]     = 500; %'Break duration between stimuli: enter duration in msc'
    [expParameters.startendbuffers]   = 250; %'Buffer before stimulus onset: enter duration in msc'
    expParameters.videoDurationMsec   = expParameters.testDurationMsec*2+expParameters.breakDuration+expParameters.startendbuffers*2; % Video duration, in msec
    expParameters.videoDurationFrames = round(expParameters.aosloFPS*(expParameters.videoDurationMsec/1000)); % Convert to frames
    expParameters.record              = 1; % Set to one if you want to record a video for each trial, set 0 if don't want video
    [expParameters.eccentricity]      = GetWithDefault('At what eccentricity is stimulus delivered', 2);
    [expParameters.increment]         = GetWithDefault('Is stimulus increment? (1--increment, 0--decrement)', 0);
    
    if expParameters.increment == 1
        [expParameters.redChpow]       = GetWithDefault('How much reduce the red power by?', 0.1);
        [expParameters.rasterCancelTF] = GetWithDefault('Raster canceld? 1--yes, 0--n', 1);
    end
    
    % Experiment parameters -- GAINS 3 STIMULI
    [expParameters.numRetContTotal]   = GetWithDefault('How many gains to test (2 or 3)?', 3);
    [expParameters.Gain1]             = GetWithDefault('Gain of contingent stimulus (first)', -1.5);
    [expParameters.Gain2]             = GetWithDefault('Gain of contingent stimulus (second)', 1.5);
    
    if expParameters.numRetContTotal == 3
        [expParameters.Gain3]         = GetWithDefault('Gain of contingent stimulus (third)', 0);
    end
    
    expParameters.nIntervals          = 2;
    expParameters.ntrialsPerGain      = 30;
    expParameters.nTrials             = expParameters.numRetContTotal*expParameters.ntrialsPerGain;
    [expParameters.difConStart]       = GetWithDefault('Starting diffusion constant:', 2940); %random walk starting speed
    [expParameters.ppdX]              = GetWithDefault('ppd_x:', 302);
    [expParameters.ppdY]              = GetWithDefault('ppd_y:', 302); %pixels per degree
    
    % Experiment parameters -- STAIRCASE/QUEST
    expParameters.staircaseType   = 'Quest';
    expParameters.numStaircases   = expParameters.numRetContTotal; % Interleave staircases? Set to >1
    [expParameters.guessdifCon]   = GetWithDefault('Guess diffusion constant: ', 540);
    expParameters.tGuessSd        = 2; % Width of Bayesian prior, in log units (from -1 to 10, since log -1 = 1, and log10 =1)
    expParameters.pThreshold      = .5; % If 4AFC, halfway between 100% and guess rate (25%) = .625
    
    % updated to .8 for jitter exp.
    expParameters.beta  = 3.5; % Slope of psychometric function
    expParameters.delta = 0.01; % Lapse rate (proportion of suprathreshold trials where subject makes an error)
    expParameters.gamma = 0.01; % 4 alternative forced-choice = 25 percent guess rate
    
    save('ExpParams.mat', 'expParameters')
    
elseif use_params == 'y'
    load('ExpParams.mat')
end

%------END HARD-CODED PARAMETER SECTION------------------------------------
% Create QUEST structures, one for each staircase

%converting the guessDifCon into log of the speedTestStim
[logGuessSpeed] = dcToLogspeedteststim(expParameters.guessdifCon, expParameters.aosloFPS);

for n = 1:expParameters.numStaircases
    q(n,1) = QuestCreate(logGuessSpeed, expParameters.tGuessSd, ...
        expParameters.pThreshold, expParameters.beta, expParameters.delta, expParameters.gamma);
end

% Directory where the stimuli will be written and accessed by ICANDI
% [rootDir, ~, ~] = fileparts(pwd);
rootDir = pwd;
expParameters.stimpath = [rootDir filesep 'tempStimulus' filesep];
if ~isdir(expParameters.stimpath)
    mkdir(expParameters.stimpath);
end


% Some boilerplate AOMcontrol stuff
if SYSPARAMS.realsystem == 1
    StimParams.stimpath = expParameters.stimpath; % Directory where the stimuli will be written and accessed by ICANDI
    VideoParams.vidprefix = expParameters.subjectID;
    set(handles.aom1_state, 'String', 'Configuring Experiment...');
    set(handles.aom1_state, 'String', 'On - Experiment ready; press start button to initiate');
    if expParameters.record == 1 % Recording videos for each trial; set to zero if you don't want to record trial videos
        VideoParams.videodur = expParameters.videoDurationMsec./1000; % Convert to seconds; ICANDI will record a video for each trial of this duration
    end
    
    psyfname = set_VideoParams_PsyfileName(); % Create a file name to which to save data
    Parse_Load_Buffers(1); % Not sure about what this does when called in this way
    set(handles.image_radio1, 'Enable', 'off');
    set(handles.seq_radio1, 'Enable', 'off');
    set(handles.im_popup1, 'Enable', 'off');
    set(handles.display_button, 'String', 'Running Exp...');
    set(handles.display_button, 'Enable', 'off');
    set(handles.aom1_state, 'String', 'On - Experiment mode - Running experiment...');
end

% Establish file name, perhaps from psyfname, so that videos and
% experiment data file are saved together in the same folder
[rootFolder, fileName, ~] = fileparts(psyfname);
dataFile = [rootFolder filesep fileName '_MotionPerceptionData.mat'];

%If decrement, Turning on AllChannelImaging in iCANDI
if expParameters.increment == 0
    allChImageCommand = sprintf('AllChImaging#%d#',1);
    netcomm('write',SYSPARAMS.netcommobj,int8(allChImageCommand));
end

% Setting Raster & Location commands
rasterCommand = sprintf('RasterFix#%d#', 1);
netcomm('write',SYSPARAMS.netcommobj,int8(rasterCommand));

% LocUser#x#y# /*Update stimulus position with absolute x and y positions*/
if expParameters.aosloFPS == 60
    centerCommand = sprintf('LocUpdateAbs#%d#%d#', 256, 128);
    netcomm('write',SYSPARAMS.netcommobj,int8(centerCommand));
else
    centerCommand = sprintf('LocUpdateAbs#%d#%d#', 256, 256);
    netcomm('write',SYSPARAMS.netcommobj,int8(centerCommand));
end

%% Main experiment loop

frameIndexFix_off = 2; %The index of the fixation cross stimulus bitmap
frameIndexFix_on = 3; %The index of the fixation cross stimulus bitmap
frameIndexCircle = 4; % The index of the stimulus bitmap

% Place stimulus startframe and endframe
startFramestim1 = 1;
endFramestim1 = startFramestim1 + floor(expParameters.testDurationMsec/1000*expParameters.aosloFPS);
startFramestim2 = endFramestim1 + floor(expParameters.breakDuration/1000*expParameters.aosloFPS);
endFramestim2 = startFramestim2+floor(expParameters.testDurationMsec/1000*expParameters.aosloFPS);

%check with Pavan if I should remove the digital marks commands too
%creating 10 RW's for each possible Diffusion Constant
[~, true_diffusionConstants, rwpaths_given_trueDCs, xColumn, yColumn] = ...
    create10RWclosestToDC(expParameters.aosloFPS, expParameters.testDurationMsec/1000, endFramestim1, rootFolder, fileName, expParameters.difConStart);

%AOM0 (IR) parameters FIXATION CROSS
aom0seq = ones(1,expParameters.videoDurationFrames);
aom0seq(startFramestim1:endFramestim1) = frameIndexFix_off;
aom0seq(startFramestim2:endFramestim2) = frameIndexFix_off;
aom0seq(size(aom0seq,2)) = frameIndexFix_on;

%locations
aom0locx = zeros(size(aom0seq));
aom0locy = zeros(size(aom0seq)); % same as above, but for y-dimension
aom0pow  = ones(size(aom0seq));
aom0gain = zeros(size(aom0seq));

%AOM1 (RED, tyically) parameters STIMULUS 1
%FOR DECREMENET: set default aom[x]seq to 1 to be blank, if you set it to 0 then black squares will appear in these frames
%FOR INCREMENT: set default aom[x]seq to 0 to be blank, if you set it to 1 then black squares will appear in these frames
if expParameters.increment == 1
    aom1seq = zeros(1,expParameters.videoDurationFrames);
elseif expParameters.increment == 0
    aom1seq = ones(1,expParameters.videoDurationFrames);
end

aom1seq(startFramestim1:endFramestim1) = frameIndexCircle;
aom1seq(startFramestim2:endFramestim2) = frameIndexCircle;
aom1pow  = ones(size(aom0seq));
aom1offx = zeros(size(aom0seq));
aom1offy = zeros(size(aom0seq));
aom1gain = zeros(size(aom1seq));

%AOM2 (GREEN, typically) paramaters STIMULUS 2
if expParameters.increment == 1
    aom2seq = zeros(1,expParameters.videoDurationFrames);
elseif expParameters.increment == 0
    aom2seq = ones(1,expParameters.videoDurationFrames);
end

aom2pow  = ones(size(aom0seq));
aom2offx = zeros(size(aom0seq));
aom2offy = zeros(size(aom0seq));
aom2gain = zeros(size(aom0seq));

% Generate the acuity test sequence
testSequence = (1:1:expParameters.nTrials);

%assigning variables
questdifConVector = nan(expParameters.numRetContTotal, length(testSequence)/expParameters.numRetContTotal); %row 1 is refGainFirst and row2 is refGainSecond
questdifConVector(:,1) = expParameters.difConStart;

%creating vector to track the actual diffusion constants tested , chosen from the options in 'true_diffusionConstants'
difConVector = nan(expParameters.numRetContTotal, length(testSequence)/expParameters.numRetContTotal);
difConVector(:,1) = expParameters.difConStart;

%defining stim1stim2 rows for easier read
row_rw   = 1;
row_gain = 2;

% row one defines which stimulus (either 1 or 2) goes on random walk, row two defines the gain of the retina-contingent stimulus
stim1Stim2order = nan(2, expParameters.nTrials);
counter = 1;
combine_rw_stim = [];

for s = 1:expParameters.nIntervals
    cur_rwStim = s.*ones(1,expParameters.nTrials/(expParameters.numRetContTotal*expParameters.nIntervals));
    combine_rw_stim = [combine_rw_stim cur_rwStim];
end

for g = 1:expParameters.numRetContTotal
    eachGain = strcat('expParameters.Gain', num2str(g));
    gain_of_interest = eval(eachGain).*ones(1,expParameters.ntrialsPerGain);
    
    stim1Stim2order(row_gain, counter: counter + (expParameters.ntrialsPerGain - 1)) = gain_of_interest;
    stim1Stim2order(row_rw, counter: counter + (expParameters.ntrialsPerGain - 1)) = combine_rw_stim;
    counter = counter + expParameters.ntrialsPerGain;
end

%shuffles the order of stim1 & stim2 by column that way the assigned speeds stay with
%stim1 or stim2
randomOrder = randperm(expParameters.nTrials);
stim1Stim2order = stim1Stim2order(:, randomOrder);

%setting up first diffusion constant
for g = 1 : expParameters.numRetContTotal
    if stim1Stim2order(row_gain,1) == eval(strcat('expParameters.Gain', num2str(g)))
        difCon = difConVector(g,1);
    end
end

%sending the gains to icandi
threeStimGaincommand = sprintf('GainI#%1.3f#%1.3f#%1.3f#',stim1Stim2order(row_gain,1), stim1Stim2order(row_gain,1), stim1Stim2order(row_gain,1));
netcomm('write',SYSPARAMS.netcommobj, int8(threeStimGaincommand));

[~, indexforclosestdifCon] = min(abs(true_diffusionConstants - difCon));

rw10paths = rwpaths_given_trueDCs.(sprintf('dcIndex%d',indexforclosestdifCon));
path_options = randperm(10);
pathChoice = path_options(1);

%IF Left Stimulus, then left stimulus is moving testGain and doing random walk
if stim1Stim2order(row_rw, 1) == 1
    
    aom1offx(startFramestim1: endFramestim1) = round(rw10paths(:,xColumn,pathChoice));
    aom1offy(startFramestim1: endFramestim1) = round(rw10paths(:,yColumn,pathChoice).*expParameters.field_Y_adjust);
                                                
    %UPDATING THE GAINS SO THAT LEFT SIMULUS IS MOVING
    % GainI#irval#rdval#grval# /*Set independent Stimulus gain to any value between -3.0 to 2.0 for each channel */
    aom1gain(startFramestim2: endFramestim2) = stim1Stim2order(row_gain,1);
    
    %otherwise Right stimulus is moving testGain and doing random walk
else
    aom1offx(startFramestim2:endFramestim2) = round(rw10paths(:,xColumn,pathChoice));
    aom1offy(startFramestim2:endFramestim2) = round(rw10paths(:,yColumn,pathChoice).*expParameters.field_Y_adjust);
    
    %UPDATING GAINS SO THAT RIGHT STIMULUS IS MOVING
    % GainI#irval#rdval#grval# /*Set independent Stimulus gain to any value between -3.0 to 2.0 for each channel */
    aom1gain(startFramestim1: endFramestim1) = stim1Stim2order(row_gain,1);
end

% Other stimulus sequence factors
stimbeep = zeros(size(aom1seq)); % ICANDI will ding on every frame where this is set to "1"
stimbeep(startFramestim1) = 1; % I usually have the system beep on the first frame of the presentation sequence

% Set up movie parameters, passed to ICANDI via "PlayMovie"
Mov.duration  = expParameters.videoDurationFrames;
Mov.aom0seq   = aom0seq;
Mov.aom0pow   = aom0pow;
Mov.aom0locx  = aom0locx;
Mov.aom0locy  = aom0locy;
Mov.aom0gain  = aom0gain;
Mov.aom0angle = zeros(size(aom0seq));

Mov.aom1seq   = aom1seq;
Mov.aom1pow   = aom1pow;
Mov.aom1offx  = aom1offx; % Shift of aom 1 (usually red) relative to IR; use this to correct x-TCA
Mov.aom1offy  = aom1offy; % As above, for y-dimension
Mov.aom1gain  = aom1gain;
Mov.aom1angle = zeros(size(aom1seq));

Mov.aom2seq   = aom2seq;
Mov.aom2pow   = aom2pow;
Mov.aom2offx  = aom2offx; % Green ch
Mov.aom2offy  = aom2offy; % Green ch
Mov.aom2gain  = aom2gain;
Mov.aom2angle = zeros(size(aom2seq));

Mov.aom0gain = aom1gain;
Mov.aom2gain = aom1gain;

%testing if this fixes bug
Mov.stimbeep = stimbeep;
Mov.frm = 1;
Mov.seq = '';

% Adjust these parameters to control which images/stimuli from the stimulus
% folder are loaded onto the FPGA board for potential playout

% Uploads circle and fixation cross image since Frameindex = 2 & 3
StimParams.fprefix = 'frame'; % ICANDI will try to load image files from the stimulus directory whose file names start with this (e.g. "frame2.bmp")
StimParams.sframe = 2; % Index of first loaded frame (i.e. "frame2")
StimParams.eframe = 4; % Index of last loaded frame (i.e. "frame4")
StimParams.fext = 'bmp';

%set up the movie parameters
Mov.dir = StimParams.stimpath;
Mov.suppress = 0;
Mov.pfx = StimParams.fprefix;

% Save responses and correct/incorrect here (Pre-allocate)
responseVector = nan(expParameters.numRetContTotal, expParameters.ntrialsPerGain);

%in case trials need repeating, save to this array
original_stim1stim2order = stim1Stim2order; %stim1stim2order is the original trial order, but if subject redos during exp, then the actual order is this one
trials_repeated =[];

ecc_diam = nan(2,5);
ecc_diam(1,:) = [0.25 0.5 1 2 4]; %these are eccentricities we're testing
ecc_diam(2,:) = [15 30 60 60 60];

% Make the circle and fixation cross templates;
circleDiam = ecc_diam(2, find(ecc_diam(1,:) == expParameters.eccentricity));

%if increment, it's ones and adjusted by redchannel power
if expParameters.increment == 1
    circleStim = double(Circle(round(circleDiam/2)))*expParameters.redChpow;
elseif expParameters.increment == 0 %if decrement
    circleStim = 1-double(Circle(round(circleDiam/2)));
end

if expParameters.field_Y_adjust == 0.5
    circleStim(2:2:circleDiam,:) = [];
end

% fixCross = ones(5,5);
fixCross_off = zeros(15,15);
fixCross_on = ones(15,15);

% Save as a .bmp
imwrite(circleStim, [expParameters.stimpath 'frame' num2str(frameIndexCircle) '.bmp']);
imwrite(fixCross_off, [expParameters.stimpath 'frame' num2str(frameIndexFix_off) '.bmp']);
imwrite(fixCross_on, [expParameters.stimpath 'frame' num2str(frameIndexFix_on) '.bmp']);

flashCommand = ['Flash#30#0#'];
netcomm('write',SYSPARAMS.netcommobj,int8(flashCommand));
Parse_Load_Buffers(0);

%creating counters
trialNum = 1;
first_n = 1;
second_n = 1;
if expParameters.numRetContTotal == 3
    third_n = 1;
end

% Initialize the experiment loop
presentStimulus = 1;
runExperiment = 1;
lastResponse = []; % start with this empty
getResponse = 0; % set to zero to force the first recognized button press to be the one that triggers the stimulus presentation
WaitSecs(1);

Speak('Begin experiment.');

while runExperiment == 1 % Experiment loop
    % Get the game pad input
    [gamePad, ~] = GamePadInput([]);
    
    %compare the last response
    if gamePad.buttonLeftUpperTrigger || gamePad.buttonLeftLowerTrigger % Start trial
        skip = 0;
        canRedo = 1;
        
        if ~isempty(lastResponse)
            
            if  presentStimulus == 1 
                if ~strcmp(lastResponse, 'redo')% if the response is NOT redo then log the most recent button press, then play stimulus sequence

                    if ansToWhichFaster == stim1Stim2order(row_rw, trialNum)
                        randWalkfaster = 1;
                    else
                        randWalkfaster = 0;
                    end
                    
                    % Update the Quest structure if it is a staircase trial
                    if stim1Stim2order(row_gain,trialNum) == expParameters.Gain1
                        responseVector(1,first_n) = ansToWhichFaster;
                        first_n = first_n+1;
                        [logSpeedTestStim] = dcToLogspeedteststim(difCon, expParameters.aosloFPS);
                        
                        %q=QuestUpdate(q,intensity,response)
                        %then you call QuestUpdate to report to Quest the actual intensity used and whether the observer got it right.
                        q(1,1) = QuestUpdate(q(1,1), logSpeedTestStim, randWalkfaster);
                    elseif stim1Stim2order(row_gain,trialNum) == expParameters.Gain2
                        responseVector(2,second_n) = ansToWhichFaster;
                        second_n = second_n+1;
                        [logSpeedTestStim] = dcToLogspeedteststim(difCon, expParameters.aosloFPS);
                        
                        q(2,1) = QuestUpdate(q(2,1), logSpeedTestStim, randWalkfaster);
                    else
                        responseVector(3, third_n) = ansToWhichFaster;
                        third_n = third_n+1;
                        [logSpeedTestStim] = dcToLogspeedteststim(difCon, expParameters.aosloFPS);
                        
                        q(3,1) = QuestUpdate(q(3,1), logSpeedTestStim, randWalkfaster);
                    end
                    
                    save(dataFile, 'q', 'expParameters', 'stim1Stim2order', 'testSequence', 'responseVector', 'questdifConVector', 'difConVector', 'circleDiam');
                end
                
                trialNum = trialNum+1;
                                    
                if trialNum > length(testSequence)  % Exit loop &  Terminate experiment
                    Beeper(400, 0.5, 0.15); WaitSecs(0.15); Beeper(400, 0.5, 0.15);  WaitSecs(0.15); Beeper(400, 0.5, 0.15);
                    Speak('Experiment complete');
                    TerminateExp;
                    
                    final_ppd_converter = (expParameters.ppdX+expParameters.ppdY)/2; %pixels/deg, averging the x and y's
                    
                    %converting from pixels^2/sec to armin^2/sec
                    difConVectorArcmin = difConVector /(final_ppd_converter^2)*3600; %converting from pixels^2 --> deg^2 --> arcmin^2
                    
                    %saving difConVector in arcmin^2/sec
                    save(dataFile, 'q', 'expParameters', 'stim1Stim2order', 'testSequence', 'responseVector', 'questdifConVector', 'difConVector', 'circleDiam', 'difConVectorArcmin', 'original_stim1stim2order', 'trials_repeated');
                    
                    figure
                    for stair = 1 : expParameters.numStaircases
                        subplot(1,expParameters.numStaircases,stair,'nextplot','add')
                        plot(1: size(difConVectorArcmin,2) ,difConVectorArcmin(stair, :), 'o')
                        hold on
                        
                        for n = 1: size(difConVectorArcmin,2)-1
                            if difConVectorArcmin(stair,n)< difConVectorArcmin(stair,n+1)
                                p1 = plot(n: n+1,difConVectorArcmin(stair, (n: n+1)), 'r-o', 'LineWidth', 1, 'MarkerSize', 4, 'MarkerFaceColor', 'r') ;
                                hold on
                            else
                                p2 = plot(n: n+1,difConVectorArcmin(stair, (n: n+1)), 'g-o', 'LineWidth', 1, 'MarkerSize', 4, 'MarkerFaceColor', 'g') ;
                                hold on
                            end
                        end
                        
                        set(gca, 'FontSize', 12)
                        set(gcf, 'Color', [1 1 1])
                        set(gca, 'LineWidth', 1.25)
                        box on
                        ylabel('Diffusion Constant (arcmin^2/sec)','FontSize',20);
                        title(sprintf('Gain %1.1f', eval(strcat('expParameters.Gain', num2str(stair)))));
                        xlabel('Trial Number','FontSize',20);
                        set(gca,'xlim',[1 size(difConVectorArcmin,2)]);
                        set(gca,'ylim',[0 max(difConVectorArcmin(stair,:)) + 1]);
                        set(gca,'FontSize',15)
                        text(20, difConVectorArcmin(stair, expParameters.ntrialsPerGain)+3, sprintf('Pt Equal = %1.3f', difConVectorArcmin(stair, expParameters.ntrialsPerGain)));
                        
                        if exist('p1','var') == 1 && exist('p2','var') == 1
                            legend([p1 p2],{'RWslower','RWfaster'})
                        elseif exist('p1','var') == 1 && exist('p2','var') == 0
                            legend(p1,{'RWslower'});
                        elseif exist('p1','var') == 0 && exist('p2','var') == 1
                            legend(p2,{'RWfaster'});
                        end
                        hold off;
                    end
                    
                    break
                else
                    
                    if first_n == 1 && stim1Stim2order(row_gain, trialNum) == expParameters.Gain1
                        skip = 1;
                    elseif second_n == 1&& stim1Stim2order(row_gain, trialNum) == expParameters.Gain2
                        skip = 1;
                    elseif exist('third_n', 'var') == 1 && third_n == 1&& stim1Stim2order(row_gain, trialNum) == expParameters.Gain3
                        skip = 1;
                    end
                    
                    if skip == 0
                        %updating the speedTestStim intensity via QuestQuantile
                        %intensity=QuestQuantile(q,[quantileOrder])
                        if stim1Stim2order(row_gain,trialNum) == expParameters.Gain1
                            newspeedTestStim = (10.^(QuestQuantile(q(1,1))));
                            [difCon] = speedteststimToDC(newspeedTestStim, expParameters.difConStart, expParameters.aosloFPS);
                            
                            questdifConVector(1,first_n) = difCon;
                        elseif stim1Stim2order(row_gain,trialNum) == expParameters.Gain2
                            newspeedTestStim = 10.^(QuestQuantile(q(2,1)));
                            [difCon] = speedteststimToDC(newspeedTestStim, expParameters.difConStart, expParameters.aosloFPS);
                            
                            questdifConVector(2,second_n) = difCon;
                        else
                            newspeedTestStim = 10.^(QuestQuantile(q(3,1)));
                            [difCon] = speedteststimToDC(newspeedTestStim, expParameters.difConStart, expParameters.aosloFPS);
                            
                            questdifConVector(3,third_n) = difCon;
                        end
                    end
                    
                    if stim1Stim2order(row_gain,trialNum) == expParameters.Gain1
                        difCon = questdifConVector(1,first_n);
                    elseif stim1Stim2order(row_gain,trialNum) == expParameters.Gain2
                        difCon = questdifConVector(2,second_n);
                    else
                        difCon = questdifConVector(3,third_n);
                    end
                    
                    %finding difcon closest to one of the options in 'true_diffusionConstants'
                    [~, indexforclosestdifCon] = min(abs(true_diffusionConstants - difCon));
                    
                    %keeping track of the truedifcons tested (since it rounds the Quest's output)
                    if stim1Stim2order(row_gain,trialNum) == expParameters.Gain1
                        difConVector(1,first_n) = true_diffusionConstants(indexforclosestdifCon);
                    elseif stim1Stim2order(row_gain,trialNum) == expParameters.Gain2
                        difConVector(2,second_n) = true_diffusionConstants(indexforclosestdifCon);
                    else
                        difConVector(3,third_n) = true_diffusionConstants(indexforclosestdifCon);
                    end

                    %selecting a RW path from the 10
                    rw10paths = rwpaths_given_trueDCs.(sprintf('dcIndex%d',indexforclosestdifCon));
                    path_options = randperm(10);
                    pathChoice = path_options(1); %chose the first value in randperm of 10
                    
                    %Updating stimulus to move, gain & random walk sequence,
                    if stim1Stim2order(row_rw, trialNum) == 1
                        
                        aom1offx(startFramestim1: endFramestim1) = round(rw10paths(:,xColumn,pathChoice));
                        aom1offy(startFramestim1: endFramestim1) = round(rw10paths(:,yColumn,pathChoice).*expParameters.field_Y_adjust);

                        aom1offx(startFramestim2: endFramestim2) = 0;
                        aom1offy(startFramestim2: endFramestim2) = 0;
                        
                        %update the Mov struct
                        Mov.aom1offx = aom1offx;
                        Mov.aom1offy = aom1offy;
                        
                        %UPDATING GAINS SO THAT SECOND STIMULUS IS RETINA-CONTINGENT
                        aom1gain = zeros(size(aom1seq));
                        aom1gain(startFramestim2: endFramestim2) = stim1Stim2order(row_gain,trialNum);
                        
                        Mov.aom1gain = aom1gain;
                        Mov.aom0gain = aom1gain;
                        Mov.aom2gain = aom1gain;
                        
                    else
                        
                        aom1offx(startFramestim2: endFramestim2) = round(rw10paths(:,xColumn,pathChoice));
                        aom1offy(startFramestim2: endFramestim2) = round(rw10paths(:,yColumn,pathChoice).*expParameters.field_Y_adjust);
                        
                        aom1offx(startFramestim1: endFramestim1) = 0;
                        aom1offy(startFramestim1: endFramestim1) = 0;
                        
                        %update the Mov struct
                        Mov.aom1offx = aom1offx;
                        Mov.aom1offy = aom1offy;
                        
                        %UPDATING GAINS SO THAT FIRST STIMULUS IS RETINA-CONTINGENT
                        aom1gain = zeros(size(aom1seq));
                        aom1gain(startFramestim1: endFramestim1) = stim1Stim2order(row_gain,trialNum);
                        
                        Mov.aom1gain = aom1gain;
                        Mov.aom0gain = aom1gain;
                        Mov.aom2gain = aom1gain;
                        
                    end
                end
            end
        end
        
        % Show the stimulus
        if presentStimulus == 1
            
            % Call Play Movie
            Mov.msg = ['Diffusion constant is: ' num2str(true_diffusionConstants(indexforclosestdifCon)) ...
                '; Trial ' num2str(trialNum) ' of ' num2str(length(testSequence))];
            setappdata(hAomControl, 'Mov',Mov);
            VideoParams.vidname = [expParameters.subjectID '_' sprintf('%03d',trialNum)];
            
            rasterCommand = sprintf('RasterFix#%d#', 1);
            netcomm('write',SYSPARAMS.netcommobj,int8(rasterCommand));
            
            if expParameters.aosloFPS == 60
                centerCommand = sprintf('LocUpdateAbs#%d#%d#', 256, 128);
                netcomm('write',SYSPARAMS.netcommobj,int8(centerCommand));
            else
                centerCommand = sprintf('LocUpdateAbs#%d#%d#', 256, 256);
                netcomm('write',SYSPARAMS.netcommobj,int8(centerCommand));
            end
            
            % added by Pavan to make use of locx,y so that IR derement
            % follows red increment
            Mov.aom0locx(:) = aom1offx;
            Mov.aom0locy(:) = aom1offy;
            
            %the red is offset from the IR channel, so since set the offsets (ie rw positions)
            % in aom0locx/y, we can set aom1offx/y to zero
            %(but only do this when 1 stim per frame, so didn't do this for peer stim exp)
            Mov.aom1offx(:) = 0;
            Mov.aom1offy(:) = 0;
            Mov.aom2offx(:) = 0;
            Mov.aom2offy(:) = 0;
            % end Pavan's edit
            
            setappdata(hAomControl, 'Mov', Mov);
            
            sprintf('TrialNum = %#1f',trialNum)
            sprintf('Gain = %#1f',stim1Stim2order(row_gain, trialNum))
            sprintf('RWstim = %#1f',stim1Stim2order(row_rw, trialNum))
            sprintf('QuestDifCon = %f',difCon)
            sprintf('trueDifCon = %f', true_diffusionConstants(indexforclosestdifCon))
            
            PlayMovie;
            
            getResponse = 1; % set getResponse to 1 (it will remain at 1 after the first trial)
            presentStimulus = 0; %to prevent the next trial from beingntriggered before one of the response buttons is pressed
        end
        
    elseif gamePad.buttonA % Right STIM2 in ICANDI (JD start collecting input from subject)
        if getResponse == 1 && canRedo == 1
            lastResponse = 'right';
            Beeper(300, 1, 0.15)
            ansToWhichFaster = 2;
            presentStimulus = 1;
        end
        
    elseif gamePad.buttonY % Left STIM2 in ICANDI
        if getResponse == 1 && canRedo == 1
            lastResponse = 'left';
            Beeper(300, 1, 0.15)
            ansToWhichFaster = 1;
            presentStimulus = 1;
        end
        
    elseif gamePad.buttonRightUpperTrigger || gamePad.buttonRightLowerTrigger %gamePad.buttonStart %redo button
        if getResponse == 1 && canRedo == 1
            lastResponse = 'redo';
            Speak('Re do');
            presentStimulus = 1;
            trials_repeated = [trials_repeated, trialNum];
            stim1Stim2order(:,end + 1) = stim1Stim2order(:, trialNum); %put this trial at the end and keep going
            stim1Stim2order(:,trialNum) = [];
            trialNum = trialNum - 1;
            canRedo = 0;
        end
        
    elseif gamePad.buttonBack %terminate button (if you hit end key on gamepad)
        if getResponse == 1
            lastResponse = 'terminate';
            Speak('experiment terminated');
            runExperiment = 0;
        end
    end
end

    function [dc] = speedteststimToDC(speedTestStim, difConStart, aosloFPS)
        dc = (2*aosloFPS)*(speedTestStim).^2; %to make linear, not exponential DC = 120x^2
        if dc < 0 % Min speed value
            dc = 0;
        elseif dc > difConStart
            dc = difConStart;
        end
    end

    function [logSpeedTestStim] = dcToLogspeedteststim(difCon, aosloFPS)
        logSpeedTestStim = log10(sqrt(difCon/(2*aosloFPS)));
    end

end