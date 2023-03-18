%% Motion Perception experiment for AOMcontrol: Quest Decrement Staircase_Josie_D
% 3 stimuli: fixation(aom0), L/Up(aom1), & R/Down(aom2)
% 1. SET THE STARTING testSpeed YOU WANT TO TEST.
%    The test stimulus goes on a random walk, the speed is "testSpeed",  
%     "testSpeed" gets updated with every trial via Quest Staircase
% 2. SET THE logGuessSpeed
% 3. SET THE GAINS. 
%    The test stimulus has gain = 0.002, it goes on the random walk 
%    The reference stimulus has a gain of any value between -3.0 to 2.0

% USEFUL INFO
% You can set gains to negative. or you can use angleseq to make it
% negative. If your angles are only 0 and 180, negative gain is easier

%commented out the digital marks commmand and uncommented teh Gain commands
%(pavan will have digital marks play via gain, not digital marks 10/25/22 JD)

function A_decOrInc_PEER_Josie_D_30Hzor60Hz_VorH_fieldadjust

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
    [expParameters.aosloFPS] = GetWithDefault('Is this 30Hz or 60Hz exp?', 60); % frame rate, in Hz fast scanner is 16kHz. Slow scanner is 30Hz. Discrete stim at dif time points gives illusion that motion: Strobascopic display properties
    [expParameters.expTypePeerOrVertical] = GetWithDefault('Peer_L/R (1) or Vertical_U/D experiment (0)?',1);
    
    if expParameters.aosloFPS == 60
        [expParameters.doublingFieldTF] = GetWithDefault('Are you doubling the vertical field? 1--yes, 0--n', 0);
        if expParameters.doublingFieldTF == 1
            [expParameters.field_Y_adjust] =1/2;
        elseif expParameters.doublingFieldTF == 0
            [expParameters.field_Y_adjust] =1;
        end
    else
        [expParameters.field_Y_adjust] =1;
    end
    
    % Experiment parameters -- STIMULUS & VIDEO
    expParameters.testDurationMsec    = 1500; % 'Timing: enter duration in msc', 
    expParameters.testDurationFrames  = round(expParameters.aosloFPS*expParameters.testDurationMsec/1000); 
    expParameters.videoDurationMsec   = 2000; %'Timing: enter full video duration in msc'
    expParameters.videoDurationFrames = round(expParameters.aosloFPS*(expParameters.videoDurationMsec/1000)); % Convert to frames
    expParameters.record              = 1; 
    
    [expParameters.increment]         = GetWithDefault('Is stimulus increment? (1--increment, 0--decrement)', 1);
    
    if expParameters.increment == 1
        [expParameters.redChpow]      = GetWithDefault('How much reduce the red power by?', 0.3);
        [expParameters.redChpow0AOm]  = GetWithDefault('How much reduce the red power by?', 0.4); %will see if this makes ir dec go away, and just show adjusted incr (since converted 8bit to 14bit),i will adjust after running on a subject if they see a difference 2/24/23
        [expParameters.rasterCancelTF] = GetWithDefault('Raster canceld? 1--yes, 0--n', 1);
