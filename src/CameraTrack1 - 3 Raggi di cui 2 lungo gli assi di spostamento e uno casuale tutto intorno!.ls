-- Cast Lingo BehaviorScript CameraTrack1 - 3 Raggi di cui 2 lungo gli assi di spostamento e uno casuale tutto intorno!.ls

property cameraOffset, TargetOffset, cameraSteps, targetSteps, cameraUp, cameraRight, cameraLeft, dWarning, dDanger, spriteNum, pSprite, world, pcamera, pTarget, pSky, oldTargetPos, oldSourcePos, pStatus, dangerTimer, phaseVector, phase, currentOffset, offsetStep
global G, havok, TV

on beginSprite me
  TV = me
  pSprite = sprite(spriteNum)
  world = pSprite.member
  pcamera = world.camera("MainCamera")
  pTarget = world.model("AutoPlayer")
  pSky = world.model("cielo")
  cameraOffset = vector(-9, 0, 4)
  currentOffset = 1.0
  offsetStep = 0.10000000000000001
  TargetOffset = vector(0, 0, 2)
  cameraSteps = 6
  targetSteps = 6
  cameraUp = G.up
  cameraRight = G.right
  cameraLeft = -G.right
  pcamera.colorBuffer.clearAtRender = 1
  pcamera.hither = 1
  pcamera.yon = 1000
  pSprite.camera = pcamera
  pcamera.transform.position = vector(-14, -1000, 4)
  oldSourcePos = pcamera.worldPosition
  oldTargetPos = pTarget.worldPosition
  pStatus = #relaxed
  dWarning = 4
  dDanger = 1
  phaseVector = [vector(1, 0, 0), vector(0, 1, 0), vector(0, 0, 1), vector(-1, 0, 0), vector(0, -1, 0), vector(0, 0, -1)]
  phase = 0
end

on enterFrame me
  t = transform()
  t.rotation = pTarget.transform.rotation
  newSourcePos = pTarget.worldPosition + t * (currentOffset * cameraOffset)
  NewPos = oldSourcePos + (newSourcePos - oldSourcePos) / cameraSteps
  NewPos.z = pTarget.worldPosition.z + currentOffset * cameraOffset.z
  case pStatus of
    #relaxed:
      Dir = NewPos - oldSourcePos
      dist = oldSourcePos.distanceTo(NewPos)
      ray = world.modelsUnderRay(oldSourcePos, Dir, 1, #detailed)
      if ray.count = 1 then
        if ray[1].distance < dist + dWarning then
          put "Warning:" && ray[1].model && "at" && ray[1].distance
          pStatus = #danger
          NewPos = oldSourcePos
        end if
      end if
      pcamera.transform.position = NewPos
    #danger, #warning:
      delta = NewPos - oldSourcePos
      if delta.x < delta.y then
        if delta.z < delta.x then
          dir1 = vector(delta.x, 0, 0)
          dir2 = vector(0, delta.y, 0)
          delta.z = 0
        else
          delta.x = 0
          dir1 = vector(0, delta.y, 0)
          dir2 = vector(0, 0, delta.z)
        end if
      else
        if delta.z < delta.y then
          dir1 = vector(delta.x, 0, 0)
          dir2 = vector(0, delta.y, 0)
          delta.z = 0
        else
          dir1 = vector(delta.x, 0, 0)
          delta.y = 0
          dir2 = vector(0, 0, delta.z)
        end if
      end if
      dir3 = phaseVector[phase + 1]
      phase = (phase + 1) mod 6
      if dir3 = dir1 then
        dir3 = phaseVector[phase + 1]
        phase = (phase + 1) mod 6
        if dir3 = dir2 then
          dir3 = phaseVector[phase + 1]
          phase = (phase + 1) mod 6
        end if
      else
        if dir3 = dir2 then
          dir3 = phaseVector[phase + 1]
          phase = (phase + 1) mod 6
          if dir3 = dir1 then
            dir3 = phaseVector[phase + 1]
            phase = (phase + 1) mod 6
          end if
        end if
      end if
      pStatus = #warning
      ray = world.modelsUnderRay(oldSourcePos, dir1, 1, #detailed)
      if ray.count = 1 then
        dist = ray[1].distance
        if dist < dDanger + dir1.magnitude then
          dir1.normalize()
          dir1 = dir1 * (dist - dDanger)
          pStatus = #danger
        end if
      end if
      ray = world.modelsUnderRay(oldSourcePos, dir2, 1, #detailed)
      if ray.count = 1 then
        dist = ray[1].distance
        if dist < dDanger + dir2.magnitude then
          dir2.normalize()
          dir2 = dir2 * (dist - dDanger)
          pStatus = #danger
        end if
      end if
      ray = world.modelsUnderRay(oldSourcePos, dir3, 1, #detailed)
      if ray.count = 1 then
        dist = ray[1].distance
        if dist < dDanger then
          dir3 = dir3.getNormalized() * (dist - dDanger)
          pStatus = #danger
        else
          dir3 = vector(0, 0, 0)
        end if
      else
        dir3 = vector(0, 0, 0)
      end if
      if pStatus = #danger then
        NewPos = oldSourcePos + dir1 + dir2 + dir3
        pcamera.transform.position = NewPos
        dangerTimer = havok.simTime
      else
        pcamera.transform.position = oldSourcePos + delta
        if havok.simTime - dangerTimer > 1 then
          pStatus = #relaxed
        end if
      end if
  end case
  newTargetPos = pTarget.worldPosition
  NewPos = oldTargetPos + (newTargetPos - oldTargetPos) / targetSteps
  pcamera.pointAt(NewPos + TargetOffset, cameraUp)
  NewPos.z = 0
  pSky.transform.position = NewPos
end

on exitFrame
  oldSourcePos = pcamera.worldPosition
  oldTargetPos = pTarget.worldPosition
end
