-- Cast Lingo BehaviorScript SecondCameraTrack.ls

property cameraOffset, TargetOffset, cameraSteps, targetSteps, cameraUp, spriteNum, pSprite, world, pcamera, pTarget, oldTargetPos, oldSourcePos

on beginSprite me
  pSprite = sprite(spriteNum)
  world = pSprite.member
  pcamera = world.camera("SecondCamera")
  if voidp(pcamera) then
    pcamera = world.newCamera("SecondCamera")
  end if
  pTarget = world.model("AutoPlayer")
  cameraOffset = vector(5, 0, 3)
  TargetOffset = vector(0, 0, 3)
  cameraSteps = 3
  targetSteps = 6
  cameraUp = vector(0, 0, 1)
  pcamera.colorBuffer.clearAtRender = 1
  pcamera.hither = 1
  pcamera.yon = 55000
  pSprite.camera = pcamera
  oldSourcePos = pcamera.worldPosition
  oldTargetPos = pTarget.worldPosition
end

on enterFrame me
  t = transform()
  t.rotation = pTarget.transform.rotation
  newSourcePos = t * cameraOffset + pTarget.transform.position
  NewPos = oldSourcePos + (newSourcePos - oldSourcePos) / cameraSteps
  NewPos.z = pTarget.worldPosition.z + cameraOffset.z
  pcamera.transform.position = NewPos
  newTargetPos = pTarget.transform.position
  NewPos = oldTargetPos + (newTargetPos - oldTargetPos) / targetSteps
  pcamera.pointAt(NewPos + TargetOffset, cameraUp)
end

on exitFrame me
  oldSourcePos = pcamera.worldPosition
  oldTargetPos = pTarget.worldPosition
end
