function tgiRating_main(vars, scr)
%
% Project: Implementation of Multidimensional TGI Threshold estimation
%
% Camila Sardeto Deolindo & Francesca Fardo 
% Last edit: 07/02/2022

%% Load the parameters
tgiRating_loadParams;

%% Define Results struct
% uniqueFilename = strcat(vars.dir.OutputFolder, 'Part',num2str(vars.control.taskN),'_', vars.ID.UniqueFileName, '.mat');
uniqueFilename = strcat(vars.dir.OutputFolder,vars.ID.UniqueFileName,'_part',num2str(vars.control.taskN),'.mat');

if ~exist(uniqueFilename)
    DummyDouble = ones(vars.task.NTrialsTotal,1).*NaN;
    DummyCell   = cell(size(DummyDouble));
    Results = struct('SubID',           {DummyDouble}, ...
                     'tcsData',         {DummyCell}, ...
                     'targetTwarm',     {DummyDouble}, ...
                     'targetTcold',     {DummyDouble}, ...
                     'vasResponse',     {repmat(DummyDouble,size(vars.instructions.whichQuestion))}, ...
                     'vasReactionTime', {repmat(DummyDouble,size(vars.instructions.whichQuestion))}, ...
                     'SOT_trial',       {DummyDouble}, ...
                     'SOT_jitter',      {DummyDouble}, ...
                     'SOT_stimOn',      {DummyDouble}, ...
                     'SOT_stimOff',     {DummyDouble}, ...
                     'SOT_ITI',         {DummyDouble}, ...
                     'TrialDuration',   {DummyDouble}, ...
                     'SessionStartT',   {DummyDouble}, ...
                     'SessionEndT',     {DummyDouble});            
else
    vars.ID.confirmedSubjN = input('Subject already exists. Do you want to continue anyway (yes = 1, no = 0)?    ');
    if vars.ID.confirmedSubjN
        load(uniqueFilename,'Results')
        vars.control.startTrialN = input('Define the trial number to restart from?   ');
        vars.ID.date_time = datestr(now,'ddmmyyyy_HHMMSS');
        vars.ID.DataFileName = strcat(vars.control.exptName, '_',vars.ID.subIDstring, '_', vars.ID.date_time);    % name of data file to write to
    else
        return
    end
end

%% Keyboard & keys configuration
[keys] = keyConfig();

% Reseed the random-number generator
SetupRand;

