%% VAS rating main script
%% A.G. Mitchell - 25.02.2022
% Developed from code by Camila Deolindo & Francesca Fardo

% Last edit - 25.02.2022

%% Load parameters
tgiRating_loadParams;

%% Keyboard & keys configuration
%[keys] = keyConfig();

% Reseed the random-number generator
%SetupRand;

%% Psychtoolbox settings
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

scr = Screen('Screens');
scrNr = max(scr);
white = WhiteIndex(scrNr);
black = BlackIndex(scrNr);

%% Prepare to start
%  try
    % Check if window is already open (if not, open screen window) 
     [win, winRect] = PsychImaging('OpenWindow', scrNr, black);
    
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

KbStrokeWait;
sca;