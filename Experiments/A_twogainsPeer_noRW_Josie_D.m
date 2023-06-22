%% Motion Perception experiment for AOMcontrol: 2 Gains with no Random Walk Method of Constant Stimulus Test
%There are 3 stimuli: fixation, L, & R
% 1. SET THE NUMBER OF TRIALS. 
%    Default is 100 trials shuffled and randomly presented to the subject
% 2. SET THE GAINS. 
%    Input two gain values to compare: "testGain" and "refGain", gains can be adjusted to any value between -3.0 to 2.0
%    Each side (stim1 and stim 2) will test half the trials as testGain the other half of the trials as refGain

% USEFUL INFO
% You can set gains to negative. or you can use angleseq to make it
% negative. If your angles are only 0 and 180, negative gain is easier

function A_twogainsPeer_noRW_Josie_D

global SYSPARAMS StimParams VideoParams;

% Not sure what this does, exactly
if exist('handles','var') == 0
    handles = guihandles;
end

startup;

% Get experiment config data stored in appdata for 'hAomControl'
hAomControl = getappdata(0,'hAomControl');

%------HARD-CODED PARAMETER STUFF FOLLOWS----------------------------------
use_params = input('Do you want to use previous params? y/n:  ','s');

if use_params == 'n'

    % if we do not want to use previous parameters - we can edit them here

    % Experiment parameters -- BASIC
    expParameters.subjectID = GetWithDefault('Subject ID','Test'); % Videos will save starting with this prefix
    expParameters.aosloPPD  = 545; % pixels per degree, adjust as needed
    expParameters.aosloFPS  = 30; % UCB frame rate, in Hz fast scanner is 16kHz. Slow scanner is 30Hz. Discrete stim at dif time points gives illusion that motion: Strobascopic display properties

    % Experiment parameters -- STIMULUS & VIDEO
    expParameters.testDurationMsec    = 1500; % Stimulus duration, in msec
    expParameters.testDurationFrames  = round(expParameters.aosloFPS*expParameters.testDurationMsec/1000); 
    expParameters.videoDurationMsec   = 2000; % Video duration, in msec
    expParameters.videoDurationFrames = round(expParameters.aosloFPS*(expParameters.videoDurationMsec/1000)); % Convert to frames
    expParameters.record              = 1; % Set to one if you want to record a video for each trial, set 0 if don't want video
    [expParameters.eccentricity]      = GetWithDefault('At what eccentricity is stimulus delivered', 0);
    [expParameters.circleDiam]        = GetWithDefault('Circle stimulus diameter', 30);
    [expParameters.nTrials]           = GetWithDefault('Number of trials total', 30); 
    
    [expParameters.turnFixCrossOnEntireTrial] = GetWithDefault('Turn fixation cross on entire trial (1--yes, keep on, 0--no, turn off)?', 1);
    
    % Experiment parameters -- GAINS 3 STIMULI
    [expParameters.fixCrossTrackingGain] = 0.002;
    [expParameters.Gain1]                = GetWithDefault('Gain of ref stimulus (first)', 1); %retina-contingent Stimulus (not RW)
    [expParameters.Gain2]                = GetWithDefault('Gain of ref stimulus (second)', 1); %retina-contingent Stimulus (not RW)    
    
    save('ExpParams.mat', 'expParameters')
    
elseif use_params == 'y'
    load('ExpParams.mat')
end


%------END HARD-CODED PARAMETER SECTION------------------------------------
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
%     Parse_Load_Buffers(1); % Not sure about what this does when called in this way
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

%Turning on AllChannelImaging in iCANDI
allChImageCommand = sprintf('AllChImaging#%d#',1);
netcomm('write',SYSPARAMS.netcommobj,int8(allChImageCommand));
pause(0.5);

%Turning on Dual Stimuli Mode
dualStimCommand = sprintf('DualStim#%d#',1);
netcomm('write',SYSPARAMS.netcommobj,int8(dualStimCommand));
pause(0.5);

%DOUBLE CHECK THAT THIS IS WORKING JD 2-7-22
% LocUser#x#y# /*Update stimulus position with absolute x and y positions*/
centerCommand = sprintf('LocUpdateAbs#%d#%d#', 256, 256);
netcomm('write',SYSPARAMS.netcommobj,int8(centerCommand));
pause(0.5);

