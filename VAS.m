%% VAS rating main script
%% A.G. Mitchell - 25.02.2022
% Developed from code by Camila Deolindo & Francesca Fardo

% Last edit - 02.03.2022

%% Load parameters
VAS_loadParams;

%% Keyboard & variable configuration
[keys] = keyConfig();

% Reseed the random-number generator
SetupRand;

vars.control.devFlag  = 1; % Development flag 1. Set to 1 when developing the task, will optimize stim size for laptop, not hide cursor

%% Psychtoolbox settings
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

%% Open a PTB window
scr.ViewDist = vars.ViewDist; % viewing distance
[scr] = displayConfig(scr);
AssertOpenGL;
if vars.control.devFlag
    [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray, [0 0 1000 1000]); %,[0 0 1920 1080] mr screen dim
else
    [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray); %,[0 0 1920 1080] mr screen dim
end
% PsychColorCorrection('SetEncodingGamma', scr.win, 1/scr.GammaGuess);

% Set text size, dependent on screen resolution
if any(logical(scr.winRect(:)>3000))       % 4K resolution
    scr.TextSize = 65;
else
    scr.TextSize = 28;
end
Screen('TextSize', scr.win, scr.TextSize);

% Set priority for script execution to realtime priority:
scr.priorityLevel = MaxPriority(scr.win);
Priority(scr.priorityLevel);

% Determine stim size in pixels
scr.dist        = scr.ViewDist;
scr.width       = scr.MonitorWidth;
scr.resolution  = scr.winRect(3:4);                    % number of pixels of display in horizontal direction

%% Prepare to start
%  try
    % Check if window is already open (if not, open screen window) 
    [scr]=openScreen(scr);
    
    % Dummy calls to prevent delays
    vars.control.RunSuccessfull = 0;
    vars.control.Aborted = 0;
    vars.control.Error = 0;
    vars.control.thisTrial = 1;
    vars.control.abortFlag = 0;
    [~, ~, keys.KeyCode] = KbCheck;
    
%     vars.ValidTrial = zeros(1,2);
%     vars.RunSuccessfull = 0;
%     vars.Aborted = 0;
%     vars.Error = 0;
%     WaitSecs(0.1);
%     GetSecs;
%     vars.Resp = 888;
%     vars.ConfResp = 888;
%     vars.abortFlag = 0;
%     WaitSecs(0.500);
%     [~, ~, keys.KeyCode] = KbCheck;

%% Run VAS
thisTrial = 1;
for question_type_idx=1:length(vars.instructions.whichQuestion)
    [Results.vasResponse(thisTrial,question_type_idx), ...
        Results.vasReactionTime(thisTrial,question_type_idx)]= getVasRatings(keys, scr, vars,question_type_idx);
end

sca;