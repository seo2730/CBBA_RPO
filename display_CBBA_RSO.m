function root = display_CBBA_RSO(agents,rsos,jdEpoch, durationYrs)
%global root

disp('Loading STK...')
uiapp = actxserver('STK11.Application');
root = uiapp.Personality2;
uiapp.visible = 1;

% Create a new scenario
try
    root.CloseScenario();
    root.NewScenario('CBBA_Scenario');
catch
    root.NewScenario('CBBA_Scenario');
end

disp('STK Loaded.')

%% Set the unit preferences
root.UnitPreferences.SetCurrentUnit('DateFormat', 'UTCG');

%% Specify the times for the scenario
newEpochNum = jdEpoch - 1721058.5;
endDateNum  = newEpochNum + durationYrs*365;

epchStr = datestr(newEpochNum, 'dd mmm yyyy HH:MM:SS.fff');
endSim  = datestr(endDateNum, 'dd mmm yyyy HH:MM:SS.fff');

root.CurrentScenario.SetTimePeriod(epchStr, endSim);
root.CurrentScenario.Epoch = epchStr;

%% Generate RSOs

disp('Configuring RSO satellites...')

for iRSO = 1:length(rsos)
    missionSat = root.CurrentScenario.Children.New('eSatellite',sprintf('RSO_%d',iRSO));
    missionSat.SetPropagatorType('ePropagatorJ4Perturbation');
    
    % Classical orbital elements: SemiMajor, Eccentricity, Inclination, Arg of Perigee, RAAN, True Anomaly
    missionSat.Propagator.InitialState.Representation.AssignClassical('eCoordinateSystemICRF',...
        rsos(iRSO).SMA,...
        0,...
        rsos(iRSO).INCL,...
        0,...
        rsos(iRSO).RAAN,...
        0);
    
    missionSat.Propagator.EphemerisInterval.SetExplicitInterval(epchStr, endSim);
    missionSat.Propagator.InitialState.Epoch = epchStr;
    missionSat.Propagator.Propagate;
end

disp('RSOs complete.')

%% Generate Agents

disp('Configuring agent satellites...')

for iAgent = 1:length(agents)
    missionSat = root.CurrentScenario.Children.New('eSatellite',sprintf('Agent_%d',iAgent));
    missionSat.SetPropagatorType('ePropagatorJ2Perturbation');
    
    % Classical orbital elements: SemiMajor, Eccentricity, Inclination, Arg of Perigee, RAAN, True Anomaly
    missionSat.Propagator.InitialState.Representation.AssignClassical('eCoordinateSystemICRF',...
        agents(iAgent).SMA,...
        0,...
        agents(iAgent).INCL,...
        0,...
        agents(iAgent).RAAN,...
        0);
    
    missionSat.Propagator.EphemerisInterval.SetExplicitInterval(epchStr, endSim);
    missionSat.Propagator.InitialState.Epoch = epchStr;
    missionSat.Propagator.Propagate;
end

disp('Agents complete.')
root.Rewind;
keyboard;
