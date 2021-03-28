function lifetimeBoost = get_lifetime_boost(simDurWks, lifeRemain, designLifeYrs, lifeMult)
% Function to compute life score boost for planning (exp decay fnct)
%lifeMult = 100;
lambda = -5;
yrToWks = 52; 

designLifeWks = designLifeYrs * yrToWks; % wks
lifeRemainWks = round(lifeRemain * designLifeYrs * yrToWks,0);
%simDurWks     = simDur * 52;

% Use 0-1 as input to exp decay plot
timeVals  = linspace(0,1,designLifeWks);

% Calculate curve with 0-1 values
lifeCurve = lifeMult * exp(lambda*timeVals);

% Pull out appropriate section of life curve
lifeCurveLeft = lifeCurve(1:lifeRemainWks);

% Account for actual simulation duration
numWksFill = simDurWks - lifeRemainWks;

% Determine how the remaining life curve fits with the simulation time
if numWksFill > 0     % Lifetime expected to run out during sim
    fillVals(1:numWksFill) = lifeMult;
    lifetimeBoost = [fillVals,lifeCurveLeft];
elseif numWksFill < 0 % Lifetime expected to outlive sim
    lifetimeBoost = lifeCurveLeft(1:simDurWks);
else                  % Lifetime exactly the same as the simtime
    lifetimeBoost = lifeCurveLeft;
end

lifetimeBoost = fliplr(lifetimeBoost);

end