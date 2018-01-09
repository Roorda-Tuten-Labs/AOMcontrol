function [hAomControl, aom_fig_handle, CFG] = initialize(CFG, file_ext)
% initialize an experiment.
%
global VideoParams StimParams SYSPARAMS

if nargin < 2
    file_ext = 'bmp';
end

% get experiment config data stored in appdata for 'hAomControl'
hAomControl = getappdata(0,'hAomControl');

% This is a subroutine located at the end of this file. Generates some
% default stimuli
stim.create_default_stim();

if CFG.run_calibration
    % don't record videos when running calibration
    VideoParams.vidrecord = 0;
end

if isstruct(CFG) == 1
    if CFG.ok == 1
        StimParams.stimpath = fullfile(pwd, 'tempStimulus', filesep);
        VideoParams.vidprefix = CFG.initials;

        if CFG.record == 1
            VideoParams.videodur = CFG.videodur;
        end

        % sets VideoParam variables
        set_VideoParams_PsyfileName();  
        
        % Appears to load stimulus into buffer. Called here with parameter
        % set to 1. This seems to load some default settings. Later calls
        % send user defined settings via netcomm.
        Parse_Load_Buffers(1);

    else
        return;
    end
end

% get handle to aom gui
aom_fig_handle = aom.setup_aom_gui();

% --- set up stim and sys params.
% Turn ON AOMs
SYSPARAMS.aoms_state(1)=1; % SWITCH IR ON
SYSPARAMS.aoms_state(2)=1; % SWITCH RED ON
SYSPARAMS.aoms_state(3)=1; % SWITCH GREEN ON

% Make sure ending is correct for system? Not sure exactly why this needs
% to be set here.
StimParams.stimpath = fullfile(StimParams.stimpath, filesep);
% Make sure calling bmp or buf
StimParams.fext = file_ext;

end