%         [expParameters.redChpow]       = GetWithDefault('How much reduce the red power by?', 0.8);
%         [expParameters.redChimgpow]    = GetWithDefault('How much power for imaging in red?', 0.5);    
    end
    
    % Experiment parameters -- setting up Stimuli & Fixation Cross parameters
    [expParameters.eccentricity]              = GetWithDefault('At what eccentricity is stimulus delivered', 0);
    [expParameters.circleDiam]                = GetWithDefault('Circle stimulus diameter', 30);
    [expParameters.turnFixCrossOnEntireTrial] = GetWithDefault('Turn fixation cross on entire trial (1--yes, keep on, 0--no, turn off)?', 1);
    
    if expParameters.expTypePeerOrVertical == 1
        expParameters.stim1_offx = -128;
        expParameters.stim1_offy = 0;
        expParameters.stim2_offx = 128;
        expParameters.stim2_offy = 0;
        expParameters.crossOffx  = 0;
        
         %setting gamepad keys
        stim1 = 'X'; %left 
        stim2 = 'B'; %right
    else
        expParameters.stim1_offx = 128;
        expParameters.stim1_offy = -86; %upper stimulus
        expParameters.stim2_offx = 128;
        expParameters.stim2_offy = 86; %lower stimulus
        expParameters.crossOffx  = -128;
        
        if expParameters.aosloFPS == 60
             expParameters.stim1_offy = expParameters.stim1_offy/2;
             expParameters.stim2_offy = expParameters.stim2_offy/2;
        end
        
        %setting gamepad keys
        stim1 = 'A'; %Top 
        stim2 = 'Y'; %Down
    end
    
    % Experiment parameters -- GAINS 3 STIMULI
    expParameters.numRetContTotal        = GetWithDefault('How many gains to test (2 or 3)?', 3);
    [expParameters.rWGain]               = 0.002; % RW stimulus
    [expParameters.fixCrossTrackingGain] = 0.002;
    [expParameters.Gain1]                = GetWithDefault('Gain of ref stimulus (first)', -1.5); %retina-contingent Stimulus (not RW)
    [expParameters.Gain2]                = GetWithDefault('Gain of ref stimulus (second)', 1.5); %retina-contingent Stimulus (not RW)
    [expParameters.ntrialsGain1]  = 30;%maek sure even
    [expParameters.ntrialsGain2]  = 30;%maek sure even
    
    if expParameters.numRetContTotal == 3
        [expParameters.Gain3]     = GetWithDefault('Gain of ref stimulus (third)', 0.002); %retina-contingent Stimulus (not RW)
        [expParameters.ntrialsGain3] = 10; %maek sure even
        [expParameters.nTrials]         = expParameters.ntrialsGain1+expParameters.ntrialsGain2+expParameters.ntrialsGain3;
    else
        [expParameters.nTrials]         = expParameters.ntrialsGain1+expParameters.ntrialsGain2;
    end
    
    expParameters.nChoices        = 2; %2AFC
    
    [expParameters.difConStart]   = GetWithDefault('Starting diffusion constant:', 2940); %random walk starting speed (since speedTestStim to start is 5 pixels)
    [expParameters.ppdX]          = GetWithDefault('ppd_x:', 303);
    [expParameters.ppdY]          = GetWithDefault('ppd_y:', 306); %pixels per degree
    
    % Experiment parameters -- STAIRCASE/QUEST 
    expParameters.staircaseType   = 'Quest';
    expParameters.numStaircases   = expParameters.numRetContTotal; % Interleave staircases? Set to >1
    expParameters.offset          = 0;
    [expParameters.guessdifCon]   = GetWithDefault('Guess diffusion constant: ', 540); %where guess-speedTestStim is 3 pixels
    expParameters.tGuessSd        = 2; % Width of Bayesian prior, in log units (from -1 to 10, since log -1 = 1, and log10 =1)
    expParameters.pThreshold      = .5; % If 4AFC, halfway between 100% and guess rate (25%) = .625
  
    % updated to .8 for jitter exp.
    expParameters.beta  = 3.5;  % Slope of psychometric function
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

%Turning on AllChannelImaging in iCANDI
allChImageCommand = sprintf('AllChImaging#%d#',1); %on since this is three stim per frame
netcomm('write',SYSPARAMS.netcommobj,int8(allChImageCommand));
pause(0.5);

%Turning on Dual Stimuli Mode
dualStimCommand = sprintf('DualStim#%d#',1); %on since this is three stim per frame
netcomm('write',SYSPARAMS.netcommobj,int8(dualStimCommand));
pause(0.5);

%for increment experiment
if expParameters.increment == 1
    %Update IR power to 1 since imaging in IR 2/22/23
    irpowerCommand = sprintf('UpdatePower#0#1#');
    netcomm('write',SYSPARAMS.netcommobj,int8(irpowerCommand));
    pause(0.5);
    
    %FIX THIS SINCE I THINK THAT THIS HSOULD BE 1 NOT 2!! 2/15/23
    %Update red power to expParameters.redChimgpow
