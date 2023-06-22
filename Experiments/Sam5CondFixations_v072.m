% =======================================================================
%               RUN DIFFEREMT TARGETS to EVALUATE FIXATION STABILITY
%                               25 of June 2019
%               written by Josselin Gautier Norick Bowers and Will Tuten
%               modified from Norick Bowers Tumbling E 'TumblingE_tremor.m'
%               School of Optometry - University of California, Berkeley
%
%               v0.3: tumbling E in Red
%               v0.4: Encoding of button response into frame +
%                     5 conditions implemented:
%                               - Disk             \
%                               - Conc. circles     | PASSIVE
%                               - Maltese cross   _/
%                               - E tumbling letter \ ACTIVE
%                               - Vernier acuity    /
%                v0.5: add last condition: concentric circle
%                      beep
%                v0.6: 5 steps of E size, and concentric circles ok
%                v0.66: -GamePad button press functionnality
%                       -Encoding the button value into the frame
%                       -Simple beeps
%                v0.67: -Pseudo Random number of steps
%                v0.68: -condition letter in written files: conditionMat
%                v0.68: -don't wait for button press in the 3 fixation conditions: conditionMat   
%                       TO DO  -Beep (feedbacks?)
%                       -
%                v0.70: -version with Beep (!reverse the connector on AODriver)
%                        and random condition(trial) order in a Session, + minor tweaks
%                v0.71: -version with thicker concentric circles, larger Maltese,same disk
%                          size
%                v0.72: -save the pregenerated table of E letter size in a
%                        table in session #1, and use it in the nexts.
%                       -correct the bug of inversion of letter
% =======================================================================

% Subjects view Tumbling E appearing every ~2 sec, during 2 sec
%

function TSLO_FixationTracking

global SYSPARAMS StimParams VideoParams

if exist('handles','var') == 0;
    handles = guihandles; else
end

startup;  % creates tempStimlus folder and dummy frame for initialization
gain_index = 1;
% ---------------------------------------------------
%get experiment config data stored in appdata for 'hAomControl'
hAomControl = getappdata(0,'hAomControl');
uiwait(gui_FixationConditions('M')); % wait for user input in Config dialog
CFG = getappdata(hAomControl, 'CFG');
psyfname = [];
if isstruct(getappdata(getappdata(0,'hAomControl'),'CFG')) == 1;
    CFG = getappdata(getappdata(0,'hAomControl'),'CFG');
    if CFG.ok == 1
        VideoParams.vidprefix = CFG.vid_prefix;
        VideoParams.rootfolder = CFG.root_folder;
        StimParams.stimpath = CFG.stim_folder;
        set(handles.aom1_state, 'String', 'Configuring Experiment...');
        set(handles.aom1_state, 'String', 'On - Press Start Button To Begin Experiment');
        psyfname1 = set_VideoParams_PsyfileName();
        hAomControl = getappdata(0,'hAomControl');
        Parse_Load_Buffers(1);
        %Parse_Load_Buffers(0);
        set(handles.image_radio1, 'Enable', 'off');
        set(handles.seq_radio1, 'Enable', 'off');
        set(handles.im_popup1, 'Enable', 'off');
        set(handles.display_button, 'String', 'Running Exp...');
        set(handles.display_button, 'Enable', 'off');
        %set(handles.aom1_state, 'String', 'On - Experiment Mode - Running Fixation Tracking Experiment');
        set(handles.aom1_state, 'String', sprintf('On - Experiment Mode -... Running Fix Tracking XP. Please click \n in Icandi Right Window, then press start button, cursor in AOMControl to start'));
    else
        return;
    end
end
% ---------------------------------------------------
% defining the constants
fps = 30; % 30 hz raster speed
trialsec = CFG.adapt_time;
trialduration = trialsec*fps;

arcminperpix = (1/CFG.pixperdeg)*60;

%setup the keyboard constants
kb_AbortConst = 'escape'; %abort constant - Esc Key
kb_StimConst = 'space'; % present stimulus

%set up MSC params
dirname = StimParams.stimpath;
fprefix = StimParams.fprefix;

% Stimulus parameters
gain = CFG.gain;
ntrials = CFG.n_trials;
condition = CFG.condition; %JG add the condition here
session = CFG.session;
trial = 1;
conditionsID={'C','D','E','M','V'};% 'C' 'D' 'E' 'M' 'V'.%conditionsID={'C','C','C','C','C'};
conditionIDstring=cell2mat(conditionsID);
%condID=find(strcmp(condition,conditionsID)==1);%was working when condition
%was predefined

