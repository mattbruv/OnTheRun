-- Cast Lingo BehaviorScript CameraTrack1.ls

property cameraOffset, TargetOffset, cameraSteps, targetSteps, cameraUp, cameraRight, cameraLeft, dWarning, dDanger, dDangerUp, spriteNum, pSprite, world, pcamera, pTarget, pSky, oldTargetPos, oldSourcePos, pStatus, dangerTimer, pAnimCamera, pAnimFrom, pTween
global G, havok, human, TV, animation

on beginSprite me
  TV = me
  pSprite = sprite(spriteNum)
  world = pSprite.member
  pcamera = world.camera("MainCamera")
  pAnimCamera = world.camera("LastCamera")
  pTarget = world.model("AutoPlayer")
  pSky = world.model("cielo")
  cameraOffset = vector(-9, 0, 4)
  TargetOffset = vector(0, 0, 2)
  cameraSteps = 3
  targetSteps = 6
  cameraUp = G.up
  cameraRight = G.right
  cameraLeft = -G.right
  pcamera.colorBuffer.clearAtRender = 0
  pcamera.hither = 1
  pcamera.yon = 1000
  pSprite.camera = pcamera
  oldSourcePos = human.pHavok.position + vector(0, 0, 10)
  oldTargetPos = human.pHavok.position
  pcamera.transform.position = oldSourcePos
  pStatus = #relaxed
  dWarning = 4
  dDanger = 1.19999999999999996
  dDangerUp = 0.80000000000000004
end

on enterFrame me
  t = transform()
  t.rotation = pTarget.transform.rotation
  newSourcePos = pTarget.worldPosition + t * cameraOffset
  NewPos = oldSourcePos + (newSourcePos - oldSourcePos) / cameraSteps
  NewPos.z = pTarget.worldPosition.z + cameraOffset.z
  case pStatus of
    #nothing:
      return 
    #prepareToAnimation:
      if pTween.TweenUpdate() then
        pcamera.transform = pAnimFrom.interpolate(pAnimCamera.transform, pTween.TweenGet())
        sound(human.sndChEngine).volume = max(1, (100 - pTween.TweenPercentage()) * 254)
      else
        animation.nextStep(animation.step + 1)
        pStatus = #nothing
      end if
      return 
    #relaxed:
      Dir = NewPos - oldSourcePos
      dist = oldSourcePos.distanceTo(NewPos)
      ray = world.modelsUnderRay(oldSourcePos, Dir, 1, #detailed)
      if ray.count = 1 then
        if ray[1].distance < dist + dWarning then
          pStatus = #danger
          if ray[1].distance < dist + dDanger then
            NewPos = oldSourcePos
          end if
        end if
      end if
      pcamera.transform.position = NewPos
    #danger, #warning:
      delta = NewPos - oldSourcePos
      dir1 = vector(delta.x, 0, 0)
      dir2 = vector(0, delta.y, 0)
      dir3 = vector(0, 0, delta.z)
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
        if dist < dDangerUp + dir3.magnitude then
          dir3.normalize()
          dir3 = dir3 * (dist - dDangerUp)
          pStatus = #danger
        end if
      end if
      if pStatus = #danger then
        NewPos = oldSourcePos + dir1 + dir2 + dir3
        pcamera.transform.position = NewPos
        dangerTimer = havok.simTime
        if NewPos.distanceTo(pTarget.worldPosition) > 15 then
          oldSourcePos = pTarget.worldPosition + t * (cameraOffset / 4)
          oldTargetPos = pTarget.worldPosition
          pcamera.transform.position = oldSourcePos
        end if
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

on theEnd me
  pStatus = #prepareToAnimation
  pAnimFrom = pcamera.transform.duplicate()
  pTween = new(script("Tween"))
  pTween.TweenStart(0, 100, 3000)
end
