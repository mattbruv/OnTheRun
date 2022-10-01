-- Cast Lingo MovieScript 3D.ls

global havok, world

on havokList name
  if stringp(name) then
    hk = member(name)
  else
    if objectp(name) then
      hk = name
    else
      hk = havok
    end if
  end if
  if not objectp(hk) then
    put "Sorry, no havok object."
  else
    put "Havok rigidBody: " & hk.rigidBody.count
    repeat with i = 1 to hk.rigidBody.count
      if hk.rigidBody[i].active then
        stat = "[active]"
      else
        stat = "[disabled]"
      end if
      put hk.rigidBody[i].name && stat && "Mass:" && hk.rigidBody[i].mass && "Restitution:" && hk.rigidBody[i].restitution && "Friction:" && hk.rigidBody[i].friction
    end repeat
  end if
end

on havokStatus name
  if stringp(name) then
    hk = member(name)
  else
    if objectp(name) then
      hk = name
    else
      hk = havok
    end if
  end if
  if not objectp(hk) then
    put "Sorry, no havok object."
  else
    put "havok.initialized =" && hk.initialized
    put "havok.tolerance =" && hk.tolerance
    put "havok.scale =" && hk.scale
    put "havok.timeStep =" && hk.timeStep
    put "havok.subStep =" && hk.subSteps
    put "havok.simTime =" && hk.simTime
    put "havok.gravity =" && hk.gravity
    put "havok.rigidBody (count) =" && hk.rigidBody.count
    put "havok.spring (count) =" && hk.spring.count
    put "havok.linearDashpot (count) =" && hk.linearDashpot.count
    put "havok.angularDashpot (count) =" && hk.angularDashpot.count
    put "havok.deactivationParameters (Hz) [short, long] =" && hk.deactivationParameters
    put "havok.dragParameters [linear, angular] =" && hk.dragParameters
  end if
end

on modelList Filter
  repeat with i = 1 to world.model.count
    if voidp(Filter) then
      put world.model[i].name
      next repeat
    end if
    if world.model[i].name contains Filter then
      put world.model[i].name
    end if
  end repeat
end

on motionList name
  if stringp(name) then
    wd = member(name)
  else
    if objectp(name) then
      wd = name
    else
      wd = world
    end if
  end if
  repeat with i = 1 to wd.motion.count
    put wd.motion[i].name
  end repeat
end

on cameraList name
  if stringp(name) then
    wd = member(name)
  else
    if objectp(name) then
      wd = name
    else
      wd = world
    end if
  end if
  repeat with i = 1 to wd.camera.count
    put string(wd.camera[i]) && ":" && wd.model[i].name
  end repeat
end