% Setting Raster & Location commands
rasterCommand = sprintf('RasterFix#%d#', 1);
netcomm('write',SYSPARAMS.netcommobj,int8(rasterCommand));

%% Main experiment loop

frameIndexFix = 2; %The index of the fixation cross stimulus bitmap
frameIndexCircle = 3; % The index of the stimulus bitmap

% Generate the frame sequence for each AOSLO channel; these get stored in
% the "Mov" structure A stimulus "sequence" is a 1XN vector where N is the
% number of frames in the trial video; a one-second trial will have N
% frames, where N is your system frame rate. The values in these vectors
% will control what happens on each video frame, stimulus-wise. Most stuff
% will happen in the IR channel (aom 0), so a lot of this is just setting
% up and passing along zero-laden vectors.

% Place stimulus in the middle of the trial video

startFrame = 1; % the frame at which it starts presenting stimulus
endFrame = startFrame+expParameters.testDurationFrames-1;

%AOM0 (IR) parameters FIXATION CROSS

aom0seq = zeros(1,expParameters.videoDurationFrames);
aom0seq(1:expParameters.videoDurationFrames) = frameIndexFix;

%turn off cross during stimulus presenation
if expParameters.turnFixCrossOnEntireTrial == 0
    aom0seq(startFrame:endFrame) = 1;
%     aom0seq(end-2:end) = 1; %CHECK THIS! 1/4/23
end

% aom0seq(2) = frameIndex;
% "aom0locx" allows you to shift the location of the IR stimulus relative
% to the tracked location on the reference frame (or in the raster,
% depending on tracking gain). Units are in pixels.

aom0locx = zeros(size(aom0seq)); 
aom0locy = zeros(size(aom0seq)); % same as above, but for y-dimension
aom0pow  = ones(size(aom0seq));
aom0gain = expParameters.Gain1*ones(size(aom0seq));

%AOM1 (RED, tyically) parameters STIMULUS 1 Left
%set default aom[x]seq to 1 to be blank, if you set it to 0 then black squares will appear in these frames
aom1seq             = ones(1,expParameters.videoDurationFrames);
% aom1seq(1:endFrame) = frameIndexCircle;
aom1seq(1:expParameters.videoDurationFrames) = frameIndexCircle;
aom1pow             = ones(size(aom0seq));
aom1offx            = zeros(size(aom0seq))+128;
aom1offy            = zeros(size(aom0seq));

%AOM2 (GREEN, typically) paramaters STIMULUS 2 Right
aom2seq             = ones(1,expParameters.videoDurationFrames);
% aom2seq(1:endFrame) = frameIndexCircle;
 aom2seq(1:expParameters.videoDurationFrames) = frameIndexCircle;
aom2pow             = ones(size(aom0seq));
aom2offx            = zeros(size(aom0seq))-128;
aom2offy            = zeros(size(aom0seq));

%tracking gains here
gain_stim1 = nan(1, expParameters.nTrials);
gain_stim2 = nan(1, expParameters.nTrials);

%setting up stim1 and stim2--this makes random order for gains. 
stim1Stim2order = nan(1, expParameters.nTrials); 
stim1Stim2order(1,:) = [ones(1,expParameters.nTrials/2) 2.* ones(1, expParameters.nTrials/2)];

%shuffles the order of stim1 & stim2 by column that way the assigned speeds stay with
%stim1 or stim2
randomOrder = randperm(expParameters.nTrials);
stim1Stim2order = stim1Stim2order(randomOrder);

%IF 1, then left stimulus is testGain and right stimulus is refGain
if stim1Stim2order(1, 1) == 1
    % GainI#irval#rdval#grval# /*Set independent Stimulus gain to any value between -3.0 to 2.0 for each channel */

    threeStimGaincommand = sprintf('GainI#%1.3f#%1.3f#%1.3f#',expParameters.fixCrossTrackingGain, expParameters.Gain1, expParameters.Gain2);
    netcomm('write',SYSPARAMS.netcommobj, int8(threeStimGaincommand));

    aom1gain = expParameters.Gain1*ones(size(aom1seq));
    aom2gain = expParameters.Gain2*ones(size(aom2seq));
    
    gain_stim1(1,1) = expParameters.Gain1;
    gain_stim2(1,1) = expParameters.Gain2;

