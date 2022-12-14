-- Cast Lingo ParentScript HavokStepCallbackAttritoViscosoGenericoSingolo.ls

property linearFactor, angularFactor, havokRigidBody
global havok

on new me, f1, f2
  linearFactor = f1
  angularFactor = f2
  havokRigidBody = havok.rigidBody("AutoPlayer")
  return me
end

on step me, timeStep
  havokRigidBody.applyImpulse(-havokRigidBody.linearVelocity * linearFactor)
  havokRigidBody.applyAngularImpulse(-havokRigidBody.angularVelocity * angularFactor)
end