conditionVector = randperm(5);%'generate a new vector of conditions for the 5 trials
conditionRandLetter=conditionIDstring(conditionVector);

fprintf('Condition %s, Session %d\n',condition, session);


% everything is pseudo-randomized
%Each time rand is called, the state of the generator is changed and a new sequence of random numbers is generated.
%rand('state',N) for integer N in the closed interval [0 2^32-1] initializes the generator to the Nth integer state.
rand('state',sum(100*clock)) %alternatively rng('Shuffle')

% ---------------------------------------------------------------------
% generate frame and location sequences that can be used thru out the experiment

% set up the location of the IR stimulus relative to the selected cross
% which is at coords (0,0)
aom0locx = zeros(1,trialduration);
aom0locy = zeros(1,trialduration);

aom2locx = zeros(1,trialduration); %-NRB Added
aom2locy = zeros(1,trialduration); %-NRB Added

% INITIALIZE
% set up the frame sequence for green
aom1seq = aom0locy;
aom1seq(:) = 0; % green channel  all set to 0 doesn't display anything
% set up the frame sequence for IR
aom0seq = aom0locy;
aom0seq(:) = 0; % IR frame is frame2.bmp (6/23/16)
% set up the frame sequence for red
aom2seq = aom0locy;
aom2seq(:) = 0;

% set the power for each frame equal to 1
aom0pow = ones(size(aom0seq));

% set up the video params
viddurtotal = size(aom0seq,2); % in frames
vid_dur = viddurtotal./fps; % in seconds
VideoParams.videodur = vid_dur;
%verify the duration is >40;
if vid_dur <36
    fprintf('Error: too short duration for 21 repetitions')
    return
end

% JG addition:
% generate a vector of 21 repetitions * 5 trials= 105 repetitions in total
% with the same number of repetitions for each 7 steps:
%105/7=15 number of steps. 
if session==1
fixSeq=repmat(1:7,1,15);
vec=randperm(105);
pRandSeq=fixSeq(vec);
% arrange into a matrix of 5 columns(trials), 21 lines (repetitions)
pseudoRandSteps=reshape(pRandSeq,21,5);
save('pseudoRandSteps.mat','pseudoRandSteps');
else
    load pseudoRandSteps
end

% loop to set up the gain sequence
if length(gain)>1
    loop = ntrials;
    ntrials = ntrials*length(gain);
    gain_order = gain;
    while loop>1
        gain = cat(2, gain, gain_order);
        loop = loop-1;
    end
    indices = randperm(ntrials);
    gain = gain(indices);
    gainseq = ones(size(aom0seq)).*gain(gain_index);
else
    gainseq = ones(size(aom0seq)).*gain(1);
end

%set up the movie parameters with variables from above or equal to zero
% Don't change anything here for Mov structure
Mov.frm = 1;
Mov.seq = '';
Mov.dir = dirname;
Mov.suppress = 0;
Mov.pfx = fprefix;
Mov.duration = size(aom0seq,2);
Mov.gainseq = gainseq;
Mov.aom0seq = aom0seq;
Mov.aom0pow = aom0pow;
Mov.aom0locx = aom0locx;
Mov.aom0locy = aom0locy;
Mov.aom1seq = zeros(1,size(aom0seq,2));     %need to keep these variables
Mov.aom1pow = ones(1,size(aom0seq,2));      %need to keep these variables
Mov.aom1offx = zeros(1,size(aom0seq,2));    %need to keep these variables
Mov.aom1offy = zeros(1,size(aom0seq,2));    %need to keep these variables
Mov.aom2seq = zeros(1,size(aom0seq,2));     %need to keep these variables
Mov.aom2pow = ones(1,size(aom0seq,2)); %-NRB Added
Mov.aom2offx = aom2locx; %-NRB Added
Mov.aom2offy = aom2locy; %-NRB Added
Mov.angleseq = zeros(1,size(aom0seq,2));    %need to keep these variables

% 0 for no beep, 1 for beep
stimbeep = zeros(1,size(aom0seq,2));
Mov.stimbeep = stimbeep; % sound before target stimulus