%     powerCommand = sprintf('UpdatePower#2#%1.1f#', expParameters.redChimgpow);
    powerCommand = sprintf('UpdatePower#1#0#');
    netcomm('write',SYSPARAMS.netcommobj,int8(powerCommand));
    pause(0.5);
    
    %Update green power to 0 %I should set to 1 since three stim? test this 2/22/23
    grpowerCommand = sprintf('UpdatePower#2#0#');
    netcomm('write',SYSPARAMS.netcommobj,int8(grpowerCommand));
    pause(0.5);
end

%2-15-23  I PUT RASTER BEFORE LOCUSER, CHECK THAT HTIS DOESN'T CHANGEYTHING% Setting Raster & Location commands
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
pause(0.5);


%% Main experiment loop

frameIndexFix = 2; %The index of the fixation cross stimulus bitmap
frameIndexCircle = 3; % The index of the stimulus bitmap

% Place stimulus in the middle of the trial video
startFrame = 1; % the frame at which it starts presenting stimulus
endFrame = startFrame+expParameters.testDurationFrames;

%creating 10 RW's for each possible Diffusion Constant
[~, true_diffusionConstants, rwpaths_given_trueDCs, xColumn, yColumn] = ...
    create10RWclosestToDC(expParameters.aosloFPS, expParameters.testDurationMsec/1000, endFrame, rootFolder, fileName, expParameters.difConStart);

%FOR DECREMENET: set default aom[x]seq to 1 to be blank, if you set it to 0 then black squares will appear in these frames
%FOR INCREMENT: set default aom[x]seq to 0 to be blank, if you set it to 1 then black squares will appear in these frames

%AOM0 (IR) parameters FIXATION CROSS
if expParameters.increment == 1
    aom0seq = zeros(1,expParameters.videoDurationFrames);
else
    aom0seq = ones(1,expParameters.videoDurationFrames);
end

aom0seq(1:expParameters.videoDurationFrames) = frameIndexFix;

%turn off cross during stimulus presenation
if expParameters.turnFixCrossOnEntireTrial == 0
    if expParameters.increment == 1
        aom0seq(startFrame:endFrame) = 0;
    else
        aom0seq(startFrame:endFrame) = 1;
    end
end

aom0locx = zeros(size(aom0seq))+expParameters.crossOffx; 
aom0locy = zeros(size(aom0seq)); 
aom0pow  = ones(size(aom0seq)); %imaging in IR in increment case, so keep on for both
aom0gain = expParameters.fixCrossTrackingGain*ones(size(aom0seq));

%AOM1 (RED, tyically) parameters STIMULUS 1 Left
%set default aom[x]seq to 1 to be blank, if you set it to 0 then black squares will appear in these frames
if expParameters.increment == 1
    aom1seq         = zeros(1,expParameters.videoDurationFrames);
    aom1pow         = zeros(size(aom0seq));
else
    aom1seq         = ones(1,expParameters.videoDurationFrames);
    aom1pow         = ones(size(aom0seq));
end

aom1offx            = zeros(size(aom0seq))+expParameters.stim1_offx;
aom1offy            = zeros(size(aom0seq))+expParameters.stim1_offy; %up stim
aom1gain            = expParameters.fixCrossTrackingGain*ones(size(aom0seq)); %since dummy trial

%AOM2 (GREEN, typically) paramaters STIMULUS 2 Right
if expParameters.increment == 1
    aom2seq         = zeros(1,expParameters.videoDurationFrames);
    aom2pow         = zeros(size(aom0seq));
else
    aom2seq         = ones(1,expParameters.videoDurationFrames);
    aom2pow         = ones(size(aom0seq));
end

aom2offx            = zeros(size(aom0seq))+expParameters.stim2_offx;
aom2offy            = zeros(size(aom0seq))+expParameters.stim2_offy; %down stim
aom2gain            = expParameters.fixCrossTrackingGain*ones(size(aom0seq)); %since dummy trial

% Generate the trials sequence
testSequence = (1:1:expParameters.nTrials);

