-- Cast Lingo ParentScript HavokStepCallbackUltrarapido.ls

property n, havokRigidBody
global havok

on new me
  n = 2
  havokRigidBody = []
  havokRigidBody[1] = havok.rigidBody("AutoPlayer")
  havokRigidBody[2] = havok.rigidBody("FurgoneCPU")
  return me
end

on step me, timeStep
  repeat with i = 1 to n
    havokRigidBody[i].applyAngularIpulse(-havokRigidBody.angularVelocity)
  end repeat
end