%set initial while loop conditions
set(handles.aom_main_figure, 'KeyPressFcn','uiresume');
runExperiment = 1;
Mov.frm = 1;
% set up the message that will appear in AOM control panel
message1 = ['Experiment ' conditionRandLetter '- Condition' condition 'Session' num2str(session) ' Trial ' num2str(trial) ' of ' num2str(ntrials) ];
message = sprintf('%s\n%s', message1);
%Mov.msg = message;
set(handles.aom1_state, 'String', message1);
% call the line below anytime you update the Mov structure
setappdata(hAomControl, 'Mov',Mov);
UpdateStimulus = 1; GetResponse = 0;

% Keeping this because afraid to delete it...
% Experiment specific psyfile header
% writePsyfileHeader(psyfname);

if SYSPARAMS.realsystem == 1
    StimParams.stimpath = dirname;
    StimParams.fprefix = fprefix;
    %StimParams.sframe = 2; %JG: will be defined for each condition later
    %StimParams.eframe = 8;
    StimParams.fext = 'bmp';
%    Parse_Load_Buffers(0);
end
SYSPARAMS.aoms_state(1) = 1; % turn on imaging channel (IR)
SYSPARAMS.aoms_state(2) = 1; % turn on second channel JGedit
SYSPARAMS.aoms_state(3) = 1; % turn on second channel (Green for AOSLO)

state = 'wait';

while(runExperiment ==1)
    switch state
        case {'wait'} % waits for a key pres
            good_check = 0;
            StimNumber=1;%
            %trial=trial+1;
