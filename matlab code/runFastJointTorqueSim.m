%% run simulation from beginning to joint torque 
%  computation with only necessary steps for fast computation

function penalty = runFastJointTorqueSim(quadruped, linkLengths, selectFrontHind, taskSelection, removalRatioStart, removalRatioEnd, base, quat, t, EE, dt, configSelection, EEselection, jointCount)

%% get quadruped properties 
% also need to recalculate mass
quadruped.hip(selectFrontHind).length = linkLengths(1)/1000;
quadruped.thigh(selectFrontHind).length = linkLengths(2)/1000;
quadruped.shank(selectFrontHind).length = linkLengths(3)/1000;

quadruped.hip(selectFrontHind).mass = quadruped.legDensity * pi*(quadruped.hip(selectFrontHind).radius)^2   * linkLengths(1)/1000;
quadruped.thigh(selectFrontHind).mass = quadruped.legDensity * pi*(quadruped.thigh(selectFrontHind).radius)^2 * linkLengths(2)/1000;
quadruped.shank(selectFrontHind).mass = quadruped.legDensity * pi*(quadruped.shank(selectFrontHind).radius)^2 * linkLengths(3)/1000;

%% get the relative motion of the end effectors to the hips
[relativeMotionHipEE, IF_hip, C_IBody] = getRelativeMotionEEHips(quat, quadruped, base, EE, dt);

%% get the liftoff and touchdown timings for each end effector
[tLiftoff, tTouchdown, minStepCount] = getEELiftoffTouchdownTimings(t, EE);

%% get the mean cyclic position and forces
[meanCyclicMotionHipEE, cyclicMotionHipEE, meanCyclicC_IBody, samplingStart, samplingEnd] = getHipEECyclicData(tLiftoff, tTouchdown, relativeMotionHipEE, EE, removalRatioStart, removalRatioEnd, dt, minStepCount, C_IBody);

%% Inverse kinematics to calculate joint angles for each leg joint
% these q0 give x config for universalStairs
% Final term is selectFrontHind 1 = front legs, 2 = hind legs

q.(EEselection).angle = inverseKinematics(meanCyclicMotionHipEE.LF.position, quadruped, EEselection, taskSelection, configSelection);

%% get joint positions (and more importantly EE position from forward dynamics)
r = getJointPositions(quadruped, q, jointCount, EEselection);

%% build robot model with configuration method - required for inverse dynamics solver
numberOfLoopRepetitions = 1;
viewVisualization = 0;

[robotConfig, config] = buildRobotRigidBodyModel(quadruped, q, EE, meanCyclicMotionHipEE, EEselection, numberOfLoopRepetitions, viewVisualization);

%% get joint velocities with inverse(Jacobian)* EE.velocity
  % the joint accelerations are then computed using finite difference
[q.(EEselection).angVel, q.(EEselection).angAccel] = getJointVelocitiesUsingJacobian(EE, meanCyclicMotionHipEE, q, quadruped, 1, dt, EEselection);

%% get joint torques using inverse dynamics
jointTorque.(EEselection) = getInverseDynamics(EEselection, q, meanCyclicMotionHipEE, robotConfig, config);

  %% penalty term for ga
  % sum of abs value of joint torques  
  % + term to prevent HAA from pointing upwards (values should always be
  %                                              close to zero)
  % + error to desired EE position
  % + knee joint below end effector (ie knee in ground)
  
  errorPositionEE = norm(meanCyclicMotionHipEE.(EEselection).position-r.(EEselection).EE);
  positionKneeEE = r.(EEselection).KFE - meanCyclicMotionHipEE.(EEselection).position(:,3);
  positionKneeEEPenalty = 0;
  
  if any(positionKneeEE < 0)
      positionKneeEEPenalty = 1000;
  end
  
  
  penalty = sum(sum((abs(jointTorque.(EEselection)(15:end,:))))) + 100*norm(q.(EEselection).angle(:,1)) + 100*errorPositionEE + positionKneeEEPenalty;

end