%assigning variables
%assigning variables
questdifConVector      = nan(expParameters.numRetContTotal, expParameters.ntrialsGain1); %row 1 is FirstGain and row2 is SecondGain, etc
questdifConVector(:,1) = expParameters.difConStart;

%creating vector to track the actual diffusion constants tested , chosen from the options in 'true_diffusionConstants'
difConVector = nan(size(questdifConVector));
difConVector(:,1) = expParameters.difConStart;

%defining rows for easier read
row_rw   = 1;
row_gain = 2;

% row one defines which stimulus (either 1 or 2) goes on random walk, row two defines the gain of the retina-contingent stimulus
stim1Stim2order = nan(2, expParameters.nTrials); 
counter = 1;

for g = 1:expParameters.numRetContTotal
    combine_rw_stim = [];
    for s = 1:expParameters.nChoices
        numtrialgexp = strcat('expParameters.ntrialsGain', num2str(g)); 
        numtrialg = eval(numtrialgexp);
        cur_rwStim = s.*ones(1,numtrialg/expParameters.nChoices);
        combine_rw_stim = [combine_rw_stim cur_rwStim];
    end
    
    eachGain = strcat('expParameters.Gain', num2str(g)); 
    gain_of_interest = eval(eachGain).*ones(1,numtrialg);
    
    stim1Stim2order(row_gain, counter: counter + (numtrialg - 1)) = gain_of_interest;
    stim1Stim2order(row_rw, counter: counter + (numtrialg - 1)) = combine_rw_stim;
    counter = counter + numtrialg;
    
end

%shuffles the order of stim1 & stim2 by column that way the assigned speeds stay with
%stim1 or stim2
randomOrder = randperm(expParameters.nTrials);
stim1Stim2order = stim1Stim2order(:, randomOrder);

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
Mov.aom1offx  = aom1offx;
Mov.aom1offy  = aom1offy;
Mov.aom1gain  = aom1gain;
Mov.aom1angle = zeros(size(aom1seq));

Mov.aom2seq   = aom2seq;
Mov.aom2pow   = aom2pow;
Mov.aom2offx  = aom2offx;
Mov.aom2offy  = aom2offy;
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

% Save responses
responseVector = nan(expParameters.numRetContTotal, expParameters.ntrialsGain1);

%in case trials need repeating, save to this array
original_stim1stim2order = stim1Stim2order; %stim1stim2order is the original trial order, but if subject redos during exp, then the actual order is this one
trials_repeated =[];

% Make the circle and fixation cross templates;
if expParameters.increment == 1
    circleStim = double(Circle(round(expParameters.circleDiam/2)))*expParameters.redChpow; % removed '1 -' since it's increment
else
    circleStim = 1-double(Circle(round(expParameters.circleDiam/2))); % '1 -' since it's decrement
end

fixCross = ones(5,5);
resizeFactor = 5;
if expParameters.increment == 1
    fixCross = 1- fixCross;
    fixCross(:,3) = expParameters.redChpow0AOm; %in increment case, the IR distorts the red fixation cross, so I just make a square for now, but Iwill adjust once run subject 2/24/23
    fixCross(3,:) = expParameters.redChpow0AOm;
else
    fixCross(:,3) = 0;
    fixCross(3,:) = 0;
end
fixCross = imresize(fixCross, resizeFactor, 'nearest');

if expParameters.field_Y_adjust == 0.5
    circleStim(2:2:expParameters.circleDiam,:) = [];
    fixCross(2:2:size(fixCross,1),:) = [];
end

% Save as a .bmp
imwrite(circleStim, [expParameters.stimpath 'frame' num2str(frameIndexCircle) '.bmp']);
imwrite(fixCross, [expParameters.stimpath 'frame' num2str(frameIndexFix) '.bmp']);

% flashCommand = ['Flash#30#0#'];
flashCommand = sprintf('Flash#%1.f#0#',expParameters.aosloFPS);                  
netcomm('write',SYSPARAMS.netcommobj,int8(flashCommand));
Parse_Load_Buffers(0);

updatestimCommand = ('Update#2#1#1#');
netcomm('write',SYSPARAMS.netcommobj,int8(updatestimCommand));