%             if strcmp(key,kb_AbortConst)   % Abort Experiment
%                 runExperiment = 0; % quit the experiment
%                 uiresume; % ditto
%                 TerminateExp; % ditto
%                 message = ['Off - Experiment Aborted - Trial ' num2str(trial) ' of ' num2str(ntrials)];
%                 set(handles.aom1_state, 'String',message)
%             end
            %
            
            [gamePad,~]=GamePadInput(gcf);
            if gamePad.buttonStart
                
                beep;pause(0.2) % sound to indicate beginning of video
                
                % Reset Mov structure to defaults
                Mov.aom0locx = aom0locx;
                Mov.aom0locy = aom0locy;
                VideoParams.videodur = 0;
                VideoParams.vidrecord = 0;
                Mov.duration = size(aom0seq,2);
                Mov.aom0pow = ones(1,size(aom0seq,2));
                Mov.gainseq = ones(1,size(aom0seq,2))*CFG.gain;
                Mov.aom1seq = zeros(1,size(aom0seq,2));     %need to keep these variables
                Mov.aom1pow = ones(1,size(aom0seq,2));      %need to keep these variables
                Mov.aom1offx = zeros(1,size(aom0seq,2));    %need to keep these variables
                Mov.aom1offy = zeros(1,size(aom0seq,2));    %need to keep these variables
                Mov.aom2seq = zeros(1,size(aom0seq,2));     %need to keep these variables
                Mov.aom2pow = ones(1,size(aom0seq,2));     %need to keep these variables
                Mov.aom2offx = zeros(1,size(aom0seq,2));    %need to keep these variables
                Mov.aom2offy = zeros(1,size(aom0seq,2));    %need to keep these variables
                Mov.angleseq = zeros(1,size(aom0seq,2));    %need to keep these variables
                
                % update the locations for stimulus presentation
                Mov.aom0locx = zeros(size(aom0seq));
                Mov.aom0locy = zeros(size(aom0seq));
                setappdata(hAomControl, 'Mov',Mov);
                
                % update video params here, but shouldn't need to change them
                VideoParams.videodur = vid_dur;
                VideoParams.vidrecord = 1;
                
                UpdateStimulus = 1; % Tells next case to update stimulus
                setappdata(hAomControl, 'Mov',Mov);
                
                state = 'stimulus';
                % TO DO load the condition value from precomputed sequence of
                % condition, conditionVector
                %
                condition = conditionRandLetter(trial);
                %conditionsID{conditionVector(trial)};
                
            end
            
        case {'stimulus'} % Present the stimulus
            
            
            if UpdateStimulus == 1 % Update the stimulus for the current trial, present and record
                % initialize variables and vectors for recordings of button
                % presses:
                sequenceVector = [];
                xOffsetVector = [];
                yOffsetVector = [];
                finalRespMat=[];
                conditionMat=[];
                %different sequence vector for each condition
                % tumbling E: random interval between 0.5 sec(16 frames)
                %             and 1.5 sec (48 frames) followed by 0.5 sec(16)
                %             of
                % vernier V: random interval between 0.5 sec(16 frames)
                %             and 1.5 sec (48 frames) followed by 0.5 sec(16)
                %             of one among the 7 conditions
                %
                
                switch condition
                    % here we generate a sequence made of a
                    % 'interval+stimuli' that we repeat for the
                    % whole duration condition
                    case 'E'
                        % defined the sequence
                        while length(sequenceVector)<length(aom0seq)
                            
                            intervalLength = randi([15 45]);
                            sequenceVector = [sequenceVector zeros(1,intervalLength)]; %#ok<AGROW>; interval
                            xOffsetVector =  [xOffsetVector zeros(1,intervalLength)]; %#ok<AGROW>; zeros at interval
                            yOffsetVector =  [yOffsetVector zeros(1,intervalLength)]; %#ok<AGROW>
                            
                            rotationStep=randi([0 3]);
                            randN=pseudoRandSteps(StimNumber,session);
                            stepSize=[2 6 10 14 18 22 26];% 7 steps
                            randSize=stepSize(randN);% pick a random  number among stepSize 
                            timSampStimOnset = length(sequenceVector);
                            sequenceVector = [sequenceVector ones(1,15)*(randSize+rotationStep)];
                            %sequenceVector = [sequenceVector ones(1,15)*randi([2 29])]; %#ok<AGROW>; stimulus is on
                            xOffsetVector =  [xOffsetVector ones(1,15)*randi([-10 10])];  %#ok<AGROW>
                            yOffsetVector =  [yOffsetVector ones(1,15)*randi([-10 10])];  %#ok<AGROW>
                            conditionMat = [conditionMat ; conditionVector(trial), session, trial, rotationStep+1,randSize,(timSampStimOnset+1)*0.033, timSampStimOnset+1];
                            if StimNumber<21
                                StimNumber=StimNumber+1;
                            else
                                sequenceVector(end:length(aom0seq)) = 0;
                            end
                        end
                        
                        if length(sequenceVector)>length(aom0seq);
                            sequenceVector(length(aom0seq)+1:end) = [];
                        end
                        % define
                        
                    case 'V'

                        while length(sequenceVector)<length(aom0seq)
                            intervalLength = randi([15 45]);
                            sequenceVector = [sequenceVector zeros(1,intervalLength)]; %#ok<AGROW>; interval
                            xOffsetVector =  [xOffsetVector zeros(1,intervalLength)]; %#ok<AGROW>; zeros at interval
                            yOffsetVector =  [yOffsetVector zeros(1,intervalLength)]; %#ok<AGROW>
                            
                            randN=pseudoRandSteps(StimNumber,session);
                            stepSize=[1 2 3 4 5 6 7];% 7 steps
                            randSize=stepSize(randN);
                            timSampStimOnset = length(sequenceVector);
                            sequenceVector = [sequenceVector ones(1,15)*(randSize+1)];
                            %sequenceVector = [sequenceVector ones(1,15)*randi([2 8])]; %#ok<AGROW>; stimulus is on
                            xOffsetVector =  [xOffsetVector ones(1,15)*randi([-10 10])];  %#ok<AGROW>
                            yOffsetVector =  [yOffsetVector ones(1,15)*randi([-10 10])];  %#ok<AGROW>
                            conditionMat = [conditionMat ; conditionVector(trial), session,trial, randSize,(timSampStimOnset+1)*0.033, timSampStimOnset+1];
                            if StimNumber<21
                                StimNumber=StimNumber+1;
                            else
                                sequenceVector(end:length(aom0seq)) = 0;
                            end
                        end
                        if length(sequenceVector)>length(aom0seq);
                            sequenceVector(length(aom0seq)+1:end) = [];
                        end
                        seqBeep=zeros(length(sequenceVector),1);
                        seqBeep(find(diff(sequenceVector)>0)) = 1;
                        seqBeep = seqBeep(:);
                        %stimbeep = zeros(1,size(aom0seq,2));
                        %Mov.stimbeep = [diff(seqBeep);0];%stimbeep; % sound before target stimulus
                        %setappdata(hAomControl, 'Mov',Mov);
                    case 'C'

                        seqTemp=[ 12 12 12 11 11 11 10 10 10 9 9 9 8 8 8 ...
                            7 7 7 6 6 6 5 5 5 4 4 4 3 3 3];
                        while length(sequenceVector)<length(aom0seq)
                            sequenceVector=[sequenceVector seqTemp];
                        end
                        if length(sequenceVector)>length(aom0seq);
                            sequenceVector(length(aom0seq)+1:end) = [];
                        end
                        sequenceVector(length(aom0seq))=0;
                        
                    case 'M' % Maltese cross, 2 sec fixation + 2 sec blank or wait for button press?
                        %gap=2;% factor of 2 for 10 arcmin. 1 for 5 arcmin

                        while length(sequenceVector)<length(aom0seq)
                            %intervalLength=1;%60;%2sec
                            targetLength=60;
                            %sequenceVector = [sequenceVector zeros(1,intervalLength)];
                            %xOffsetVector =  [xOffsetVector zeros(1,intervalLength)]; %#ok<AGROW>; zeros at interval
                            %yOffsetVector =  [yOffsetVector zeros(1,intervalLength)];
                            sequenceVector = [sequenceVector ones(1,targetLength)*2];
                            xOffsetVector =  [xOffsetVector ones(1,targetLength)*randi([-10 10])];  %#ok<AGROW>
                            yOffsetVector =  [yOffsetVector ones(1,targetLength)*randi([-10 10])];
                        end
                        if length(sequenceVector)>length(aom0seq);
                            sequenceVector(length(aom0seq)+1:end) = [];
                        end
                        sequenceVector(length(aom0seq))=0;
                    case 'D' % case of a disk, 2 sec fixation + 2 sec blank
                          
                        while length(sequenceVector)<length(aom0seq)
                            %intervalLength=1;%60;%2sec
                            targetLength=60;
                            %sequenceVector = [sequenceVector zeros(1,intervalLength)];
                            sequenceVector = [sequenceVector ones(1,targetLength)*2];
                        end
                        if length(sequenceVector)>length(aom0seq);
                            sequenceVector(length(aom0seq)+1:end) = [];
                        end
                        sequenceVector(length(aom0seq))=0;
                end
                
