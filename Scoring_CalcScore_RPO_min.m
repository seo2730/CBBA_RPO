% Copyright 2010
% Massachusetts Institute of Technology
% All rights reserved
% Developed by the Aerospace Controls Lab, MIT

%---------------------------------------------------------------------%
% Calculates marginal score of doing a task and returns the expected
% start time for the task.
%---------------------------------------------------------------------%

function [score, minStartTime, maxStartTime] = Scoring_CalcScore_RPO_min(CBBA_Params,agent,rsoCurr,rsoPrev,timePrev,taskNext,timeNext, CBBA_Data, tasks)
    
dvMultiplier = 50;
lambdaDV     = -4;

% if((agent.type == CBBA_Params.AGENT_TYPES.QUAD) || ...
%    (agent.type == CBBA_Params.AGENT_TYPES.CAR))
numWeeksToEval = round(CBBA_Params.sim_years * 52,1);
 
    if(isempty(rsoPrev)) % First task in path
        startDV = 0;
        
        % Compute start time of task
        
        Output = RendezvousFunc_weeks_updated(agent,rsoCurr,CBBA_Params.JD,CBBA_Params.JD,numWeeksToEval);
        valid = find(~isnan(Output.RSO.deltaV));
        
        if ~isempty(valid)
            %dt = Output.Week(valid(1));
            %minStart = taskCurr.start + dt; % Soonest time feasible
            
            % Minimum start time is the largest of either the start of
            % task availability or a valid potential access [weeks relative
            % to JD start]
            minStartTime = max(rsoCurr.start,Output.Week(valid(1))); %Output.JD(valid(1));
            
        else
            error('Problem with timing. Valid time not found.')
            %minStart = inf;
        end
        
        %dt = sqrt((agent.x-taskCurr.x)^2 + (agent.y-taskCurr.y)^2 + (agent.z-taskCurr.z)^2)/agent.nom_vel;
        %minStart = max(taskCurr.start, agent.avail + dt);
        
    else % Not first task in path
        
        % Calculate the current delta-V required for the currently planned task(s)      
        startDV = compute_deltaV_for_sequence(agent, CBBA_Data(agent.id), tasks, CBBA_Params.JD, CBBA_Params.num_weeks);
        
        
        % Put in new JD associated with previous task (NEED TimePrev)
        Output = RendezvousFunc_weeks_updated(rsoPrev,rsoCurr,timePrev,CBBA_Params.JD,numWeeksToEval);
        valid  = find(~isnan(Output.RSO.deltaV));
        
        if ~isempty(valid)
            
            % Relative weeks for reference
            dt = Output.Week(valid(1));
            minStartTime = max(rsoCurr.start, timePrev + rsoPrev.duration + dt);

            %minStart = Output.JD(valid(1));
        else
            error('Problem with timing. Valid time not found.')
            %minStart = inf;
        end
        
    
    end
    
    if(isempty(taskNext)) % Last task in path
        maxStartTime = rsoCurr.end;
    else % Not last task, check if we can still make promised task
        
        if (isempty(timePrev))
            Output = RendezvousFunc_weeks_updated(agent,rsoCurr,CBBA_Params.JD,CBBA_Params.JD,numWeeksToEval);
            %Output = RendezvousFunc_weeks(agent,taskCurr,CBBA_Params.JD,CBBA_Params.JD,numWeeksToEval);
        else
            Output = RendezvousFunc_weeks_updated(rsoPrev,rsoCurr,timePrev,CBBA_Params.JD,numWeeksToEval);
        end
        
        valid  = find(~isnan(Output.RSO.deltaV));
        
        dt = Output.Week(valid(1));
        
        %dt = sqrt((taskNext.x-taskCurr.x)^2 + (taskNext.y-taskCurr.y)^2 + (taskNext.z-taskCurr.z)^2)/agent.nom_vel;
        
        maxStartTime = min(rsoCurr.end, timeNext - rsoCurr.duration - dt); %i have to have time to do task m and fly to task at j+1
        
    end

    % Compute score using Output structure, combine with cost and then
    % determine bestStartTime
    %beta = Output.RSO.Beta;
    %lightingReward = (-0.0004 .* beta.^3) + (0.06 .* beta.^2) + (-1.3 .* beta) + 22;
    
    %eolJD = round(CBBA_Params.JD + taskCurr.life_remaining_at_start * taskCurr.design_life * 365);
    
    %lifeMult = 100;
    %lambdaVal = -5;
    
   %lifeRemainReward = lifeMult * exp(taskCurr.lambda * taskCurr.life_remaining_at_start);
   % lifetimeReward = 1
    
    %reward = lightingReward + lifeRemainReward + taskCurr.score_fun; %
    reward = rsoCurr.score; %taskCurr.value*exp(-taskCurr.lambda*(minStartTime-taskCurr.start));

    % Subtract fuel cost.  Implement constant fuel to ensure DMG.
    % NOTE: This is a fake score since it double counts fuel.  Should
    % not be used when comparing to optimal score.  Need to compute
    % real score of CBBA paths once CBBA algorithm has finished
    % running.
    
    % Find intersection of valid task time and min/max start times
    
    %dvInds = intersect(rsoCurr.start:rsoCurr.end,valid);
    dvInds     = intersect(minStartTime:maxStartTime,valid);
    dvTaskCost = max(Output.RSO.deltaV(dvInds));
    
    
    
    newDV = compute_deltaV_for_sequence(agent, CBBA_Data(agent.id), tasks, CBBA_Params.JD, CBBA_Params.num_weeks);
    
    %Output = RendezvousFunc_weeks_updated(agent,rsoCurr,CBBA_Params.JD,CBBA_Params.JD,numWeeksToEval);
    
    
    
    
    penalty = dvMultiplier * exp(lambdaDV *(agent.DV - dvTaskCost));
    
    %penalty = dvMultiplier * max(Output.RSO.deltaV(dvInds));
    
    
    
    
    
    
    %penalty = dvMultiplier * rand(1); % * Output.RSO.deltaV; %agent.fuel*sqrt((agent.x-taskCurr.x)^2 + (agent.y-taskCurr.y)^2 + (agent.z-taskCurr.z)^2);

    score = reward - penalty;

    %[maxScore,maxInd] = max(score);
    
    % Find time corresponding to maximum score and set as bestStartTime
    %bestStartTime = Output.Week(maxInd);
    %scoreVal      = maxScore;
    
    
    
% FOR USER TO DO:  Define score function for specialized agents, for example:
% elseif(agent.type == CBBA_Params.AGENT_TYPES.NEW_AGENT), ...  

% Need to define score, minStart and maxStart

% else
%     disp('Unknown agent type')
% end

return
