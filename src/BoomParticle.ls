-- Cast Lingo ParentScript BoomParticle.ls

property pBoom
global world

on new me, pos, myParent
  boom_texture = world.texture("BoomTexture")
  if voidp(boom_texture) then
    boom_texture = world.newTexture("BoomTexture", #fromCastMember, member("BoomTexture2"))
  end if
  particle_resource = world.modelResource("BoomParticle")
  if voidp(particle_resource) then
    particle_resource = world.newModelResource("BoomParticle", #particle)
  end if
  particle_resource.lifeTime = 5000
  particle_resource.colorRange.start = rgb(255, 255, 128)
  particle_resource.colorRange.end = rgb(255, 32, 32)
  particle_resource.tweenMode = #age
  particle_resource.sizeRange.start = 0
  particle_resource.sizeRange.end = 10
  particle_resource.blendRange.start = 50.0
  particle_resource.blendRange.end = 0.0
  particle_resource.texture = boom_texture
  particle_resource.emitter.numParticles = 0
  particle_resource.emitter.mode = #burst
  particle_resource.emitter.loop = 0
  particle_resource.emitter.direction = vector(0, 0, 1)
  particle_resource.emitter.angle = 60
  particle_resource.emitter.distribution = #linear
  particle_resource.emitter.minSpeed = 1
  particle_resource.emitter.maxSpeed = 4
  particle_resource.drag = 1.0
  particle_resource.gravity = vector(0, 0, -0.10000000000000001)
  particle_resource.wind = vector(0, 0, 0)
  pBoom = world.model("BoomModel")
  if voidp(pBoom) then
    pBoom = world.newModel("BoomModel", particle_resource)
  else
    pBoom.resource = particle_resource
  end if
  if not voidp(myParent) then
    pBoom.parent = myParent
  end if
  pBoom.transform.position = pos
  pBoom.resource.emitter.numParticles = 50
  pBoom.addToWorld()
  return me
end