%                 end
                
                if ~isempty(find(sequenceVector==0))
                    [zeroIndex] = find(sequenceVector==0);
                    sequenceVector(zeroIndex(end):end) = 0;
                end
                
                % specific code to make analog beeps instead of stimBeeps
                % ! you need to reverse the IR and Red channles on the
                % Acousto-optic driver to use it.
                switch condition
                    case {'C','D','M'}
                        Mov.aom1seq=zeros(1,length(sequenceVector));
                    otherwise
                        sequenceBeep=[0 diff(sequenceVector)];
                        sequenceBeep(sequenceBeep<0)=0;
                        Mov.aom1seq = sequenceBeep;%sequenceVector;
                end
                
                
                %Mov.aom1offx = xOffsetVector;
                %Mov.aom1offy = yOffsetVector;                
                Mov.aom0seq = sequenceVector;% red
                
                % To activate random location of the target JGadd
                % (location set before in each condition)
                %{
                Mov.aom0locx = xOffsetVector;
                Mov.aom0locy = yOffsetVector;
                %}
                %                 aom1seq(:) = randi(4)+4;%JGmod % randomly select one of 4 orientations (frames 5-8)
                
                %JGc: Norick randomized interval before stimuli presentation
%                 cps = CFG.interval_length*30; %for 90 longest stimulus interval = 3 sec, shortest is 1/30 sec
%                 for t = 1:trialsec %auto changes depending on your video duration
%                     aom2seq(randi(cps)+(t*cps)-cps:end) = randi(4)+4; %30 = fps
%                 end
                
                Mov.aom0seq(end)=0;

                Mov.frm=1;
                % update video name to include new trial number
                VideoParams.vidname = [CFG.vid_prefix '_' sprintf('%03d',trial)];%
                % update the message presented in AOMcontrol panel
                message1 = [condition ' of ' conditionRandLetter ' ' num2str(session) ' Trial ' num2str(trial) ' of ' num2str(ntrials)];
                message = sprintf('%s\n%s', message1);
                Mov.msg = message;
                set(handles.aom1_state, 'String', message);
                %new additions for createStimulus 6/21/2016; need to defines inputs b4 calling
                %them
                intensity = 0; % the intensity of the E
                
                % going to want to change gap to equal the stimulus size
                % which will be set in the config to CFG."something"
                gap = CFG.stim_size; % is the gap between the prongs of the E in pixels ...
                %- will change the overall size of the stimulus by some factor
                
                
                
                
                %this is the first place createStimulus calls inputs
                %gap=[];
                alt=[];
                grayValue=0;
                %TO BE REMOVED
                indices=createStimulus(gap,alt,grayValue,condition);
                %                 Mov.aom0seq(:) = 3; % we might need to change this to 3.
                
                StimParams.sframe =min(indices); %JG: dunno why Norick had 2, 3 and 4.bmp void
                StimParams.eframe = max(indices);%Alley and Will:add +1 to have eframe-sframe>0
                setappdata(hAomControl, 'Mov',Mov);
                %load the speficied frames into ICANDI
                Parse_Load_Buffers(0); % we might need to change this to 1.
                % TO DO : check into in debug mode
                
                
                % Presents stimulus and saves movie.
                beep;pause(0.2); beep;pause(0.2); % sound to indicate beginning of video
                %tic
                PlayMovie                
                %toc
                startTime=GetSecs();
                %tic
                UpdateStimulus = 0; % sets the program to run through the other if statement below
            end
            
            
            %if UpdateStimulus =
