function agentS = generate_agents(numAgents,seedSMA,sigmaSMA,seedInc,sigmaInc,seedRAAN,sigmaRAAN, seedDv,sigmaDv, typeVal)


agentS = struct('family','','id',{},'type',{},'SMA',{},'INCL',{},'RAAN',{},'life_remaining',{},'design_life',{});
for iAgent = 1:numAgents
    
    agentS(iAgent).family = 'agent';
    
    agentS(iAgent).id   = iAgent;
    agentS(iAgent).type = typeVal;
    
    % Orbit Parms
    agentS(iAgent).SMA  = seedSMA + sigmaSMA * randn(1);
    agentS(iAgent).INCL = seedInc + sigmaInc * randn(1);
    agentS(iAgent).RAAN = seedRAAN + sigmaRAAN * randn(1);
    
    % Delta-V capability
    agentS(iAgent).DV = seedDv + sigmaDv * randn(1);
    
    % Agent spacecraft properties
    agentS(iAgent).life_remaining = 1;
    agentS(iAgent).design_life = 10;
    
end

end