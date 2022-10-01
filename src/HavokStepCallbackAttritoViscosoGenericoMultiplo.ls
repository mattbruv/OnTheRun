-- Cast Lingo ParentScript HavokStepCallbackAttritoViscosoGenericoMultiplo.ls

property linearFactor, angularFactor
global havok

on new me, f1, f2
  linearFactor = f1
  angularFactor = f2
  return me
end

on step me, timeStep
  c = havok.rigidBody.count
  repeat with i = 1 to c
    rb = havok.rigidBody[i]
    if rb.active then
      rb.applyImpulse(-rb.linearVelocity * linearFactor)
      rb.applyAngularImpulse(-rb.angularVelocity * angularFactor)
    end if
  end repeat
end