%             if UpdateStimulus == 0;
%                 uiwait; % wait for keypress (response or abort)
%                 key = get(handles.aom_main_figure,'CurrentKey');
%                 if strcmp(key,kb_AbortConst)   % Abort Experiment
%                     runExperiment = 0;
%                     uiresume;
%                     TerminateExp;
%                     
%                 else % otherwise...
                    GetResponse = 1; % sends you to thegz if statement below to get the response
                    
%                 end
%             end
            
              %gamePad=GamePad();% TO CHECK
                %gamePad = [];
            %pause(30);
                %%{    
                %toc
                markFrame = 0;
             switch condition
                 case {'C','D','M'}
                     good_check = 1;% we don't scan for button to redo the trial
                     while GetSecs-startTime< (length(sequenceVector)/30)
                     end
                 otherwise %'E' or 'V'
                         
                    while GetSecs-startTime< (length(sequenceVector)/30)%=36
                        % it doesn't really work as it is catching few amounts of
                        % button press occuring over this 0.01 periods
                         [gamePad,~]=GamePadInput(gcf);%GamePadInput %gamePad.read(); %this runs continuously until the while loop is left
                         good_check=1;%temp

                         %switch condition
                        if gamePad.buttonY
                            fprintf('Y\n');%beep;

                            resp = 1; good_check = 1;
                            grayLevel = 250; markFrame = 1;
                            %add Pavan's code to write into frame
                            finalRespMat = [finalRespMat;[conditionVector(trial), session,trial , resp , GetSecs-startTime, round((GetSecs-startTime)*30)]];
                        elseif gamePad.buttonB
                            fprintf('B\n');%beep;
                            resp= 2; good_check = 1;
                            grayLevel = 245; markFrame = 1;
                            finalRespMat = [finalRespMat;[conditionVector(trial), session,trial , resp , GetSecs-startTime,round((GetSecs-startTime)*30)]];
                        elseif gamePad.buttonA
                            fprintf('A\n');%beep;
                            resp = 3; good_check = 1;
                            grayLevel = 240; markFrame = 1;
                            finalRespMat = [finalRespMat;[conditionVector(trial), session,trial , resp , GetSecs-startTime,round((GetSecs-startTime)*30)]];
                        elseif gamePad.buttonX
                            fprintf('X\n');%beep;
                            resp= 4; good_check = 1;
                            grayLevel = 235; markFrame = 1;
                            finalRespMat = [finalRespMat;[conditionVector(trial), session,trial , resp , GetSecs-startTime,round((GetSecs-startTime)*30)]];

                        elseif gamePad.buttonLeftLowerTrigger || gamePad.buttonLeftUpperTrigger
                            % should we overwrite or write separately?
                            %good_check=0;%temp
                            %break
                        end
                        if markFrame == 1 % Write gray level to next ICANDI frame using netcomm
                           command = ['MarkFrame#' num2str(grayLevel) '#'];
                           netcomm('write', SYSPARAMS.netcommobj, int8(command));
                           markFrame = 0; % Set flag back to zero
                        end       
                        pause(0.25);
                    end
             end
            %toc
            %}
            if ~isempty(conditionMat);
                save([psyfname1(1:end-4) '_' condition num2str(session) '-' num2str(trial) '.mat'],'finalRespMat','conditionMat','condition','sequenceVector');
            else
                save([psyfname1(1:end-4) '_' condition num2str(session) '-' num2str(trial) '.mat'],'condition');
            end
            %save([psyfname1(1:end-4) '.mat'],'finalRespVector','-append')
            
 
            state = 'wait';
            
            if trial==ntrials
                runExperiment=0;
                pause(5);
                TerminateExp; % Magic Pavan code - abort experiment for AOMControl
                message = ['Off - Experiment Complete - '];
                set(handles.aom1_state, 'String',message);
                Speak('Experiment complete. Nice job.');
            end
            

            if good_check == 1
                trial = trial+1;
            end
