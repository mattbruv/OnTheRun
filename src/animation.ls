-- Cast Lingo BehaviorScript animation.ls

property spriteNum, step, tween, camion, sb1, sb2, sb3, sb4, tr
global world, human, animation, havok, G, TV, CPU1, CPU2, CPU3

on beginSprite me
  animation = me
  tween = new(script("Tween"))
  camion = havok.rigidBody("Camion")
  havok.rigidBody("?Ipercubo02")
  havok.disableCollision("?Ipercubo02", "AutoPlayer")
  sb1 = world.model("Sbarra01")
  sb2 = world.model("Sbarra02")
  sb3 = world.model("Sbarra03")
  sb4 = world.model("Sbarra04")
  tr = world.model("Treno")
  tr.transform.position = vector(60.92199999999999704, -1508.4919999999999618, 4.31099999999999994)
  tr.transform.rotation = vector(0, 0, 180)
  step = 0
  world.registerForEvent(#animationEnded, #endAnimation, me)
end

on nextStep me, newStep
  step = newStep
  case step of
    1:
      tween.TweenStart(90, 0, 4000)
    2:
      tween.TweenStart(0, 90, 4000)
      havok.deleteRigidBody("?Ipercubo01")
      world.model("?Ipercubo01").removeFromWorld()
      zoneChange(11)
      sprite(spriteNum).camera = world.camera("CameraPL1")
      G.Run = 0
      tr.transform.position = vector(946.7682999999999538, 358, 2.21700000000000008)
      tr.transform.rotation = vector(0, 0, 0)
    3:
      zoneChange(1)
      sprite(spriteNum).camera = world.camera("MainCamera")
      G.Run = 1
    4:
      sound(8).play([#member: member("SFXCamion")])
      p = camion.position
      tween.TweenStart(p.y + 12, p.y - 12, 4800)
    5:
    6:
      sb3 = world.model("Sbarra03")
      sb4 = world.model("Sbarra04")
      sb3.keyframePlayer.play("aMotionSbarreBonus-SbarraChiusura-Key", 0, 0, 1000, 0.20000000000000001)
      sb4.keyframePlayer.play("aMotionSbarreBonus-SbarraChiusura-Key", 0, 0, 1000, 0.20000000000000001)
    8:
      TV.theEnd()
    9:
      tween.TweenStart(358, -30, 10000)
      sound(8).play(member("Treno"))
      sound(8).volume = 254
    10:
      havok.enableAllCollisions("?Ipercubo02")
      if human.pmodel.worldPosition.x > 940 then
        human.pHavok.linearVelocity = vector(0, 0, 0)
      end if
      TV.theEnd()
    11:
      tween.TweenStart(tr.worldPosition.y, -30, 10000)
      sound(8).play(member("Treno"))
      sound(8).volume = 254
    12:
      B = new(script("BoomParticle"), human.pmodel.worldPosition)
      sound(8).play(member("Explode1"))
      sound(8).volume = 254
      go("Perso2")
    13:
      go("Perso3")
  end case
end

on exitFrame me
  case step of
    1:
      if tween.TweenUpdate() then
        R = tween.TweenGet()
        sb1.transform.rotation = vector(R, 0, 0)
        sb2.transform.rotation = vector(180 - R, 0, 0)
      else
        tr = world.model("Treno")
        tr.keyframePlayer.play("aMotionTreniMacchine-Treno01-Key", 0, 0, 1000, 0.10000000000000001)
        tr.keyframePlayer.autoBlend = 0
        sound(8).play(member("Treno"))
        sound(8).volume = 254
        me.nextStep(-1)
      end if
    2:
      if tween.TweenUpdate() then
        R = tween.TweenGet()
        sb1.transform.rotation = vector(R, 0, 0)
        sb2.transform.rotation = vector(180 - R, 0, 0)
      else
        me.nextStep(3)
      end if
    4:
      if tween.TweenUpdate() then
        p = camion.position
        p.y = tween.TweenGet()
        camion.position = p
      else
        me.nextStep(5)
      end if
    10:
      havok.step()
    9:
      if tween.TweenUpdate() then
        R = tween.TweenGet()
        tr.transform.position.y = R
      else
        go("Vinto")
      end if
    11:
      if tween.TweenUpdate() then
        R = tween.TweenGet()
        tr.transform.position.y = R
      else
        go("Perso")
      end if
  end case
end

on endAnimation me, eventName, whichMotion, whichTime
  case step of
    6:
      if world.model("Sbarra03").keyframePlayer.playList = [] and world.model("Sbarra04").keyframePlayer.playList = [] then
        me.nextStep(10)
      end if
  end case
end
