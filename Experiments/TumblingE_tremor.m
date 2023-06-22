
function TSLO_FixationTracking

% Experiment to record videos for fixation performance.
% Subject views tumbling E, responses are not recorded.


global SYSPARAMS StimParams VideoParams


if exist('handles','var') == 0;
    handles = guihandles; else
end

startup;  % creates tempStimlus folder and dummy frame for initialization
gain_index = 1;
%get experiment config data stored in appdata for 'hAomControl'
hAomControl = getappdata(0,'hAomControl');
uiwait(gui_FixationTracking('M')); % wait for user input in Config dialog
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
        set(handles.aom1_state, 'String', 'On - Experiment Mode - Running Fixation Tracking Experiment');
    else
        return;
    end
end


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
trial = 1;

% everything is psuedo-randomized
rand('state',sum(100*clock))


% generate frame and location sequences that can be used thru out the experiment

% set up the location of the IR stimulus relative to the selected cross
% which is at coords (0,0)
aom0locx = zeros(1,trialduration);
aom0locy = zeros(1,trialduration);

aom2locx = zeros(1,trialduration); %-NRB Added
aom2locy = zeros(1,trialduration); %-NRB Added

% set up the frame sequence for green
aom1seq = aom0locy;
aom1seq(:) = 0; % green channel  all set to 0 doesn't display anything

% set up the frame sequence for IR
aom0seq = aom0locy;
aom0seq(:) = 0; % IR frame is frame2.bmp (6/23/16)
aom2seq = aom0locy;
aom2seq(:) = 0; 

% set the power for each frame equal to 1
aom0pow = ones(size(aom0seq));

% set up the video params
viddurtotal = size(aom0seq,2); % in frames
vid_dur = viddurtotal./fps; % in seconds
VideoParams.videodur = vid_dur;

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
message1 = ['Running Experiment - Trial ' num2str(trial) ' of ' num2str(ntrials) ];
message = sprintf('%s\n%s', message1);
Mov.msg = message;
% call the line below anytime you update the Mov structure
setappdata(hAomControl, 'Mov',Mov);
UpdateStimulus = 1; GetResponse = 0;

% Keeping this because afraid to delete it...
% Experiment specific psyfile header
% writePsyfileHeader(psyfname);

if SYSPARAMS.realsystem == 1
    StimParams.stimpath = dirname;
    StimParams.fprefix = fprefix;
    StimParams.sframe = 2;
    StimParams.eframe = 8;
    StimParams.fext = 'bmp';
    Parse_Load_Buffers(0);
end
SYSPARAMS.aoms_state(1) = 1; % turn on imaging channel (IR)
SYSPARAMS.aoms_state(2) = 0; % turn on second channel (Green for TSLO)
SYSPARAMS.aoms_state(3) = 1; % turn on second channel (Green for AOSLO)

state = 'wait';

