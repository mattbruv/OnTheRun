-- Cast Lingo BehaviorScript ThirdCameraTrack.ls

property spriteNum, pSprite, world, pcamera, pTarget

on beginSprite me
  pSprite = sprite(spriteNum)
  world = pSprite.member
  pcamera = world.camera("ThirdCamera")
  if voidp(pcamera) then
    pcamera = world.newCamera("ThirdCamera")
  end if
  pTarget = world.model("JeepCPU02")
  pcamera.colorBuffer.clearAtRender = 1
  pcamera.hither = 1
  pcamera.yon = 55000
  pcamera.projection = #ortographic
  pcamera.orthoHeight = 25
  pSprite.camera = pcamera
  pcamera.transform.position = vector(pTarget.worldPosition.x, pTarget.worldPosition.y, 10)
  pcamera.pointAt(pTarget.worldPosition + vector(0, 0.10000000000000001, 0))
end

on enterFrame me
  pcamera.transform.position = vector(pTarget.worldPosition.x, pTarget.worldPosition.y, pTarget.worldPosition.z + 10)
end
