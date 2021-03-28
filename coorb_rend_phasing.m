function [dV,aPhase] = coorb_rend_phasing(aTgt, phaseAngle, kTgt, kInt)
%--------------------------------------------------------------------------
% Title: coorb_rend_phasing
% This function computes the delta-V and semi-major axis of a phasing orbit
% that meets the phasing requirements specified in the input.
%--------------------------------------------------------------------------
% Input:
%   aTgt       - semi-major axis of target orbit [km]
%   phaseAngle - angle between target and interceptor. Measured from target
%       to the interceptor. Positive if in the same direction as orbital 
%       motion [radians]
%   kTgt       - number of target revs over which to conduct phasing [int]
%   kInt       - number of interceptor revs over which to conduct phasing
%   NOTE: Under almost all circumstances, kTgt and kInt will be equal
%
% Output:
%   dV   - delta-V required to perform phasing orbit and then
%          re-circularization after proper phasing reached [km/sec]
%   aPhase - the semi-major axis of the phasing orbit [km]
%--------------------------------------------------------------------------
mu = 398600; % [km^3/sec^2]

omegaTgt = sqrt(mu/aTgt^3);                             % [rad/sec]
tauPhase = (2*pi()*kTgt + phaseAngle) / omegaTgt;       % [sec]
aPhase   = (mu * (tauPhase/(2*pi()*kInt))^2 )^(1/3);    % [km]

if aPhase < 300
    error('Perigee too low!')
end

dV = 2 * abs( sqrt( (2*mu)/aTgt - mu/aPhase ) - sqrt(mu/aTgt) ); % [km/sec]

%==========================================================================
%                       END OF FUNCTION
%==========================================================================