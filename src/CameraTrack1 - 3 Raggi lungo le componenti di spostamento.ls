-- Cast Lingo BehaviorScript CameraTrack1 - 3 Raggi lungo le componenti di spostamento.ls

property cameraOffset, TargetOffset, cameraSteps, targetSteps, cameraUp, cameraRight, cameraLeft, dWarning, dDanger, spriteNum, pSprite, world, pcamera, pTarget, pSky, oldTargetPos, oldSourcePos, pStatus, currentOffset, offsetStep
global G, TV

on beginSprite me
  TV = me
  pSprite = sprite(spriteNum)
  world = pSprite.member
  pcamera = world.camera("MainCamera")
  pTarget = world.model("AutoPlayer")
  pSky = world.model("cielo")
  cameraOffset = vector(-9, 0, 4)
  currentOffset = cameraOffset
  offsetStep = 0.10000000000000001
  TargetOffset = vector(0, 0, 2)
  cameraSteps = 6
  targetSteps = 6
  cameraUp = G.up
  cameraRight = G.right
  cameraLeft = -G.right
  pcamera.colorBuffer.clearAtRender = 1
  pcamera.hither = 0
  pcamera.yon = 1000
  pSprite.camera = pcamera
  pcamera.transform.position = vector(-14, -1000, 4)
  oldSourcePos = pcamera.worldPosition
  oldTargetPos = pTarget.worldPosition
  pStatus = #relaxed
  dWarning = 4
  dDanger = 1
end

on enterFrame me
  t = transform()
  t.rotation = pTarget.transform.rotation
  newSourcePos = pTarget.worldPosition + t * currentOffset
  NewPos = oldSourcePos + (newSourcePos - oldSourcePos) / cameraSteps
  NewPos.z = pTarget.worldPosition.z + cameraOffset.z
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
    #danger:
      delta = NewPos - oldSourcePos
      dist = oldSourcePos.distanceTo(NewPos)
      if delta.x <> 0 then
        dirx = vector(sign(delta.x), 0, 0)
        ray = world.modelsUnderRay(oldSourcePos, dirx, 1, #detailed)
        if ray.count = 1 then
          distx = ray[1].distance
        else
          distx = 999
        end if
      else
        distx = 999
      end if
      if delta.y <> 0 then
        diry = vector(0, sign(delta.y), 0)
        ray = world.modelsUnderRay(NewPos, diry, 1, #detailed)
        if ray.count = 1 then
          disty = ray[1].distance
        else
          disty = 999
        end if
      else
        disty = 999
      end if
      if delta.z <> 0 then
        dirz = vector(0, 0, sign(delta.z))
        ray = world.modelsUnderRay(NewPos, dirz, 1, #detailed)
        if ray.count = 1 then
          distz = ray[1].distance
        else
          distz = 999
        end if
      else
        distz = 999
      end if
      pStatus = #relaxed
      if distx < dDanger then
        delta = delta - (dDanger - distx) * dirx
        pStatus = #danger
        put "X  "
      else
        if distx < dWarning then
          pStatus = #danger
        end if
      end if
      if disty < dDanger then
        delta = delta - (dDanger - disty) * diry
        pStatus = #danger
        put " Y "
      else
        if disty < dWarning then
          pStatus = #danger
        end if
      end if
      if distz < dDanger then
        delta = delta - (dDanger - distz) * dirz
        pStatus = #danger
        put "  Z"
      else
        if distz < dWarning then
          pStatus = #danger
        end if
      end if
      pcamera.transform.position = oldSourcePos + delta
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
  currentOffset.x = currentOffset.x + sign(cameraOffset.x - currentOffset.x) * offsetStep
  currentOffset.y = currentOffset.y + sign(cameraOffset.y - currentOffset.y) * offsetStep
  currentOffset.z = currentOffset.z + sign(cameraOffset.z - currentOffset.z) * offsetStep
end
