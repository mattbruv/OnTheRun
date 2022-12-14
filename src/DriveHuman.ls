-- Cast Lingo BehaviorScript DriveHuman.ls

property gForward, gUp, gDown, pMaxSpeed, pMaxRetroSpeed, pminspeed, pMaxTurnSpeed, pAccGain, pDecGain, pBrakeGain, pTurnGain, pReTurnGain, pSobbalzo, pGrip, pDrag, pMaxHeight, pRadarHeight, pCorrectorActivation, pAntiRevolutionSystem, pTrackSpeed, pGroundSpeed, pGrassSpeed, pTrackGrip, pGroundGrip, pGrassGrip, spriteNum, pSprite, world, pmodel, pShadow, pHavok, pShader, pShaderStop, pTexture, pTextureStop, pGoingForward, pGoingBackward, pGoingLeft, pGoingRight, pBraking, pheight, pObjectUnder, pOldGround, pGround, pContact, pNormal, pCurrentSpeed, pSlideSpeed, pFallSpeed, pUpsideDown, pCorrector, pSgommata, pBrakesLightOn, pCarrozzeria, pDanniRibaltamentoOk, sndChEngine, sndChEffects, sndChCollision, sndList, sndOverlap, sndSlidingSpeed, sndBrakesSpeed, sndGearSpeed, sndStatus, sndPercentage, sndBrakes, sndEngineWait, sndCollisionWait
global G, havok, trail, human, aqua, animation

