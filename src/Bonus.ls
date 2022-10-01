-- Cast Lingo BehaviorScript Bonus.ls

property bonusTot, spriteNum, pSprite, world, pmodel, pParticle, pBonus, bonus_resource1, bonus_resource2, bonus_shader, particle_texture, particle_resource
global G, bonus, human

on beginSprite me
  bonus = me
  pSprite = sprite(me.spriteNum)
  world = pSprite.member
  bonusTot = G.bonusList.count
  pBonus = []
  G.bonusType1 = 0
  G.bonusType2 = 0
  repeat with i = 1 to bonusTot
    pBonus[i] = world.model("Bonus" & i)
    if voidp(pBonus[i]) then
      if G.bonusList[i].type = #benz then
        pBonus[i] = world.model("BonusBenz+").clone("Bonus" & i)
        G.bonusType1 = G.bonusType1 + 1
      else
        pBonus[i] = world.model("BonusMecc+").clone("Bonus" & i)
        G.bonusType2 = G.bonusType2 + 1
      end if
      pBonus[i].addModifier(#collision)
      pBonus[i].collision.immovable = 1
      pBonus[i].collision.resolve = 0
      pBonus[i].collision.enabled = 1
      pBonus[i].collision.mode = #sphere
      pBonus[i].addModifier(#keyframePlayer)
    end if
    pBonus[i].addToWorld()
    pBonus[i].transform.position = G.bonusList[i].pos + vector(0, 0, 1.5)
    pBonus[i].transform.rotation = vector(0, 0, 0)
    pBonus[i].keyframePlayer.play("aMotionSbarreBonus-BonusRotazione-Key", 1, 0, 1000, 0.29999999999999999)
  end repeat
  particle_texture = world.texture("TextureParticle")
  if voidp(particle_texture) then
    particle_texture = world.newTexture("TextureParticle", #fromCastMember, member("AquaTexture"))
  end if
  particle_resource = world.modelResource("BonusParticle")
  if voidp(particle_resource) then
    particle_resource = world.newModelResource("BonusParticle", #particle)
  end if
  particle_resource.lifeTime = 2000
  particle_resource.colorRange.start = rgb(255, 255, 128)
  particle_resource.colorRange.end = rgb(128, 128, 32)
  particle_resource.tweenMode = #age
  particle_resource.sizeRange.start = 1.5
  particle_resource.sizeRange.end = 0.5
  particle_resource.blendRange.start = 100.0
  particle_resource.blendRange.end = 0.0
  particle_resource.texture = particle_texture
  particle_resource.emitter.numParticles = 0
  particle_resource.emitter.mode = #burst
  particle_resource.emitter.loop = 0
  particle_resource.emitter.distribution = #gaussian
  particle_resource.emitter.minSpeed = 1
  particle_resource.emitter.maxSpeed = 3
  particle_resource.drag = 2.0
  particle_resource.gravity = vector(0, 0, 0)
  particle_resource.wind = vector(0, 0, 0)
  pParticle = world.model("BonusBoom")
  if voidp(pParticle) then
    pParticle = world.newModel("BonusBoom", particle_resource)
  else
    pParticle.resource = particle_resource
  end if
  world.registerForEvent(#collideAny, #bonusBoom, me)
end

on keyUp me
  if G.editBonus then
    if the key = "1" then
      G.bonusList.append([#type: #benz, #pos: world.model("AutoPlayer").worldPosition])
      i = bonusTot + 1
      pBonus[i] = world.model("BonusBenz+").clone("Bonus" & i)
      pBonus[i].addModifier(#collision)
      pBonus[i].collision.immovable = 1
      pBonus[i].collision.resolve = 0
      pBonus[i].collision.enabled = 1
      pBonus[i].addToWorld()
      pBonus[i].transform.position = G.bonusList[i].pos
      pBonus[i].transform.rotation = vector(45, 45, 45)
      pBonus[i].addModifier(#keyframePlayer)
      pBonus[i].keyframePlayer.play("aMotionSbarreBonus-BonusRotazione-Key", 1, 0, 1000, 0.29999999999999999)
      bonusTot = bonusTot + 1
      sound(8).play(member("CUCKOO"))
    end if
    if the key = "2" then
      G.bonusList.append([#type: #mecc, #pos: world.model("AutoPlayer").worldPosition])
      i = bonusTot + 1
      pBonus[i] = world.model("BonusMecc+").clone("Bonus" & i)
      pBonus[i].addModifier(#collision)
      pBonus[i].collision.immovable = 1
      pBonus[i].collision.resolve = 0
      pBonus[i].collision.enabled = 1
      pBonus[i].addToWorld()
      pBonus[i].transform.position = G.bonusList[i].pos
      pBonus[i].transform.rotation = vector(45, 45, 45)
      pBonus[i].addModifier(#keyframePlayer)
      pBonus[i].keyframePlayer.play("aMotionSbarreBonus-BonusRotazione-Key", 1, 0, 1000, 0.29999999999999999)
      bonusTot = bonusTot + 1
      sound(8).play(member("CUCKOO"))
    end if
    if the key = "0" and G.editCurrent <> 0 then
      pParticle.resource.emitter.numParticles = 1000
      pParticle.resource.emitter.loop = 0
      pParticle.resource.emitter.mode = #burst
      pParticle.transform.position = pBonus[G.editCurrent].worldPosition
      pBonus[G.editCurrent].removeFromWorld()
      G.bonusList[G.editCurrent] = VOID
      G.editCurrent = 0
      sound(8).play(member("CRUSH"))
    end if
    if the key = "s" then
      gUpdate(#bonusList, G.bonusList)
      sound(8).play(member("OK"))
    end if
  end if
end

on bonusBoom me, collisionData
  if G.editBonus then
    bonus = collisionData.modelB
    n = value(chars(bonus.name, 6, 12))
    if G.editCurrent <> n then
      G.editCurrent = n
      pParticle.resource.emitter.numParticles = 100
      pParticle.resource.emitter.loop = 1
      pParticle.resource.emitter.mode = #stream
      pParticle.transform.position = bonus.worldPosition
      sound(8).play(member("POP"))
    end if
  else
    bonus = collisionData.modelB
    bonus.removeFromWorld()
    pParticle.resource.emitter.numParticles = 100
    pParticle.transform.position = bonus.worldPosition
    n = value(chars(bonus.name, 6, 12))
    case G.bonusList[n].type of
      #benz:
        G.benza = min(G.benza + G.bonusBenz, G.benzaMax)
        G.totBenz = G.totBenz + 1
        sound(8).play(member("Benz"))
        sound(8).volume = 254
      #mecc:
        G.carrozzeria = min(G.carrozzeria + G.bonusMecc, G.carrozzeriaMax)
        G.totMecc = G.totMecc + 1
        sound(8).play(member("Mecc"))
        sound(8).volume = 254
        newVal = min(integer(G.carrozzeria / 25), 3)
        if human.pCarrozzeria <> newVal then
          human.pCarrozzeria = newVal
          human.pShader.texture = human.pTexture[human.pCarrozzeria + 1]
        end if
    end case
  end if
end