%% Prepare to start
%  try
    %% Check if window is already open (if not, open screen window) 
     [scr]=openScreen(scr);
    
    %% Dummy calls to prevent delays
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
    %% Start session
    Results.SessionStartT = GetSecs;            % session start = trigger 1 + dummy vols

    %% Run through trials
    WaitSecs(0.500);            % pause before experiment start
    thisTrial = vars.control.startTrialN; % trial counter (user defined)
    Results.vasResponse (thisTrial:end) = NaN; %Erase responses from defined trial onwards

    endOfExpt = 0;
    if thisTrial ~= 1
        Restarted = 1;   % If experiment was aborted, display thermode position in the first trial.
    else
        Restarted = 0;
    end

    while endOfExpt ~= 1       % General stop flag for the loop
                
        %% show instructions
        if any(vars.instructions.show == thisTrial) || (Restarted ==1)
            
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            if thisTrial ==1
                DrawFormattedText(scr.win, uint8([vars.instructions.Start]), 'center', 'center', scr.TextColour, 60); %#ok<FNDSB>
                [~, ~] = Screen('Flip', scr.win);
                
                while keys.KeyCode(keys.Space) == 0 % Wait for trigger
                    [~, ~, keys.KeyCode] = KbCheck;
                    WaitSecs(0.001);
                end
                
          else
                [~,whichInstruction] = min(abs(thisTrial-vars.instructions.show));
                whichInstruction = mod(whichInstruction,3)+1;
                DrawFormattedText(scr.win, uint8([vars.instructions.Position{whichInstruction}]), 'center', 'center', scr.TextColour, 60); %#ok<FNDSB>
                [~, ~] = Screen('Flip', scr.win);
                WaitSecs(vars.task.movingT);
            end
            
            [~, ~, keys.KeyCode] = KbCheck;
            WaitSecs(0.001);
            
            if keys.KeyCode(keys.Escape)==1 % if ESC, quit the experiment
                % Save, mark the run
                vars.control.RunSuccessfull = 0;
                vars.control.Aborted = 1;
                experimentEnd(vars, scr, keys, Results)
                return
            end
            
            new_line;
        end
        
        %% Trial starts: Configure temperatures and draw fixation point
        Tcold = single(round(vars.task.TcoldTGI,1)); %Round values so it interfaces better with stimulator
        Twarm = single(round(vars.task.TwarmSequence(thisTrial),1)); %Round values so it interfaces better with stimulator
        
        Results.SOT_trial(thisTrial) = GetSecs - Results.SessionStartT; % trial starts        
        
        % Draw Fixation
        [~, ~] = Screen('Flip', scr.win);            % clear screen
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        scr = drawFixation(scr); % fixation point
        [~, ~] = Screen('Flip', scr.win);
        
        %% Jitter
        WaitSecs(vars.task.jitter(thisTrial));
            
        %% Stimulation ON
        if ~vars.control.stimFlag
            disp('debugging without stimulation')
            Results.vasResponse(thisTrial,:)=NaN;
            Results.vasReactionTime(thisTrial,:)=NaN; %not interested in cold/warm
        else
            vars.control.thisTrial = thisTrial;
            while any(isnan(Results.vasResponse(thisTrial,find(vars.instructions.whichQuestion))))
                
                [vars.control.stimTime,stimOn, stimOff, tcsData]  = stimulate(vars,keys,2,vars.stim.durationS,Tcold,Twarm); % Stimulate TGI
                %%Brief feedback to experimenter
                disp(['Trial #' num2str(vars.control.thisTrial) ', Twarm = ' num2str(Twarm) ', Tcold = ' num2str(Tcold)])
                
                
                %% Get response: Ratings
                % Fetch the participant's ratings
                for question_type_idx=1:length(vars.instructions.whichQuestion)
                    if vars.instructions.whichQuestion(question_type_idx)==1
                        [Results.vasResponse(thisTrial,question_type_idx), ...
                            Results.vasReactionTime(thisTrial,question_type_idx)]= getVasRatings(keys, scr, vars,question_type_idx);
                    else
                        Results.vasResponse(thisTrial,question_type_idx) = NaN;
                        Results.vasReactionTime(thisTrial,question_type_idx) = NaN;
                    end
                end
                %% ITI
                stimulate(vars,keys,3,vars.task.ITI(thisTrial)); % stimulate ITI
                Results.TrialDuration(vars.control.thisTrial) = GetSecs;
            end
        end
        %% Update Results
        Results.SubID(thisTrial)        = vars.ID.subNo;
        Results.tcsData{thisTrial}      = tcsData;
        Results.targetTwarm(thisTrial)  = Twarm;
        Results.targetTcold(thisTrial)  = Tcold;
        Results.SOT_jitter(thisTrial)   = vars.task.jitter(thisTrial);
        Results.SOT_stimOn(thisTrial)   = stimOn;
        Results.SOT_stimOff(thisTrial)  = stimOff;
        Results.SOT_ITI(thisTrial)      = vars.task.ITI(thisTrial); 
        Results.SessionEndT             = GetSecs  - Results.SessionStartT;                           
        
        %% save data at every trial
        %save(strcat(vars.OutputFolder, vars.UniqueFileName), 'Results', 'vars', 'scr', 'keys' );
        save(uniqueFilename, 'Results', 'vars', 'scr', 'keys', '-regexp', ['^(?!', 'vars.control.ser' , '$).'] );

        
         %% Continue to next trial or time to stop? (max # trials reached)
        if (thisTrial == vars.task.NTrialsTotal)
            endOfExpt = 1;
        else
            % Advance one trial
            thisTrial = thisTrial + 1;
        end
        
    end % end trial

    
    vars.control.RunSuccessfull = 1;
    
    % Save, mark the run
    experimentEnd(vars, scr, keys, Results);
    
    ShowCursor;
    
  
% catch ME% Error. Clean up...
%     
%     % Save, mark the run
%     vars.control.RunSuccessfull = 0;
%     vars.control.Error = 1;
%     experimentEnd(vars, scr, keys, Results);
%     rethrow(ME)
end