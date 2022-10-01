-- Cast Lingo BehaviorScript Aqua.ls

property offset, spriteNum, pSprite, world, pmodel, pAqua, particle_resource, currentBlend, active
global havok, human, aqua

on beginSprite me
  aqua = me
  pSprite = sprite(me.spriteNum)
  world = pSprite.member
  pmodel = world.model("AutoPlayer")
  particle_texture = world.texture("AquaTexture")
  if voidp(particle_texture) then
    particle_texture = world.newTexture("AquaTexture", #fromCastMember, member("AquaTexture"))
  end if
  particle_resource = world.modelResource("AquaParticle")
  if voidp(particle_resource) then
    particle_resource = world.newModelResource("AquaParticle", #particle)
  end if
  particle_resource.lifeTime = 1000
  particle_resource.colorRange.start = rgb(255, 255, 255)
  particle_resource.colorRange.end = rgb(128, 128, 255)
  particle_resource.tweenMode = #age
  particle_resource.sizeRange.start = 0
  particle_resource.sizeRange.end = 2
  particle_resource.blendRange.start = 100.0
  particle_resource.blendRange.end = 0.0
  particle_resource.texture = particle_texture
  particle_resource.emitter.numParticles = 0
  particle_resource.emitter.mode = #stream
  particle_resource.emitter.loop = 1
  particle_resource.emitter.direction = vector(0, 0, 1)
  particle_resource.emitter.angle = 45
  particle_resource.emitter.region = [vector(-1, -1, 0), vector(1, -1, 0), vector(1, 1, 0), vector(-1, 1, 0)]
  particle_resource.emitter.distribution = #linear
  particle_resource.emitter.minSpeed = 8
  particle_resource.emitter.maxSpeed = 16
  particle_resource.drag = 10.0
  particle_resource.gravity = vector(0, 0, 0)
  particle_resource.wind = vector(0, 0, 0)
  pAqua = world.model("Aqua")
  if voidp(pAqua) then
    pAqua = world.newModel("Aqua", particle_resource)
  else
    pAqua.resource = particle_resource
  end if
  pAqua.removeFromWorld()
  active = 0
  currentBlend = 0
end

on perform me, pos, vel
  currentBlend = min(100, currentBlend + 10)
  if not active then
    active = 1
    pAqua.addToWorld()
    particle_resource.emitter.numParticles = 50
    particle_resource.emitter.loop = 1
    sound(8).play(member("acqua3"))
    sound(8).volume = 5
  end if
  pAqua.transform.position = pos
  magni = vel.magnitude
  particle_resource.wind = -vector(vel.x, vel.y, 0) / 2
  particle_resource.emitter.minSpeed = magni / 20
  particle_resource.emitter.maxSpeed = magni / 6
end

on exitFrame me
  if active then
    currentBlend = currentBlend - 5
    if currentBlend <= 0 then
      active = 0
      particle_resource.emitter.numParticles = 0
      particle_resource.emitter.loop = 0
      pAqua.removeFromWorld()
      sound(8).stop()
    else
      particle_resource.blendRange.start = currentBlend
      sound(8).volume = min(254, currentBlend * particle_resource.emitter.minSpeed)
    end if
  end if
end
