-- Cast Lingo BehaviorScript Aqua 4x4.ls

property offset, spriteNum, pSprite, world, pmodel, pAqua, particle_resource, active, currentBlend
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
  particle_resource.lifeTime = 2000
  particle_resource.colorRange.start = rgb(255, 255, 255)
  particle_resource.colorRange.end = rgb(0, 0, 255)
  particle_resource.tweenMode = #age
  particle_resource.sizeRange.start = 0
  particle_resource.sizeRange.end = 0.59999999999999998
  particle_resource.blendRange.start = 100.0
  particle_resource.blendRange.end = 0.0
  particle_resource.texture = VOID
  particle_resource.emitter.numParticles = 200
  particle_resource.emitter.mode = #stream
  particle_resource.emitter.loop = 1
  particle_resource.emitter.direction = vector(0, 0, 1)
  particle_resource.emitter.angle = 45
  particle_resource.emitter.distribution = #gaussian
  particle_resource.emitter.minSpeed = 8
  particle_resource.emitter.maxSpeed = 16
  particle_resource.drag = 10.0
  particle_resource.gravity = vector(0, 0, -0.10000000000000001)
  particle_resource.wind = vector(0, 0, 0)
  pAqua = []
  repeat with i = 1 to 4
    pAqua[i] = world.model("Aqua" & i)
    if voidp(pAqua[i]) then
      pAqua[i] = world.newModel("Aqua" & i, particle_resource)
      pAqua[i].parent = pmodel
      next repeat
    end if
    pAqua[i].resource = particle_resource
  end repeat
  pAqua[1].transform.position = vector(-1.39999999999999991, -0.80000000000000004, 0)
  pAqua[1].transform.rotation = vector(0, 0, 0)
  pAqua[2].transform.position = vector(1.39999999999999991, -0.80000000000000004, 0)
  pAqua[2].transform.rotation = vector(0, 0, 0)
  pAqua[3].transform.position = vector(-1.39999999999999991, 0.80000000000000004, 0)
  pAqua[3].transform.rotation = vector(0, 0, 0)
  pAqua[4].transform.position = vector(1.39999999999999991, 0.80000000000000004, 0)
  pAqua[4].transform.rotation = vector(0, 0, 0)
  active = 1
  me.stop()
end

on active me
end

on start me
end

on stop me
  particle()
end

on exitFrame me
  p = human.pmodel.worldPosition
  pAqua[1].transform.position = p + vector(-1.39999999999999991, -0.80000000000000004, 0)
  pAqua[2].transform.position = p + vector(1.39999999999999991, -0.80000000000000004, 0)
  pAqua[3].transform.position = p + vector(-1.39999999999999991, 0.80000000000000004, 0)
  pAqua[4].transform.position = p + vector(1.39999999999999991, 0.80000000000000004, 0)
  pAqua[4].transform.rotation = vector(0, 0, 0)
  v = human.pHavok.linearVelocity
  v.z = 0
  t = transform()
  t.rotation = pmodel.transform.rotation
  t.invert()
  particle_resource.wind = -(t * v) / 2
  particle_resource.emitter.minSpeed = v.magnitude / 10
  particle_resource.emitter.maxSpeed = v.magnitude
end
