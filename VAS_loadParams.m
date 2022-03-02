%% Define parameters required for VAS presentation
%
% 
%
% A G Mitchell 02/03/2022
% Last edit: 02/03/2022

%% Key flags
                                                 
vars.control.inputDevice    = 1;   % Response method for button presses 1 - mouse, 2 - keyboard 
% Now it works only for MOUSE
% need to develop keyboard response

%% Task parameters

%Trials
vars.task.NTrialsTotal       = 6; %50 % Total number of trials
vars.task.NTrialsChangeP     = 2; %5  % Regularity that participant changes thermode position. If you don't want this, please make it equal to vars.task.NTrialsTotal 

%Times
%vars.task.jitter             = randInRange(1,3,[1,vars.task.NTrialsTotal]); % time between the beginning of the trial and the beginning of the stimulation
vars.task.feedbackBPtime     = 0.5; % this determines how long the feedbacks "button press detected" is shown on the screen
%vars.task.ITI                = 6 - (vars.task.jitter + vars.task.feedbackBPtime);
vars.task.movingT            = 3; %Time to move the thermode to adjacent position
vars.task.RespT              = 10;    % Time to respond

%% Temperatures: Loading Outcomes from previous Experiments
%vars.task.Ttol               = 0.5;  %Tolerance to indicate that stimulator did not reach temperature.

% try
%     out1 = load(strcat(vars.dir.OutputFolder, 'Part1_', vars.ID.UniqueFileName, '.mat'));
% out1=load('C:\Users\mgane\Documents\Camila\FAST\C300_CI.mat');%% FOR TEST ONLY DELETE! Use line above
%     out3 = load(strcat(vars.dir.OutputFolder, 'Part3_', vars.ID.UniqueFileName, '.mat'));
% out3 = load(strcat(vars.dir.OutputFolder, 'Part2_', vars.ID.UniqueFileName, '.mat'));%% FOR TEST ONLY DELETE! Use line above
% 
% vars.fast.myfast = out1.myfast;%% FOR TEST ONLY DELETE!Use line below
%     vars.fast.myfast = out1.Results.myfast{end};
%     vars.fast.pArray = [0.25 0.5 0.75];
%     
%     Extract values for the selected probabilities.
%     vars.fast.allTcold = sort(vars.fast.myfast.data(:,1));
%     vars.fast.TwarmInpArray = arrayfun(@(x) squeeze(fastCalcYs(vars.fast.myfast, vars.fast.allTcold,x)),vars.fast.pArray, 'UniformOutput',false);
%     
%     Extract Twarm for the correspondent Tcold
%     vars.task.Tbaseline = out3.vars.task.Tbaseline;
%     vars.task.TcoldTGI = out3.vars.task.TcoldTGI;
%     vars.task.TwarmTGI = cellfun(@(x) x(find(vars.fast.allTcold==vars.task.TcoldTGI,1)),vars.fast.TwarmInpArray);
% 
%     Generate a sequence of stimuli
%     vars.task.TwarmSequence = repmat(vars.task.TwarmTGI,1,ceil(vars.task.NTrialsTotal/3));
%     vars.task.TwarmSequence = vars.task.TwarmSequence (randperm(vars.task.NTrialsTotal));
% 
%     clear ('out1','out3')
% catch
%     error('Results from previous parts of the experiment are missing or with very few trials.')
% end


%% Instructions
vars.instructions.textSize = 35;

vars.instructions.Position = {'Please place the thermode in position 3.',...
                               'Please place the thermode in position 1.',...
                                'Please place the thermode in position 2.'};

vars.instructions.Question = {'At the moment, how much is the stimulus BURNING?',...
                               'At the moment, how WARM is the stimulus?',...
                               'At the moment, how COLD is the stimulus?'}; 
                           
vars.instructions.whichQuestion = [1 1 1]; %Enable or disable question

vars.instructions.whichKey = {'LR','UD'}; % Left/Right. Up/Down. If you are using the mouse as an input device let this entirely as LR.
vars.instructions.Feedback ={'Yes' 'No';...
                            'Warm' 'Cold'}; %First Feedback for 1. Then for 0.

vars.instructions.Start = 'Threshold detection \n \n Please position the thermode to location 1. \n \n You will receive a series of stimuli and be asked to rate how you perceived them. Please move the indicator along the line and confirm with a left click, as fast and accurately as possible. \n \n If you do not perceive the sensation that is described in the question, make sure to select the extreme left position (rating = 0/Do not feel it at all).\n \n \n \n  Press SPACE to continue.';
        
vars.instructions.show = 1:vars.task.NTrialsChangeP:vars.task.NTrialsTotal; %When to ask participant to change thermode position

vars.instructions.ConfEndPoins = {'Not at all', 'Extreme'};
