function totalDeltaV = compute_deltaV_for_sequence(Agent, Agent_Tasks, RSOs, JD0, numWeeks)

daysInWk = 7;
taskInds = Agent_Tasks.path(Agent_Tasks.path > 0);
numTasks = length(taskInds);

totalDeltaV = 0;
for iTask = 1:(numTasks)
    
    if isequal(iTask,1)
        
        JD = JD0;
        StartLoc = Agent;
        
        targetDeltaWks = Agent_Tasks.times(iTask);
        
    else
        
        
        % Identify future visit time duration
        targetDeltaWks = Agent_Tasks.times(iTask) - Agent_Tasks.times(iTask - 1) - durationWks;
        
        %Output = RendezvousFunc_weeks_updated(Agent,RSOs(Agent_Tasks.path(iTask)), JD0, JD0,CBBA_Params.num_weeks);
        
        % Find previous task location and accompanying time (JDnew)
        JD = JDnew; % + (Agent_Tasks.times(iTask - 1) * daysInWk);
        
        % Previous task information (start location)
        locInd = Agent_Tasks.path(iTask - 1);
        StartLoc.SMA  = RSOs(locInd).SMA;
        StartLoc.INCL = RSOs(locInd).INCL;
        StartLoc.RAAN = RSOs(locInd).RAAN;
        
    end
    
    targetTask = Agent_Tasks.path(iTask);
    TargetLoc  = RSOs(targetTask);
    
    
    S = RendezvousFunc_weeks_updated(StartLoc,TargetLoc,JD,JD0,numWeeks);
    
    if targetDeltaWks < 1
        targetDeltaWks = 1;
    end

    deltaV = interp1(S.Week, S.RSO.deltaV, targetDeltaWks);
    
    % Check for a NaN delta-V
    if isnan(deltaV)
        validInd = find(~isnan(S.RSO.deltaV));
        validInd = validInd(1);
        
        deltaV = S.RSO.deltaV(validInd);
    end
    
    %deltaV = S.RSO.deltaV(targetDeltaWks);
    
    totalDeltaV = totalDeltaV + deltaV;
    
    %JD0 = JD;
    StartLoc = TargetLoc;
    
    durationWks = RSOs(targetTask).duration;
    JDnew = JD + (targetDeltaWks + durationWks) * daysInWk;
    
end



