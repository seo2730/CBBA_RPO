function Output = RendezvousFunc_weeks(Agent,RSO,JD,JD0,numWeeks)

error('Do not use!')
% Number of RSOs to Assess
numRSO = size(RSO,2);

% Constants
J2 = 0.00108262668;
RE = 6378.137;
mu = 398600;
epsilon = 23.439;
drate = 1.990986593e-7;
%JD0 = 2451545;
theta0 = 0;

% Calculate RAAN Rates for RSOs and Agent
i = Agent.INCL;
a = Agent.SMA;
Agent.RAANdot = -1.5*sqrt(mu/a^7)*RE*RE*J2*cosd(i);
for j = 1:numRSO
    i = RSO(j).INCL;
    a = RSO(j).SMA;
    RSO(j).RAANdot = -1.5*sqrt(mu/a^7)*RE*RE*J2*cosd(i);
end

% Look forward in 1 week (7 day) increments
for week = 1:numWeeks
        
    % Save Future time to Output
    Output.JD(week) = JD + 7*week;
    Output.Week(week) = week;
    
    % Evaluate Rendezvous costs for each RSO
    for j = 1:numRSO
        
        % RSO Values
        i = RSO(j).INCL;
        a = RSO(j).SMA;
        W = RSO(j).RAAN;
        d = RSO(j).RAANdot;
        % Agent Values
        ia = Agent.INCL;
        aa = Agent.SMA;
        Wa = Agent.RAAN;
        
        % Step 1: Node Alignment
        W_future = W + d*week*604800;
        dW = W_future - Wa;
        RAANdot_des = dW/(week*604800);
        SMA_des = (2.25*mu*RE*RE*RE*RE*J2*J2*cosd(ia)*cosd(ia)/RAANdot_des/RAANdot_des)^(1/7);
        if aa < SMA_des
            a1 = aa;
            a2 = SMA_des;
        else
            a1 = SMA_des;
            a2 = aa;
        end
        dV1 = sqrt(mu/a1)*(sqrt((2*a2)/(a1+a2))-1);
        dV2 = sqrt(mu/a2)*(1-sqrt((2*a2)/(a1+a2)));
        
        % Step 2: Altitude Matching
        dV3 = sqrt(mu/a)*(sqrt(2*SMA_des/(a+SMA_des))-1);
        dV4 = sqrt(mu/SMA_des)*(1-sqrt(2*a/(a+SMA_des)));
        
        % Step 3: Inclination Matching
        v = sqrt(mu/a);
        di = abs(i-ia);
        dV5 = 2*v*sind(di/2);
        
        % Beta Angle of RSO Orbit at given time
        del = theta0 + drate*(week*604800 + (JD-JD0)*86400);
        temp1 = sind(epsilon)*cosd(i)*sind(del);
        temp2 = cosd(epsilon)*sind(i)*cosd(W)*sind(del);
        temp3 = sind(i)*sind(W)*cosd(del);
        sinB = temp1 - temp2 + temp3;
        Beta = asind(sinB);
        
        % Save RSO data to Output
        Output.RSO(j).SMA(week) = a;
        Output.RSO(j).INCL(week) = i;
        Output.RSO(j).RAAN(week) = W_future;
        if SMA_des < 6700
            Output.RSO(j).deltaV(week) = NaN; % Orbits below minimum altitude not allowed
        else
            Output.RSO(j).deltaV(week) = abs(dV1) + abs(dV2) + abs(dV3) + abs(dV4) + abs(dV5);
        end
        Output.RSO(j).a_star(week) = SMA_des;
        Output.RSO(j).deltaV_Node(week) = abs(dV1) + abs(dV2);
        Output.RSO(j).deltaV_Alt(week)  = abs(dV3) + abs(dV4);
        Output.RSO(j).deltaV_Inc(week)  = abs(dV5);
        Output.RSO(j).dW(week) = dW;
        Output.RSO(j).Beta(week) = Beta;
        
    end
end