%             if good_check ~= 1 % experimenter rejects trial
%                 message = ['Off - Experiment Aborted'];
%                 set(handles.aom1_state, 'String',message)
%                 % TO DO delete that movie & mat file
%                 finalRespVector=[];
%             end%
            
            
            % Increment the trial counter if good trial
            
            
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%code to generate E%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [indices]=createStimulus(gap,alt,grayValue,condition)


CFG = getappdata(getappdata(0,'hAomControl'),'CFG');

cd([pwd,filesep,'tempStimulus']);
temp=[];
switch condition
    case 'E'
        rotations = [270,0,90,180];%0:90:270;
        stepIndex=-2;%+4 =2
        for gapE=3:9%2:8
            stepIndex=stepIndex+4;
            e=ones(gapE*5,gapE*5)*(1-grayValue/255);
            e(gapE+1:2*gapE,gapE+1:end)=0;
            e(3*gapE+1:4*gapE,gapE+1:end)=0;
            padh=zeros(1,length(e));padv=zeros(length(e)+2,1);
            E=[padh;e;padh];
            E=[padv E padv];
            E = 1-E; %-NRB Commented. Stimulus now increment.
            rightE=E;
            for rotIndex = 1:length(rotations)
                E = imrotate(rightE,rotations(rotIndex));
                imwrite(E,sprintf('frame%d.bmp',stepIndex+rotIndex-1));
                temp=[temp (stepIndex+rotIndex-1)];
            end
            
        end
        indices=temp;
        %         imwrite(,'frame2.bmp');
        
    case 'V'
        % the height and width of each horizontal bar are hard-defined
        % bar are 3 pix height x 47 pix width
        gap=2;%to change to 2 to easier % a single pixel bar height for the Vernier
        hbar=ones(1*3,gap*47)*(1-grayValue/255);%half bar
        padt=  zeros( 3*gap,size(hbar,2));% pad top: add 3* space on top and bottom
        padmin=zeros(   gap,size(hbar,2));
        padmax=zeros(6* gap,size(hbar,2));%pad max, a pad made of 6 times the bar width
        
        vleft=[padt; hbar; padt];
        %cd([pwd,filesep,'tempStimulus']);
        for i=1:7 %from -3 to +3
            if i==1     %top
                vright=hbar;
                vright=[hbar; padmax];
                
            elseif i==7 % bottom vernier
                vright=hbar;
                vright=[padmax;hbar];
            else
                padt=zeros((i-1)* gap ,size(hbar,2));
                padb=zeros((7-i)* gap ,size(hbar,2));
                vright=[padt;hbar;padb];
            end
            %concatenating, padding, inversing and saving
            V=[vleft vright];
            padh=zeros(1,size(V,2));padv=zeros(size(V,1)+2,1);
            V=[padh;V;padh];
            V=[padv V padv];
            V=1-V;
            
            imwrite(V,['frame' num2str(i+1) '.bmp']);
            temp(i) = i+1; 
        end
        indices=temp;
        %cd ..;
        
    case 'M'
        %temporarily hardcode the gap size
        %gap=2;% factor of 2 for 10 arcmin. 1 for 5 arcmin
        % so 97 pixels
        % here we use a trick from
        c=97;%53;%97;%ceil(97/2);
        m=ones(c);
        %mbr=tril(m),
        %m1=[fliplr(flipud(tril(m))), ones(c,1),flipud(tril(m)); zeros(1,c),1,zeros(1,c) ;fliplr(tril(m)),ones(c,1),tril(m)]
        m1=[fliplr(flipud(tril(m))), 1-flipud(tril(m))];
        m1=[m1;flipud(1-m1)];
        Mr=imrotate(m1,22.5,'bicubic');%'bilinear');%or
        Mr=imbinarize(Mr);%M
        %crop
        M= ones(c);
        %M=Mr(ceil(length(Mr)/4):ceil(3*length(Mr)/4),...
        %    ceil(length(Mr)/4):ceil(3*length(Mr)/4) );
        M=Mr(ceil(length(Mr)/2-c/2):ceil(length(Mr)/2+c/2),...
            ceil(length(Mr)/2-c/2):ceil(length(Mr)/2+c/2));
        M = double(M);
        for aa = 2:8
            imwrite(M, sprintf('frame%d.bmp',aa));
        end
            %         imwrite(M,'frame2.bmp');
        indices=[2:8];

    case 'C'
        % the C have already been created
        % or re-create them here.
        r=round([9 17 26 34 43 51 60 68 77 85])/2;
        
        stimSize=90;%it has to be the double of biggest diameter
        xoffset=stimSize/2; yoffset=stimSize/2;
        
        for zz= 1:length(r)
            r_curr = r(zz);
            
            th=0:pi/stimSize:2*pi;
            xpos= round(r_curr*cos(th) + xoffset);
            ypos= round(r_curr*sin(th) + yoffset);
            
            bmp=zeros(stimSize,stimSize);
            for aa=1:length(xpos)
                bmp(xpos(aa),ypos(aa))=1;
                bmp(xpos(aa)+1,ypos(aa))=1;
                bmp(xpos(aa)-1,ypos(aa))=1;
                bmp(xpos(aa),ypos(aa)+1)=1;
                bmp(xpos(aa),ypos(aa)-1)=1;
                %
                bmp(xpos(aa)+2,ypos(aa))=1;
                bmp(xpos(aa)-2,ypos(aa))=1;
                bmp(xpos(aa),ypos(aa)+2)=1;
                bmp(xpos(aa),ypos(aa)-2)=1;
            end
            bmp= 1-bmp;
            
            imwrite(bmp,sprintf('frame%d.bmp',zz+1));
            %temp(zz)=zz+2;
        end
        indices=[2:8];
        
    case 'D' %bull's eye = 2 black and white disk
        %gap=2;% factor of 2 for 10 arcmin. 1 for 5 arcmin