%otherwise Right stimulus is testGain and left stimulus is refGain
else
    % GainI#irval#rdval#grval# /*Set independent Stimulus gain to any value between -3.0 to 2.0 for each channel */
    threeStimGaincommand = sprintf('GainI#%1.3f#%1.3f#%1.3f#',expParameters.fixCrossTrackingGain, expParameters.Gain2, expParameters.Gain1);
    netcomm('write',SYSPARAMS.netcommobj, int8(threeStimGaincommand));

    aom1gain = expParameters.Gain2*ones(size(aom2seq));
    aom2gain = expParameters.Gain1*ones(size(aom1seq));
    
    gain_stim1(1,1) = expParameters.Gain2;
    gain_stim2(1,1) = expParameters.Gain1;
end
    
% Other stimulus sequence factors 
stimbeep = zeros(size(aom1seq)); % ICANDI will ding on every frame where this is set to "1"
stimbeep(startFrame) = 1; % I usually have the system beep on the first frame of the presentation sequence

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
Mov.aom2offx  = aom2offx; % Green TCA correction
Mov.aom2offy  = aom2offy; % Green TCA correction
Mov.aom2gain  = aom2gain;
Mov.aom2angle = zeros(size(aom2seq));

%testing if this fixes bug
Mov.stimbeep = stimbeep;
Mov.frm = 1;
Mov.seq = '';

% Adjust these parameters to control which images/stimuli from the stimulus
% folder are loaded onto the FPGA board for potential playout

% Uploads circle and fixation cross image since Frameindex = 2 & 3
StimParams.fprefix = 'frame'; % ICANDI will try to load image files from the stimulus directory whose file names start with this (e.g. "frame2.bmp")
StimParams.sframe = 2; % Index of first loaded frame (i.e. "frame2") 
StimParams.eframe = 3; % Index of last loaded frame (i.e. "frame4")
StimParams.fext = 'bmp';

%set up the movie parameters
Mov.dir = StimParams.stimpath;
Mov.suppress = 0;
Mov.pfx = StimParams.fprefix;

% Generate the acuity test sequence
testSequence = (1:1:expParameters.nTrials);

% Save responses and correct/incorrect here (Pre-allocate)
responseVector = nan(length(testSequence),1);

% Make the circle and fixation cross templates;
circleDiam = expParameters.circleDiam;
circleStim = 1-double(Circle(round(circleDiam/2)));

fixCross = ones(5,5);
fixCross(:,3) = 0;
fixCross(3,:) = 0;
resizeFactor = 5;
fixCross = imresize(fixCross, resizeFactor, 'nearest');

% Save as a .bmp
imwrite(circleStim, [expParameters.stimpath 'frame' num2str(frameIndexCircle) '.bmp']);
imwrite(fixCross, [expParameters.stimpath 'frame' num2str(frameIndexFix) '.bmp']);

flashCommand = ['Flash#30#0#'];
netcomm('write',SYSPARAMS.netcommobj,int8(flashCommand));
Parse_Load_Buffers(0);
updatestimCommand = ('Update#2#1#1#');
netcomm('write',SYSPARAMS.netcommobj,int8(updatestimCommand));

% Initialize the experiment loop
presentStimulus = 1;
trialNum = 1;
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
        
         if ~isempty(lastResponse) %this only applies the first loop through?
            if ~strcmp(lastResponse, 'redo') && presentStimulus == 1 % if the response is NOT redo then log the most recent button press, then play stimulus sequence
                
                responseVector(trialNum,1) = ansToWhichFaster;
                %figure out how to save dataFile JD
                save(dataFile, 'expParameters', 'stim1Stim2order', 'testSequence', 'responseVector', 'gain_stim1', 'gain_stim2');

                trialNum = trialNum+1;

                if trialNum > length(testSequence) % Exit loop &  Terminate experiment
                    Beeper(400, 0.5, 0.15); WaitSecs(0.15); Beeper(400, 0.5, 0.15);  WaitSecs(0.15); Beeper(400, 0.5, 0.15);
                    Speak('Experiment complete');
                    TerminateExp;
                    
                    gains_table = { strcat('Gain',num2str(expParameters.Gain1)),strcat('Gain',num2str(expParameters.Gain2))};%{num2str(expParameters.Gain1), num2str(expParameters.Gain2)});
