function totalDeltaV = compute_deltaV_for_sequence_matrix(Agent, assignmentMatrix, RSOs, JD0, numWeeks)
%totalDeltaV = compute_deltaV_for_sequence_matrix(Agent, Agent_Tasks, RSOs, JD0, numWeeks)

%Agent       = taskMatrix(:,1);
agentTasks = assignmentMatrix(:,1);
taskTimes = assignmentMatrix(:,2);

daysInWk = 7;
taskInds = agentTasks; %Agent_Tasks.path(Agent_Tasks.path > 0);
numTasks = length(taskInds);

totalDeltaV = 0;
for iTask = 1:(numTasks)
    
    if isequal(iTask,1)
        
        JD = JD0;
        StartLoc = Agent;
        
        targetDeltaWks = taskTimes(iTask);
        
        % No previous task
        locInd = 0;
    else
        JD = JDnew; % + (Agent_Tasks.times(iTask - 1) * daysInWk);
        
        % Find previous task location at time JDnew
        locInd = assignmentMatrix(iTask - 1,1); %Agent_Tasks.path(iTask - 1);
        StartLoc.SMA  = RSOs(locInd).SMA;
        StartLoc.INCL = RSOs(locInd).INCL;
        StartLoc.RAAN = RSOs(locInd).RAAN;
        
        %targetDeltaWks = Agent_Tasks.times(iTask) - Agent_Tasks.times(iTask - 1) - durationWks;
        targetDeltaWks = taskTimes(iTask) - taskTimes(iTask - 1) - durationWks;
    end
    
    targetTask = agentTasks(iTask);
    TargetLoc  = RSOs(targetTask);
    
    
    S = RendezvousFunc_weeks_updated(StartLoc,TargetLoc,JD,JD0,numWeeks);
    
    if targetDeltaWks < 1
        targetDeltaWks = 1;
    end

    deltaV = interp1(S.Week, S.RSO.deltaV, targetDeltaWks);
    
    % Check for a NaN delta-V, meaning infeasible
    if isnan(deltaV)
        % Set deltaV to very large value since it is infeasible
        deltaV = 10000000;
        fprintf('Invalid time specified. Large DV assigned for task %d to task %d in %d weeks. \n',locInd,targetTask,round(targetDeltaWks))
        
        % Code below searches for next valid week for scheduling
        validInd = find(~isnan(S.RSO.deltaV));
        validInd = validInd(1);
        suggestDeltaV = S.RSO.deltaV(validInd);
        
        fprintf('Valid time starts at %d weeks and %2.3f km/s of delta-V. \n',round(S.Week(validInd)),suggestDeltaV)
    end
    
    %deltaV = S.RSO.deltaV(targetDeltaWks);
    
    totalDeltaV = totalDeltaV + deltaV;
    
    %JD0 = JD;
    StartLoc = TargetLoc;
    
    durationWks = RSOs(targetTask).duration;
    JDnew = JD + (targetDeltaWks + durationWks) * daysInWk;
    
end