while(runExperiment ==1)
    switch state
        case {'wait'} % waits for a key press
            good_check = 0;
            uiwait; % pause program until keypress to initiate trial
            key = get(handles.aom_main_figure,'CurrentKey'); % get the keypress
            if strcmp(key,kb_AbortConst)   % Abort Experiment
                runExperiment = 0; % quit the experiment
                uiresume; % ditto
                TerminateExp; % ditto
                message = ['Off - Experiment Aborted - Trial ' num2str(trial) ' of ' num2str(ntrials)];
                set(handles.aom1_state, 'String',message)
            end
            if  strcmp(key,kb_StimConst) % Start the trial/video
                beep;pause(0.2); beep;pause(0.2); beep; % sound to indicate beginning of video
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
                % update video params here, but shouldn't need to change
                % them
                VideoParams.videodur = vid_dur;
                VideoParams.vidrecord = 1;
                
                
                UpdateStimulus = 1; % Tells next case to update stimulus
                setappdata(hAomControl, 'Mov',Mov);
                
                state = 'stimulus';
                
            end
            
        case {'stimulus'} % Present the stimulus
            
            
            if UpdateStimulus == 1 % Update the stimulus for the current trial, present and record
                % update with any changes to the Mov structure in this part
                % of the code...
                %                 aom0seq(:) = randi(4)+4; % randomly select one of 4 orientations (frames 5-8)
                %
                %                 cps = CFG.interval_length*30; %for 90 longest stimulus interval = 3 sec, shortest is 1/30 sec
                %                 for t = 1:trialsec %auto changes depending on your video duration
                %                     aom0seq(randi(cps)+(t*cps)-cps:end) = randi(4)+4; %30 = fps
                %                 end
                %
                %                 Mov.aom0seq = aom0seq;
                
                %NRB Added All Below (copied from above and changed to green)
                aom2seq(:) = randi(4)+4; % randomly select one of 4 orientations (frames 5-8)
                
                cps = CFG.interval_length*30; %for 90 longest stimulus interval = 3 sec, shortest is 1/30 sec
                for t = 1:trialsec %auto changes depending on your video duration
                    aom2seq(randi(cps)+(t*cps)-cps:end) = randi(4)+4; %30 = fps
                end
                
                Mov.aom2seq = aom2seq;
                Mov.aom2seq(end) = 0; 
                
                Mov.frm = 1;
                % update video name to include new trial number
                VideoParams.vidname = [CFG.vid_prefix '_' sprintf('%03d',trial)];%
                % update the message presented in AOMcontrol panel
                message1 = ['Trial ' num2str(trial) ' of ' num2str(ntrials)];
                message = sprintf('%s\n%s', message1);
                Mov.msg = message;
                
                
                %new additions for createStimulus 6/21/2016; need to defines inputs b4 calling
                %them
                intensity = 0; % the intensity of the E
                
                % going to want to change gap to equal the stimulus size
                % which will be set in the config to CFG."something"
                gap = CFG.stim_size; % is the gap between the prongs of the E in pixels - will change the overall size of the stimulus by some factor
                
                % select the orientation of the E (alt)
                alts = [0 90 180 270];
                randind = randi(4);
                alt = alts(randind);
                
                grayValue = 0;
                
                %this is the first place createStimulus calls inputs
                createStimulus(gap,alt,grayValue)
                Mov.aom0seq(:) = 3; % we might need to change this to 3.

                setappdata(hAomControl, 'Mov',Mov);
                Parse_Load_Buffers(0); % we might need to change this to 1. 
                PlayMovie % Presents stimulus and saves movie. Usually a good place to put a break point for debugging to check Mov structure
                
                UpdateStimulus = 0; % sets the program to run through the other if statement below
            end
            
            if UpdateStimulus == 0;
                uiwait; % wait for keypress (response or abort)
                key = get(handles.aom_main_figure,'CurrentKey');
                if strcmp(key,kb_AbortConst)   % Abort Experiment
                    runExperiment = 0;
                    uiresume;
                    TerminateExp;
                    message = ['Off - Experiment Aborted - Trial ' num2str(trial) ' of ' num2str(ntrials)];
                    set(handles.aom1_state, 'String',message)
                else % otherwise...
                    GetResponse = 1; % sends you to thegz if statement below to get the response
                    
                end
            end
            
            if GetResponse == 1
                if strcmp(key,'uparrow') % redo the trial and overwrite the video
                    good_check = 0;
                else
                    good_check = 1; % carry on
                end
                % This is where you would get the responses based on the
                % keypress
                %                 if strcmp(key,'insert')
                %                     resp = 0;
                %                     good_check = 1;
                %                 elseif strcmp(key,'end')
                %                     resp = 1;
                %                     good_check = 1;
                %                 elseif strcmp(key,'downarrow')
                %                     resp = 2;
                %                     good_check = 1;
                %                 elseif strcmp(key,'pagedown')
                %                     resp = 3;
                %                     good_check = 1;
                %                 elseif strcmp(key,'uparrow')
                %                     resp = [];
                %                     good_check = 0;
                %                 end
                
                if good_check == 1
                    
                    trial = trial + 1; % go to the next trial
                    if trial > ntrials && ntrials~=0 % if you haven't exceeded the total number of trials
                        runExperiment = 0; % exit the while loop
                        pause(30);
                        set(handles.aom_main_figure, 'keypressfcn','');
                        TerminateExp; % magic pavan code
                        message = ['Off - Experiment Complete - '];
                        set(handles.aom1_state, 'String',message);
                    else %continue experiment
                        
                    end
                elseif strcmp(key,'uparrow') % experimenter rejects trial
                    resp = [];
                    good_check = 0;
                end
            end
            UpdateStimulus = 0;
            GetResponse = 0;
            state = 'wait'; % go through next iteration of the loop but for the next trial
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%code to generate E%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function createStimulus(gap,alt,grayValue)


CFG = getappdata(getappdata(0,'hAomControl'),'CFG');


e=ones(gap*5,gap*5)*(1-grayValue/255);
e(gap+1:2*gap,gap+1:end)=0;
e(3*gap+1:4*gap,gap+1:end)=0;
padh=zeros(1,length(e));padv=zeros(length(e)+2,1);
E=[padh;e;padh];
E=[padv E padv];
%E = 1-E; %-NRB Commented. Stimulus now increment. 

cd([pwd,filesep,'tempStimulus']);
E = E.*0.01;
canv=E;
canv2=canv;
canv2(:)=1;
%present right E
canv=imrotate(E,0);
imwrite(canv,'frame5.bmp');
%present left E
canv=imrotate(E,90);
imwrite(canv,'frame6.bmp');
%present up E
canv=imrotate(E,180);
imwrite(canv,'frame7.bmp');
%present down E
canv=imrotate(E,270);
imwrite(canv,'frame8.bmp');


canv2=canv;
canv2(:)=1;
% dummy frames
%imwrite(canv2,'frame3.bmp');
%imwrite(canv2,'frame4.bmp');
%imwrite(canv,'frame2.bmp');
cd ..;


function startup

dummy=ones(10,10);
if isdir([pwd, filesep,'tempStimulus']) == 0;
    mkdir(pwd,'tempStimulus');
    cd([pwd,filesep,'tempStimulus']);
%     imwrite(dummy,'frame2.bmp');
%     imwrite(dummy,'frame3.bmp');
%     imwrite(dummy,'frame4.bmp');
%     imwrite(dummy,'frame5.bmp');
%     imwrite(dummy,'frame6.bmp');
%     imwrite(dummy,'frame7.bmp');
%     imwrite(dummy,'frame8.bmp');
else
    cd([pwd, filesep,'tempStimulus']);
%     delete *.bmp
%     delete *.buf
%     imwrite(dummy,'frame2.bmp');
%     imwrite(dummy,'frame3.bmp');
%     imwrite(dummy,'frame4.bmp');
%     imwrite(dummy,'frame5.bmp');
%     imwrite(dummy,'frame6.bmp');
%     imwrite(dummy,'frame7.bmp');
%     imwrite(dummy,'frame8.bmp');
end


cd ..;