%                     for i = 1 : length(gains_table)
%                         trials_of_interest = gain_stim1 ==gains_table(i);
%                         percent_correct(i) = sum(responseVector(trials_of_interest) == 1)/length(responseVector(trials_of_interest));
%                     end
                    data = table();
                    data.stim1 = gain_stim1';
                    data.response = responseVector;
                    
                    percentCorrectgain2 = (length(find(data.stim1 == expParameters.Gain1 & data.response == 2)) + length(find(data.stim1 == expParameters.Gain2 & data.response == 1)))/expParameters.nTrials;
                    percentCorrectgain1 = 1-percentCorrectgain2;
                    
                    percent_correct = [percentCorrectgain1, percentCorrectgain2];
                    figure
                    
                    hbar = bar(percent_correct);
                    x = get(hbar,'XData');
                    y = get(hbar,'YData');
                     
                    %for gain1
                    htext = text(x(1), y(1), gains_table{1});
                    set(htext, 'VerticalAlignment', 'bottom', 'HorizontalAlignment','center')
                    
                    htext = text(x(2), y(2), gains_table{2});
                    set(htext, 'VerticalAlignment', 'bottom', 'HorizontalAlignment','center')

                    ylabel(strcat('Percent trials seen faster'), 'FontSize', 20);
                    title('Results', 'FontSize', 20);
                    set(gca, 'ylim', [0 1]);
                    break
                else                    
                    %Updating stimulus to move, gain & random walk sequence, 
                    if stim1Stim2order(1, trialNum) == 1

                        %UPDATING GAINS SO THAT LEFT STIMULUS IS testGain
                        threeStimGaincommand = sprintf('GainI#%1.3f#%1.3f#%1.3f#',expParameters.fixCrossTrackingGain, expParameters.Gain1, expParameters.Gain2);
                        netcomm('write',SYSPARAMS.netcommobj, int8(threeStimGaincommand));

                        Mov.aom1gain = expParameters.Gain1*ones(size(aom1seq));
                        Mov.aom2gain = expParameters.Gain2*ones(size(aom2seq));
                        
                        gain_stim1(1,trialNum) = expParameters.Gain1;
                        gain_stim2(1,trialNum) = expParameters.Gain2;

                    else
                        %UPDATING GAINS SO THAT RIGHT STIMULUS IS testGain
                        threeStimGaincommand = sprintf('GainI#%1.3f#%1.3f#%1.3f#',expParameters.fixCrossTrackingGain, expParameters.Gain2, expParameters.Gain1);
                        netcomm('write',SYSPARAMS.netcommobj, int8(threeStimGaincommand));
                        
                        Mov.aom1gain = expParameters.Gain2*ones(size(aom2seq));
                        Mov.aom2gain = expParameters.Gain1*ones(size(aom1seq));
                        
                        gain_stim1(1,trialNum) = expParameters.Gain2;
                        gain_stim2(1,trialNum) = expParameters.Gain1;
                    end
                    
                end   
            end
        end

            % Show the stimulus
         if presentStimulus == 1 
            
            % Call Play Movie
            Mov.msg = ['Trial ' num2str(trialNum) ' of ' num2str(length(testSequence))];
            setappdata(hAomControl, 'Mov',Mov);
            VideoParams.vidname = [expParameters.subjectID '_' sprintf('%03d',trialNum)];
        
            PlayMovie;
            
            getResponse = 1; %set getResponse to 1 (it will remain at 1 after the first trial)
            presentStimulus = 0; %to prevent the next trial from beingntriggered before one of the response buttons is pressed
         end

    elseif gamePad.buttonB % Right STIM2 in ICANDI (JD start collecting input from subject)
        if getResponse == 1
            lastResponse = 'right';
            Beeper(300, 1, 0.15)
            ansToWhichFaster = 2;
            presentStimulus = 1;
        end    

    elseif gamePad.buttonX % Left STIM2 in ICANDI
        if getResponse == 1
            lastResponse = 'left';
            Beeper(300, 1, 0.15)
            ansToWhichFaster = 1;
            presentStimulus = 1;
        end

    elseif gamePad.buttonRightUpperTrigger || gamePad.buttonRightLowerTrigger %gamePad.buttonStart %redo button
        if getResponse == 1
            lastResponse = 'redo';
            Speak('Re do');
            presentStimulus = 1;
        end

    elseif gamePad.buttonBack %terminate button (if you hit end key on gamepad)
        if getResponse == 1
            lastResponse = 'terminate';
            Speak('experiment terminated');
            runExperiment = 0;
            
        end
    end
end