%         diam=gap*47+1;
        diam = 53;
        d=ones(diam,diam);% empty support matrix
        center=round(diam/2);%floor
        radius=center-1;
        [columns rows] = meshgrid(1:diam, 1:diam);
        d=(rows - center).^2+(columns - center).^2 >= radius.^2;
        %now adding central disk of half diameter
        [columns rows] = meshgrid(1:ceil(diam), 1:ceil(diam));
        d2=(rows - center).^2+(columns - center).^2 <= ceil(radius/2).^2;
        D=d|d2;
        D = double(D);
        for aa = 2:8
            imwrite(D, sprintf('frame%d.bmp',aa));
        end
%         imwrite(D,'frame2.bmp');
        indices=[2:8];%D=1-D;
end
cd ..;


function startup

dummy=ones(10,10);
if isdir([pwd, filesep,'tempStimulus']) == 0;
    mkdir(pwd,'tempStimulus');
    cd([pwd,filesep,'tempStimulus']);
    imwrite(dummy,'frame2.bmp');
    imwrite(dummy,'frame3.bmp');
    imwrite(dummy,'frame4.bmp');
    imwrite(dummy,'frame5.bmp');
    imwrite(dummy,'frame6.bmp');
    imwrite(dummy,'frame7.bmp');
    imwrite(dummy,'frame8.bmp');
else
    cd([pwd, filesep,'tempStimulus']);
    delete *.bmp
    delete *.buf
    imwrite(dummy,'frame2.bmp');
    imwrite(dummy,'frame3.bmp');
    imwrite(dummy,'frame4.bmp');
    imwrite(dummy,'frame5.bmp');
    imwrite(dummy,'frame6.bmp');
    imwrite(dummy,'frame7.bmp');
    imwrite(dummy,'frame8.bmp');
end


cd ..;

