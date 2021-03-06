function [springTorque, springDeformation] = computeFinalJointDeformation(Leg, heuristic, qPrevious, EE_force, linkCount, rotBodyY, EEselection)
kTorsionalSpring = heuristic.torqueAngle.kTorsionalSpring;

% compute jacobian to obtain coordinates of AFE, DFE, and EE.
[~, ~, ~, ~, ~, r_H_04, r_H_05, r_H_0EE]  = jointToPosJac(Leg, rotBodyY, qPrevious, EEselection);

R_EE = r_H_0EE;
if linkCount == 3
    R_finalJoint = r_H_04;
elseif linkCount == 4
    R_finalJoint = r_H_05;
end

% compute spring deformation as cross product of moment arm and end
% effector force
R_EEfinalJoint = R_EE - R_finalJoint;
springTorque = cross(R_EEfinalJoint, EE_force);
springTorque = springTorque(1,2); % spring torque about y joint is the relevant torque
springDeformation = springTorque/kTorsionalSpring; 
end