%creating counters
trialNum = 0;
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
                if ~strcmp(lastResponse, 'redo') % if the response is NOT redo then log the most recent button press, then play stimulus sequence
                    
                    if trialNum == 0
                        aom1seq(1:endFrame) = frameIndexCircle;
                        aom2seq(1:endFrame) = frameIndexCircle;  
                        
                        Mov.aom1seq   = aom1seq;
                        Mov.aom2seq   = aom2seq;
                    else
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
                        
                        %save data
                        save(dataFile, 'q', 'expParameters', 'stim1Stim2order', 'testSequence', 'responseVector', 'questdifConVector', 'difConVector');
                    end
                end
                trialNum = trialNum+1;
                
                if trialNum > length(testSequence) % Exit loop &  Terminate experiment
                    Beeper(400, 0.5, 0.15); WaitSecs(0.15); Beeper(400, 0.5, 0.15);  WaitSecs(0.15); Beeper(400, 0.5, 0.15);
                    Speak('Experiment complete');
                    TerminateExp;
                    
                    final_ppd_converter = (expParameters.ppdX+expParameters.ppdY)/2; %pixels/deg, averging the x and y's
                    
                    %converting from pixels^2/sec to armin^2/sec
                    difConVectorArcmin = difConVector /(final_ppd_converter^2)*3600; %converting from pixels^2 --> deg^2 --> arcmin^2
                    
                    %saving difConVector in arcmin^2/sec
                    save(dataFile, 'q', 'expParameters', 'stim1Stim2order', 'testSequence', 'responseVector', 'questdifConVector','difConVector', 'difConVectorArcmin', 'original_stim1stim2order', 'trials_repeated');
                    
                    %plotting all data
                    figure
                    for stair = 1 : expParameters.numStaircases
                        numtrialgexp = strcat('expParameters.ntrialsGain', num2str(stair)); 
                        numtrialg = eval(numtrialgexp);
                        subplot(1,expParameters.numStaircases,stair,'nextplot','add')
                        plot(1: numtrialg ,difConVectorArcmin(stair, 1:numtrialg), 'o')
                        hold on
                        
                        for n = 1: numtrialg-1
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
                        set(gca,'xlim',[1 numtrialg]);
                        set(gca,'ylim',[0 max(difConVectorArcmin(stair,:)) + 1]);
                        set(gca,'FontSize',15)
                        text(20, difConVectorArcmin(stair, numtrialg)+3, sprintf('Pt Equal = %1.3f', difConVectorArcmin(stair, numtrialg)));
                        
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
                    elseif exist('third_n', 'var') == 1 && third_n == 1 && stim1Stim2order(row_gain, trialNum) == expParameters.Gain3
                        skip = 1;
                    end
                    
                    
                    if skip == 0
                        %updating the speedTestStim(difCon converted) intensity via QuestQuantile
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
                        
                        aom1offx(startFrame:endFrame) = round(rw10paths(:,xColumn,pathChoice))+expParameters.stim1_offx;
                        aom1offy(startFrame:endFrame) = round(rw10paths(:,yColumn,pathChoice).*expParameters.field_Y_adjust)+expParameters.stim1_offy;
                        
                        Mov.aom1offx = aom1offx;
                        Mov.aom1offy = aom1offy;
                        Mov.aom2offx = zeros(size(aom0seq))+expParameters.stim2_offx;
                        Mov.aom2offy = zeros(size(aom0seq))+expParameters.stim2_offy;
                        
                        %UPDATING GAINS SO THAT LEFT STIMULUS IS MOVING
                        threeStimGaincommand = sprintf('GainI#%1.3f#%1.3f#%1.3f#',expParameters.fixCrossTrackingGain, expParameters.rWGain, stim1Stim2order(row_gain, trialNum));
                        netcomm('write',SYSPARAMS.netcommobj, int8(threeStimGaincommand));
                        
                        Mov.aom1gain = expParameters.rWGain*ones(size(aom1seq));
                        Mov.aom2gain = stim1Stim2order(row_gain, trialNum)*ones(size(aom2seq));
                        
                        pause(0.2);
                    else
                        
                        aom2offx(startFrame:endFrame) = round(rw10paths(:,xColumn,pathChoice))+expParameters.stim2_offx;
                        aom2offy(startFrame:endFrame) = round(rw10paths(:,yColumn,pathChoice).*expParameters.field_Y_adjust)+expParameters.stim2_offy;
                        
                        Mov.aom2offx = aom2offx;
                        Mov.aom2offy = aom2offy;
                        Mov.aom1offx = zeros(size(aom0seq))+expParameters.stim1_offx;
                        Mov.aom1offy = zeros(size(aom0seq))+expParameters.stim1_offy;
                        
                        %UPDATING GAINS SO THAT RIGHT STIMULUS IS MOVING
                        
                        threeStimGaincommand = sprintf('GainI#%1.3f#%1.3f#%1.3f#',expParameters.fixCrossTrackingGain, stim1Stim2order(row_gain, trialNum), expParameters.rWGain);
                        netcomm('write',SYSPARAMS.netcommobj, int8(threeStimGaincommand));
                        
                        Mov.aom1gain = stim1Stim2order(row_gain, trialNum)*ones(size(aom2seq));
                        Mov.aom2gain = expParameters.rWGain*ones(size(aom1seq));
                        
                        pause(0.2);
                    end
                    
                end
            end
        end
        
        % Show the stimulus
        if presentStimulus == 1
            if trialNum == 0
                 % Call Play Movie
                Mov.msg = ['This is a dummy trial to get fixation cross'];
                setappdata(hAomControl, 'Mov',Mov);
                VideoParams.vidname = [expParameters.subjectID '_' sprintf('%03d',1)];
            else
                % Call Play Movie
                Mov.msg = ['Diffusion constant is: ' num2str(true_diffusionConstants(indexforclosestdifCon)) ...
                    '; Trial ' num2str(trialNum) ' of ' num2str(length(testSequence))];
                setappdata(hAomControl, 'Mov',Mov);
                VideoParams.vidname = [expParameters.subjectID '_' sprintf('%03d',trialNum)];
                
                sprintf('TrialNum = %#1f',trialNum)
                sprintf('Gain = %#1f',stim1Stim2order(row_gain, trialNum))
                sprintf('RWstim = %#1f',stim1Stim2order(row_rw, trialNum))
                sprintf('DifCon = %f',true_diffusionConstants(indexforclosestdifCon))  
            end
            %update the ICANDI commands
            %I uncommented this since can't reset iwth it here, but may move
            %this to be before the Mov is called, will test
            %For horizontal this is okay, but will be an issue with Vertical 3/7/23
            if expParameters.aosloFPS == 60
                centerCommand = sprintf('LocUpdateAbs#%d#%d#', 256, 128);
                netcomm('write',SYSPARAMS.netcommobj,int8(centerCommand));
            else
                centerCommand = sprintf('LocUpdateAbs#%d#%d#', 256, 256);
                netcomm('write',SYSPARAMS.netcommobj,int8(centerCommand));
            end
            PlayMovie;
            
            getResponse = 1; % set getResponse to 1 (it will remain at 1 after the first trial)
            presentStimulus = 0; % to prevent the next trial from beingntriggered before one of the response buttons is pressed
        end
        
    elseif gamePad.(sprintf('button%s',stim2)) %gamePad.buttonB % Right STIM2 in ICANDI 
        if getResponse == 1  && canRedo == 1 
            lastResponse = 'right'; %or down
            Beeper(300, 1, 0.15)
            ansToWhichFaster = 2;
            presentStimulus = 1;
        end
        
    elseif gamePad.(sprintf('button%s',stim1)) % gamePad.buttonX % Left STIM1 in ICANDI
        if getResponse == 1  && canRedo == 1
            lastResponse = 'left'; %or up
            Beeper(300, 1, 0.15)
            ansToWhichFaster = 1;
            presentStimulus = 1;
        end
        
    elseif gamePad.buttonRightUpperTrigger || gamePad.buttonRightLowerTrigger %gamePad.buttonStart %redo button
        if getResponse == 1 && canRedo == 1 && trialNum ~= 0
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