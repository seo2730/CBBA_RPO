function Output = RendezvousFunc_weeks_updated(Agent,RSO,JD,JD0,numWeeks)

% Number of RSOs to Assess
numRSO = size(RSO,2);

% Constants
J2 = 0.00108262668;
RE = 6378.137;
mu = 398600;

proxDV = 0.025; % [km/s] Fixed delta-V assumed for proximity operations

% Rendezvous rate
rendRateDegPerDay = 25; % [deg/day]

% Step Agent/RSO from JD0 to JD
if JD ~= JD0 % Don't perform if JD = JD0
    DJD = JD - JD0;
    Agent = OrbitStep(Agent,DJD);
    for j = 1:numRSO
        RSO(j) = OrbitStep(RSO(j),DJD);
    end
end

% Calculate RAAN Rates for RSOs and Agent
Agent.RAANdot = RAANRate(Agent);
for j = 1:numRSO
    RSO(j).RAANdot = RAANRate(RSO(j));
end

% Look forward in 1 week (7 day) increments
for week = 1:numWeeks
        
    % Save Future time to Output
    Output.JD(week) = JD + 7*week;
    Output.Week(week) = week;
    
    % Evaluate Rendezvous costs for each RSO
    for j = 1:numRSO
        
        % RSO Values
        ir = RSO(j).INCL;
        ar = RSO(j).SMA;
        Wr = RSO(j).RAAN;
        dr = RSO(j).RAANdot;
        
        rsoMeanAnom = sqrt(mu/ar^3);                    % [rad/sec]
        rsoTrueAnom = rsoMeanAnom * (week * 7*24*3600); % [rad]
        rsoTrueAnom = mod(rsoTrueAnom,2*pi());          % [rad]
        rsoRevsPerDay = (24 * 3600 * rsoMeanAnom) / (2*pi());
        
        % Agent Values
        ia = Agent.INCL;
        aa = Agent.SMA;
        Wa = Agent.RAAN;
                
        % Step 1: Node Alignment
        W_future = Wr + dr*week*604800; % RSO RAAN at future time due to drift (deg)
        dW = W_future - Wa; % delta-RAAN between RSO future position and Agent current position
        RAANdot_des = dW/(week*604800); % RAAN rate required for nodal alignment at future time (deg/sec)
        RAANdot_rps = RAANdot_des*pi/180; % RAAN rate required for nodal alignment at future time (rad/sec)
        SMA_des = ( (2.25*mu*(RE*RE*J2*cosd(ia))^2)/(RAANdot_rps*RAANdot_rps) )^(1/7); % Altitude to achieve desired drift rate
        if aa < SMA_des % Need to increase altitude
            a1 = aa;
            a2 = SMA_des;
        else % Need to decrease altitude
            a1 = SMA_des;
            a2 = aa;
        end
        % 2-burn Hohmann transfer from a1 to a2
        dV1 = sqrt(mu/a1)*(sqrt((2*a2)/(a1+a2))-1);
        dV2 = sqrt(mu/a2)*(1-sqrt((2*a2)/(a1+a2)));
        
        % Calculate phase angle based on RSO drift altitude
        agentMeanAnom = sqrt(mu/SMA_des^3);                    % [rad/sec]
        agentTrueAnom = agentMeanAnom * (week * 7*24*3600); % [rad]
        agentTrueAnom = mod(agentTrueAnom,2*pi());          % [rad]
        
        phaseAngleDeg = 180/pi() * (agentTrueAnom - rsoTrueAnom);
        numPhaseDays  = abs(phaseAngleDeg/rendRateDegPerDay);
        numRevs       = floor(rsoRevsPerDay * numPhaseDays);
        if isequal(numRevs,0)
            numRevs = 1;
        end
        
        kTgt          = numRevs;
        phaseAngleRad = phaseAngleDeg * pi()/180;
        [dVPhase,~] = coorb_rend_phasing(ar, phaseAngleRad, kTgt, kTgt);
        
        % Step 2: Altitude Matching
        if SMA_des < ar % Need to increase altitude
            a1 = SMA_des;
            a2 = ar;
        else % Need to decrease altitude
            a1 = ar;
            a2 = SMA_des;
        end
        dV3 = sqrt(mu/a1)*(sqrt((2*a2)/(a1+a2))-1);
        dV4 = sqrt(mu/a2)*(1-sqrt((2*a2)/(a1+a2)));
        
        % Step 3: Inclination Matching
        v = sqrt(mu/ar);
        di = abs(ir-ia);
        dV5 = 2*v*sind(di/2);
        
        % Beta Angle of RSO Orbit at given time
        n     = JD + (week*7) - 2451545; % Days since J2000
        g     = 357.528 + 0.9856003*n; % Solar mean anomaly
        lam   = rem(280.460 + 0.9856474*n,360) + 1.915*sind(g) + 0.02*sind(2*g); % Ecliptic longitude
        obq   = 23.439 - 4.00e-7*n; % Obliquity of ecliptic
        Worb  = rem(W_future,360); % Future RAAN
        temp1 = sind(ir)*sind(Worb)*cosd(lam);
        temp2 = sind(ir)*cosd(Worb)*sind(lam)*cosd(obq);
        temp3 = cosd(ir)*sind(lam)*sind(obq);
        sinB  = temp1 - temp2 + temp3;
        Beta  = asind(sinB);
        
        % Save RSO data to Output
        Output.RSO(j).SMA(week)  = ar; % Final altitude (km)
        Output.RSO(j).INCL(week) = ir; % Final inclination (deg)
        raan = rem(W_future,360);
        if raan < -180
            raan = raan + 360;
        elseif raan > 180
            raan = raan - 360;
        end
        Output.RSO(j).RAAN(week) = raan; % Final RAAN (deg)
        if SMA_des < 6700
            Output.RSO(j).deltaV(week) = NaN; % Orbits below minimum altitude not allowed
        else
            Output.RSO(j).deltaV(week) = abs(dV1) + abs(dV2) + abs(dV3) + abs(dV4) + abs(dV5) + abs(dVPhase) + abs(proxDV); % Total delta-V
        end
        Output.RSO(j).a_star(week)       = SMA_des; % Desired altitude for transfer
        Output.RSO(j).deltaV_Node(week)  = abs(dV1) + abs(dV2); % Delta-V for nodal alignment
        Output.RSO(j).deltaV_Alt(week)   = abs(dV3) + abs(dV4); % Delta-V for altitude matching
        Output.RSO(j).deltaV_Inc(week)   = abs(dV5); % Delta-V for inclination matching
        Output.RSO(j).deltaV_Phase(week) = abs(dVPhase); % Delta-V for phasing
        Output.RSO(j).deltaV_Prox(week)  = abs(proxDV); % Delta-V for prox ops
        
        Output.RSO(j).dW(week)           = dW; % RAAN transfer (deg)
        Output.RSO(j).Beta(week)         = Beta; % Orbit beta angle (deg)
        Output.RSO(j).RAANdot(week)      = RSO(j).RAANdot; 
        
    end
end

end

function [xFuture] = OrbitStep(x,deltaJD)
% Calculate RAAN at future time

    xFuture = x;
    RAANdot = RAANRate(x);
    xFuture.RAAN = rem(x.RAAN + RAANdot*(deltaJD*86400),360);

end

function RAANdot = RAANRate(X)
% Calculate RAAN rate in deg/sec
    
    J2 = 0.00108262668;
    RE = 6378.137;
    mu = 398600;
    
    a = X.SMA;
    i = X.INCL;
    
    RAANdot_rps = -1.5*sqrt(mu/a^7)*RE*RE*J2*cosd(i);
    RAANdot = RAANdot_rps*180/pi;

end