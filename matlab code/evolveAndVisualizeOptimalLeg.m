%% compute and visualize the optimal design
% takes task and robot selection to load corresponding towr motion data
% then computes motion of EE relative to hip, and evolves the link lengths
% to minimize sum of joint torques over full motion for this relative
% motion

clear all 
close all

% select task and robot, configuration and end effector which is to be optimized
taskSelection = 'universalTrot';
robotSelection = 'universal';
[removalRatioStart, removalRatioEnd] = getSuggestedRemovalRatios(taskSelection);
load(taskSelection);
dt = t(2) - t(1);
configSelection = 'X'; % unreliable
EEselection = 'LF';
jointCount = 4; %for forward dynamics EE position computation (only works for =4)

% genetic algorithm parameters
upperBoundMultiplier = 5;
lowerBoundMultiplier = 0.1;
maxGenerations = 30;
populationSize = 30;


if (EEselection == 'LF') | (EEselection == 'RF')
    selectFrontHind = 1;
    else selectFrontHind = 2;
end


%% get quadruped properties
quadruped = getQuadrupedProperties(robotSelection);

%% get the relative motion of the end effectors to the hips
[relativeMotionHipEE, IF_hip, C_IBody] = getRelativeMotionEEHips(quat, quadruped, base, EE, dt);

%% get the liftoff and touchdown timings for each end effector
[tLiftoff, tTouchdown, minStepCount] = getEELiftoffTouchdownTimings(t, EE);

%% get the mean cyclic position and forces
[meanCyclicMotionHipEE, cyclicMotionHipEE, meanCyclicC_IBody, samplingStart, samplingEnd] = getHipEECyclicData(tLiftoff, tTouchdown, relativeMotionHipEE, EE, removalRatioStart, removalRatioEnd, dt, minStepCount, C_IBody);



%% evolve optimal link lengths
%initial guess at link lengths in mm so the values can be integers
initialLinkLengths(1) = round(1000*quadruped.hip(selectFrontHind).length); 
initialLinkLengths(2) = round(1000*quadruped.thigh(selectFrontHind).length);
initialLinkLengths(3) = round(1000*quadruped.shank(selectFrontHind).length);

[linkLengths, penaltyMin] = evolveOptimalLeg(maxGenerations, populationSize, initialLinkLengths, upperBoundMultiplier, lowerBoundMultiplier, taskSelection, robotSelection, configSelection, EEselection, removalRatioStart, removalRatioEnd, base, quat, t, EE, dt, jointCount)

quadruped.hip(selectFrontHind).length = linkLengths(1)/1000;
quadruped.thigh(selectFrontHind).length = linkLengths(2)/1000;
quadruped.shank(selectFrontHind).length = linkLengths(3)/1000;

%% visualize the optimized design
numberOfLoopRepetitions = 3;
viewVisualization = 1;

q.(EEselection).angle = inverseKinematics(meanCyclicMotionHipEE.LF.position, quadruped, EEselection, taskSelection, configSelection);
[robotConfig, config] = buildRobotRigidBodyModel(quadruped, q, EE, meanCyclicMotionHipEE, EEselection, numberOfLoopRepetitions, viewVisualization);

%% get joint torques of optimal design
[q.(EEselection).angVel, q.(EEselection).angAccel] = getJointVelocitiesUsingJacobian(EE, meanCyclicMotionHipEE, q, quadruped, 1, dt, EEselection);
jointTorque.(EEselection) = getInverseDynamics(EEselection, q, meanCyclicMotionHipEE, robotConfig, config);