on beginSprite me
  human = me
  pSprite = sprite(me.spriteNum)
  world = pSprite.member
  gForward = G.forward
  gUp = G.up
  gDown = -G.up
  pmodel = world.model("AutoPlayer")
  pHavok = havok.rigidBody(pmodel.name)
  pShader = world.shader("AutoPlayer$")
  pTexture = []
  pTexture[1] = world.texture("AutoPlayerMap1")
  pTexture[2] = world.texture("AutoPlayerMap2")
  pTexture[3] = world.texture("AutoPlayerMap3")
  pTexture[4] = world.texture("AutoPlayerMap4")
  pShaderStop = world.shader("AutoPlayerStop")
  pTextureStop = []
  pTextureStop[1] = world.texture("AutoPlayerStopMap0")
  pTextureStop[2] = world.texture("AutoPlayerStopMap1")
  human.pShader.blend = 100
  human.pShaderStop.blend = 100
  pmodel.addModifier(#collision)
  pmodel.collision.immovable = 0
  pmodel.collision.resolve = 0
  pmodel.collision.enabled = 1
  pmodel.collision.mode = #sphere
  pCarrozzeria = 3
  pBrakesLightOn = 0
  pShader.texture = pTexture[pCarrozzeria + 1]
  pShaderStop.texture = pTextureStop[pBrakesLightOn + 1]
  pDanniRibaltamentoOk = 0
  pShadow = new(script("shadow"), pmodel, "ombra", gUp, G.shadowHeight)
  pMaxSpeed = 248.0
  pMaxRetroSpeed = pMaxSpeed * 2 / 3
  pminspeed = 2
  pMaxTurnSpeed = 3.0
  pAccGain = 0.02
  pDecGain = 0.02
  pBrakeGain = 0.10000000000000001
  pTurnGain = 0.40000000000000002
  pSobbalzo = 20
  pAntiRevolutionSystem = 0.20000000000000001
  pGrip = 0.29999999999999999
  pDrag = 0.02
  pMaxHeight = 1.0
  pRadarHeight = vector(0, 0, 2)
  pCorrectorActivation = 1
  pReTurnGain = pTurnGain
  pTrackSpeed = pMaxSpeed
  pGroundSpeed = pMaxSpeed
  pGrassSpeed = pMaxSpeed * 2 / 3
  pTrackGrip = pGrip
  pGroundGrip = pGrip
  pGrassGrip = pGrip
  pGoingForward = 0
  pGoingBackward = 0
  pGoingLeft = 0
  pGoingRight = 0
  pBraking = 0
  sndChEngine = 1
  sndChEffects = 2
  sndChCollision = 3
  sound(sndChEngine).volume = 1
  sndList = [:]
  sndList[#prima] = [#member: member("1")]
  sndList[#seconda] = [#member: member("2")]
  sndList[#terza] = [#member: member("3")]
  sndList[#quarta] = [#member: member("4")]
  sndList[#quinta] = [#member: member("5")]
  sndList[#sgommata] = [#member: member("sgommata")]
  sndList[#fuorigiri] = [#member: member("fuorigiri")]
  sndList[#minimo] = [#member: member("minimo")]
  sndList[#ridotta] = [#member: member("ridotta")]
  sndList[#medio] = [#member: member("medio")]
  sndList[#manetta] = [#member: member("manetta")]
  sndList[#scalatina] = [#member: member("AsfaltoToErba")]
  sndList[#scalata] = [#member: member("scalata")]
  sndList[#retro] = [#member: member("retro+loop"), #loopStartTime: 2724, #loopCount: 0]
  sndList[#frenata] = [#member: member("freno")]
  sndList[#slittamento] = [#member: member("screech")]
  sndList[#crash1] = [#member: member("crash3")]
  sndList[#crash2] = [#member: member("crash")]
  sndList[#impatto1] = [#member: member("crash1")]
  sndList[#impatto2] = [#member: member("impatto")]
  sndList[#impatto3] = [#member: member("crash4")]
  sndList[#impattosuolo] = [#member: member("impatto")]
  sndList[#ribaltamento] = [#member: member("ribaltamento")]
  sndOverlap = 150
  sndSlidingSpeed = 5
  sndBrakesSpeed = 25
  realMaxSpeed = pMaxSpeed / 3
  sndGearSpeed = [:]
  sndGearSpeed.sort()
  sndGearSpeed.setaProp(0, #retro)
  sndGearSpeed.setaProp(integer(realMaxSpeed / 5), #prima)
  sndGearSpeed.setaProp(integer(realMaxSpeed / 3), #seconda)
  sndGearSpeed.setaProp(integer(realMaxSpeed / 2), #terza)
  sndGearSpeed.setaProp(integer(realMaxSpeed * 2 / 3), #quarta)
  sndGearSpeed.setaProp(pMaxSpeed * 10, #quinta)
  me.sndNextStatus(#minimo)
  sndBrakes = 0
  sndEngineWait = 0
  havok.registerInterest(pmodel.name, #all, 0, 1, #havok_callback, me)
end

on prepareFrame me
  me.probeGround()
  if not voidp(pContact) then
    pShadow.updateShadow(pContact, pNormal)
  end if
end

on exitFrame me
  me.getKeys()
  if G.Run then
    if pCorrector > 0 then
      if havok.simTime > pCorrector then
        pHavok.corrector.enabled = 0
        pCorrector = 0
      end if
    else
      me.driveController()
      me.soundController()
    end if
  end if
end

on probeGround me
  pOldGround = pGround
  ground = world.modelsUnderRay(pmodel.worldPosition, gDown, 3, #detailed)
  repeat with i = 1 to ground.count()
    pObjectUnder = ground[i].model.name
    if not (pObjectUnder contains pmodel.name) and not (pObjectUnder contains "Target") then
      pContact = ground[i].isectPosition
      pNormal = ground[i].isectNormal
      pheight = ground[i].distance
      if pObjectUnder contains "strada" then
        pGround = #track
      else
        if pObjectUnder contains "marciapiede" then
          pGround = #ground
        else
          if pObjectUnder contains "acqua" then
            if pheight < pMaxHeight then
              aqua.perform(pmodel.worldPosition, pHavok.linearVelocity)
            end if
            pGround = #track
          else
            if pObjectUnder contains "acqua" then
              pGround = #grass
            else
              case animation.step of
                0:
                  if pObjectUnder contains "WPassaggioLivello01" then
                    animation.nextStep(1)
                  end if
                -1:
                  if pObjectUnder contains "WTunnel" and pheight < pMaxHeight then
                    me.sndNextStatus(#minimo)
                    animation.nextStep(2)
                  end if
                3:
                  if pObjectUnder contains "WCamion" then
                    animation.nextStep(4)
                  end if
                5:
                  if pObjectUnder contains "WPassaggioLivello02" then
                    animation.nextStep(6)
                  end if
                6:
                  if pObjectUnder contains "GraficaBinari01" then
                    animation.nextStep(8)
                  end if
              end case
              pGround = #track
            end if
          end if
        end if
      end if
      case pGround of
        #track:
          pGrip = pTrackGrip
          pMaxSpeed = pTrackSpeed
        #ground:
          pGrip = pGroundGrip
          pMaxSpeed = pGroundSpeed
        #grass:
          pGrip = pGrassGrip
          pMaxSpeed = pGrassSpeed
      end case
      return 
    end if
  end repeat
  pGrip = 0
  pContact = VOID
  pObjectUnder = EMPTY
  pheight = 9999
end

on getKeys me
  if animation.step < 7 then
    pGoingForward = keyPressed(126) or the controlDown
    pGoingBackward = keyPressed(125) or the optionDown
    pGoingRight = keyPressed(124)
    pGoingLeft = keyPressed(123)
    pBraking = keyPressed(" ")
    if pGoingRight and pGoingLeft then
      pGoingRight = 0
      pGoingLeft = 0
    end if
    if pBraking or pGoingForward and pGoingBackward then
      pGoingForward = 0
      pGoingBackward = 0
    end if
    if pGoingForward + pGoingBackward then
      if G.benza > 0 then
        G.benza = G.benza - 1
      else
        pGoingForward = 0
        pGoingBackward = 0
        sound(sndChEngine).play(member("gatewhine"))
        sound(sndChEffects).stop()
        sound(sndChCollision).stop()
        animation.nextStep(13)
      end if
    end if
    if pBraking <> pBrakesLightOn then
      pBrakesLightOn = pBraking
      pShaderStop.texture = pTextureStop[pBrakesLightOn + 1]
    end if
  else
    pGoingForward = animation.step = 8
    pGoingBackward = 0
    pGoingRight = 0
    pGoingLeft = 0
    pBraking = animation.step <> 8
  end if
end

on driveController me
  trans = pmodel.transform.duplicate()
  trans.position = vector(0, 0, 0)
  trans.scale = vector(1, 1, 1)
  currentFwd = trans * gForward
  currentAxis = trans * gUp
  currentRight = currentFwd.cross(currentAxis)
  if pGround = #track then
    trail.dropMark(pmodel.worldPosition, currentFwd)
  end if
  currentVel = pHavok.linearVelocity
  pCurrentSpeed = currentVel.dot(currentFwd)
  pSlideSpeed = currentVel.dot(currentRight)
  pFallSpeed = currentVel.dot(currentAxis)
  propSpeed = min(abs(pCurrentSpeed) / pMaxSpeed, 1)
  angularVel = pHavok.angularVelocity
  mass = pHavok.mass
  imp = angularVel.dot(currentFwd) * (-pAntiRevolutionSystem * mass)
  pHavok.applyAngularImpulse(currentFwd * imp)
  imp = angularVel.dot(currentRight) * (-pAntiRevolutionSystem * mass)
  if imp < 0 then
    pHavok.applyAngularImpulse(currentRight * imp)
  end if
  if pGround <> pOldGround then
    if pCurrentSpeed > 10 and not soundBusy(8) then
      if pOldGround = #track then
        sound(8).play(member("impactMarc"))
        sound(8).volume = 254
      else
        sound(8).play(member("impactMarcDiscesa"))
        sound(8).volume = 254
      end if
    end if
    imp = pSobbalzo * mass * currentAxis * propSpeed
    pHavok.applyImpulse(imp)
  end if
  if pheight < pMaxHeight then
    if pGoingBackward and pCurrentSpeed > 20 then
      pSgommata = 1
      turnGain = 25 * pTurnGain
    else
      pSgommata = 0
      turnGain = pTurnGain
    end if
    if pGoingForward then
      diff = pMaxSpeed - pCurrentSpeed
      imp = diff * pAccGain * mass * pGrip * currentFwd
      pHavok.applyImpulse(imp)
    end if
    if pGoingBackward then
      if not pSgommata then
        diff = -pMaxRetroSpeed - pCurrentSpeed
        imp = diff * pDecGain * mass * pGrip * currentFwd
        pHavok.applyImpulse(imp)
      end if
    end if
    if pBraking then
      imp = -pCurrentSpeed * pBrakeGain * mass * currentFwd
      pHavok.applyImpulse(imp)
    end if
    mTS = min(abs(pCurrentSpeed), (1.0 - propSpeed) * pMaxTurnSpeed)
    canTurn = abs(angularVel.dot(currentAxis)) < mTS
    if canTurn then
      if pGoingLeft then
        imp = currentAxis * (turnGain * mass)
        if pGoingBackward then
          imp = -imp
        end if
        pHavok.applyAngularImpulse(imp)
      end if
      if pGoingRight then
        imp = currentAxis * (-turnGain * mass)
        if pGoingBackward then
          imp = -imp
        end if
        pHavok.applyAngularImpulse(imp)
      end if
    end if
    if not pBraking and not pSgommata then
      imp = currentRight * (-pSlideSpeed * mass * pGrip)
      pHavok.applyImpulse(imp)
    end if
    if canTurn = 0 or pGoingLeft = 0 and pGoingRight = 0 then
      imp = currentAxis * angularVel.dot(currentAxis) * (-pReTurnGain * mass)
      pHavok.applyAngularImpulse(imp)
    end if
    if currentVel.magnitude > pminspeed then
      imp = -currentVel * (pDrag * mass)
      pHavok.applyImpulse(imp)
    end if
  end if
  if currentAxis.dot(gUp) > 0.5 then
    pUpsideDown = VOID
    pDanniRibaltamentoOk = 0
  else
    if voidp(pUpsideDown) then
      pUpsideDown = havok.simTime
    end if
    if havok.simTime - pUpsideDown > pCorrectorActivation then
      me.correctorMatrix()
      pUpsideDown = havok.simTime
    end if
  end if
end

on sndNextStatus me, newstatus, percentage
  sndStatus = newstatus
  if voidp(percentage) then
    sound(sndChEngine).play(sndList[sndStatus])
  else
    snd = duplicate(sndList[sndStatus])
    snd[#startTime] = sndList[sndStatus].member.duration * (1 - percentage)
    sound(sndChEngine).play(snd)
  end if
  sndEngineWait = 2
end

on soundController me
  if sndCollisionWait > 0 then
    sndCollisionWait = sndCollisionWait - 1
  end if
  if sndEngineWait > 0 then
    sndEngineWait = sndEngineWait - 1
    return 
  end if
  runnig = 0
  if sndCollisionWait = 0 then
    if pGoingForward then
      running = 1
    else
      if pGoingBackward then
        running = -1
      end if
    end if
  end if
  sndPercentage = sound(sndChEngine).elapsedTime / sndList[sndStatus].member.duration
  nearly_finished = sound(sndChEngine).endTime - sound(sndChEngine).elapsedTime < sndOverlap
  if pheight >= pMaxHeight then
    case sndStatus of
      #minimo:
        if running then
          me.sndNextStatus(#sgommata)
        end if
      #fuorigiri:
        if not running then
          me.sndNextStatus(#scalata)
        end if
      #sgommata:
        if running then
          if nearly_finished then
            me.sndNextStatus(#fuorigiri)
          end if
        else
          me.sndNextStatus(#scalata, sndPercentage)
        end if
      #scalata:
        if not running then
          if nearly_finished then
            me.sndNextStatus(#minimo)
          end if
        else
          me.sndNextStatus(#sgommata)
        end if
      otherwise:
        if running then
          me.sndNextStatus(#sgommata)
        else
          me.sndNextStatus(#scalata)
        end if
    end case
    if soundBusy(sndChEffects) then
      sound(sndChEffects).stop()
    end if
  else
    case sndStatus of
      #retro:
        if running = 1 then
          me.sndNextStatus(#prima)
        else
          if running = 0 then
            me.sndNextStatus(#minimo)
          end if
        end if
      #minimo:
        if running = 1 then
          if pGround = #grass then
            me.sndNextStatus(#ridotta)
          else
            me.sndNextStatus(#prima)
          end if
        else
          if running = -1 and pCurrentSpeed <= 0 then
            me.sndNextStatus(#retro)
          end if
        end if
      #medio:
        if running = 1 then
          if pGround <> #grass then
            me.sndNextStatus(#seconda)
          end if
        else
          me.sndNextStatus(#scalata, 0.80000000000000004)
        end if
      #ridotta:
        if running = 1 then
          if pGround <> #grass then
            me.sndNextStatus(#seconda)
          else
            if nearly_finished then
              me.sndNextStatus(#medio)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.80000000000000004)
        end if
      #prima:
        if running = 1 then
          if pGround = #grass then
            me.sndNextStatus(#ridotta)
          else
            if nearly_finished or abs(pCurrentSpeed) > sndGearSpeed.getPropAt(2) then
              me.sndNextStatus(#seconda)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.80000000000000004)
        end if
      #seconda:
        if running = 1 then
          if pGround = #grass then
            me.sndNextStatus(#scalatina, 0.80000000000000004)
          else
            if nearly_finished or abs(pCurrentSpeed) > sndGearSpeed.getPropAt(3) then
              me.sndNextStatus(#terza)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.59999999999999998)
        end if
      #terza:
        if running = 1 then
          if pGround = #grass then
            me.sndNextStatus(#scalatina, 0.59999999999999998)
          else
            if nearly_finished or abs(pCurrentSpeed) > sndGearSpeed.getPropAt(4) then
              me.sndNextStatus(#quarta)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.40000000000000002)
        end if
      #quarta:
        if running = 1 then
          if pGround = #grass then
            me.sndNextStatus(#scalatina, 0.20000000000000001)
          else
            if nearly_finished or abs(pCurrentSpeed) > sndGearSpeed.getPropAt(5) then
              me.sndNextStatus(#quinta)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.20000000000000001)
        end if
      #quinta:
        if running = 1 then
          if pGround = #grass then
            me.sndNextStatus(#scalatina)
          else
            if nearly_finished then
              me.sndNextStatus(#manetta)
            end if
          end if
        else
          me.sndNextStatus(#scalata)
        end if
      #manetta:
        if running <= 0 then
          me.sndNextStatus(#scalata)
        else
          if pGround = #grass then
            me.sndNextStatus(#scalatina)
          end if
        end if
      #fuorigiri, #sgommata:
        if not running then
          me.sndNextStatus(#scalata)
        else
          me.sndNextStatus(sndGearSpeed[sndGearSpeed.findPosNear(integer(abs(pCurrentSpeed)))])
        end if
      #scalata:
        if running = 1 then
          me.sndNextStatus(sndGearSpeed[sndGearSpeed.findPosNear(integer(abs(pCurrentSpeed)))])
        else
          if running = -1 and pCurrentSpeed <= 0 then
            me.sndNextStatus(#retro)
          else
            if nearly_finished then
              me.sndNextStatus(#minimo)
            end if
          end if
        end if
      #scalatina:
        if running = 1 then
          if pGround <> #grass then
            me.sndNextStatus(#seconda)
          else
            if nearly_finished then
              me.sndNextStatus(#medio)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.59999999999999998)
        end if
    end case
    if pBraking then
      if not sndBrakes and abs(pCurrentSpeed) > sndBrakesSpeed then
        sound(sndChEffects).play(sndList[#frenata])
        sndBrakes = 1
      end if
    else
      sndBrakes = 0
    end if
    if abs(pSlideSpeed) > sndSlidingSpeed or pSgommata then
      if not soundBusy(sndChEffects) and pGround = #track then
        sound(sndChEffects).play(sndList[#slittamento])
      end if
    else
      if soundBusy(sndChEffects) and not sndBrakes then
        sound(sndChEffects).stop()
      end if
    end if
  end if
end

on havok_callback me, cd
  if sndCollisionWait > 0 then
    return 
  end if
  if cd[1] = cd[2] then
    return 
  end if
  groundCollision = cd[2] contains "strada" or cd[2] contains "marciapiede" or cd[2] contains "sterrato"
  if voidp(pUpsideDown) then
    if groundCollision and pFallSpeed > -8 then
      return 
    end if
    if cd[2] contains "CPU" then
      if cd[5] < 2 then
        audio = #crash1
      else
        audio = #crash2
      end if
      danni = integer(G.danni.cpu * cd[5])
    else
      if groundCollision = 1 then
        audio = #impattosuolo
        danni = G.danni.suolo
      else
        if cd[5] < 1.5 then
          audio = #impatto1
        else
          if cd[5] < 2 then
            audio = #impatto2
          else
            audio = #impatto3
          end if
        end if
        danni = integer(G.danni.impatto * cd[5])
      end if
    end if
  else
    if not pDanniRibaltamentoOk then
      pDanniRibaltamentoOk = 1
      audio = #ribaltamento
      danni = G.danni.ribaltamento
    end if
  end if
  sound(sndChCollision).play(sndList[#crash1])
  G.carrozzeria = max(G.carrozzeria - danni, 0)
  if G.carrozzeria <= 0 and animation.step < 7 then
    sound(sndChEngine).play(member("EXPLODE"))
    G.Run = 0
    sound(sndChEffects).stop()
    sound(sndChCollision).stop()
    animation.nextStep(12)
  end if
  newVal = min(integer(G.carrozzeria / 25), 3)
  if pCarrozzeria <> newVal then
    pCarrozzeria = newVal
    pShader.texture = pTexture[pCarrozzeria + 1]
  end if
  sndCollisionWait = 1
end

on correctorMatrix
  if pCorrector = 0 then
    pHavok.corrector.enabled = 1
    pHavok.corrector.threshold = 1
    pHavok.corrector.multiplier = 1
    pHavok.corrector.level = 1
    pHavok.corrector.maxTries = 100
    pHavok.corrector.maxDistance = 10
    trans = pmodel.transform.duplicate()
    trans.rotation.x = 0
    p = pmodel.worldPosition + vector(0, 0, 3)
    repeat with Dir in [vector(1, 0, 0), vector(-1, 0, 0), vector(0, 1, 0), vector(0, -1, 0)]
      ray = world.modelsUnderRay(p, Dir, 1, #detailed)
      if ray.count = 1 then
        if ray[1].distance < 2 then
          p = p - Dir * 2
        end if
      end if
    end repeat
    pHavok.correctorMoveTo(p, trans.axisAngle)
    pCorrector = havok.simTime + 4
    sound(sndChEngine).play(member("gatewhine"))
    sound(sndChEffects).stop()
    sound(sndChCollision).stop()
    sndStatus = #minimo
  end if
end
