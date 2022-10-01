-- Cast Lingo BehaviorScript DriveCPU2[disc].ls

property debugTrail, pMaxSpeed, pminspeed, pMaxTurnSpeed, pAccGain, pDecGain, pBrakeGain, pTurnGain, pReTurnGain, pGrip, pForward, pUp, pDown, pDrag, shadowZ, pMaxHeight, pRadarHeight, pCorrectorActivation, pTrackSpeed, pGroundSpeed, pGrassSpeed, pTrackGrip, pGroundGrip, pGrassGrip, spriteNum, pSprite, world, pmodel, pPlayer, pTarget, pShadow, aiStatus, aiLastStatusChange, aiAction, aiPhase, aiLookAt, aiPointAt, aiLastCheck, aiLastStatus, pGoingForward, pGoingBackward, pGoingLeft, pGoingRight, pBraking, pheight, pObjectUnder, pMainDirector, pGround, pContact, pCurrentSpeed, pSlideSpeed, pFallSpeed, pAngularVel, pUpsideDown, pCorrector, sndCh, sndList, sndOverlap, sndStatus, sndPercentage, sndWait
global G, havok, CPU2, trail

on beginSprite me
  debugTrail = new(script("trail"), 3, 1, 0, 0, 0, 1)
  CPU2 = me
  pSprite = sprite(me.spriteNum)
  world = pSprite.member
  pmodel = world.model("PickUpCPU")
  pPlayer = world.model("AutoPlayer")
  pTarget = world.model("Target2")
  pShadow = world.model(pmodel.name & "ombra+")
  if voidp(pShadow) then
    pShadow = world.model("ombra+").clone(pmodel.name & "ombra+")
  end if
  pMaxSpeed = 200.0
  pminspeed = 2
  pMaxTurnSpeed = 2.0
  pAccGain = 0.02
  pDecGain = 0.02
  pBrakeGain = 0.10000000000000001
  pTurnGain = 0.20000000000000001
  pGrip = 0.29999999999999999
  pDrag = 0.02
  pForward = vector(1, 0, 0)
  pUp = vector(0, 0, 1)
  pDown = vector(0, 0, -1)
  shadowZ = 0.29999999999999999
  pMaxHeight = 1
  pRadarHeight = vector(0, 0, 3)
  pCorrectorActivation = 1
  pReTurnGain = pTurnGain
  pTrackSpeed = pMaxSpeed
  pGroundSpeed = pMaxSpeed
  pGrassSpeed = pMaxSpeed * 3 / 4
  pTrackGrip = pGrip
  pGroundGrip = pGrip
  pGrassGrip = pGrip * 3 / 4
  me.aiChangeStatus(#retro)
  me.aiChangeAction(#lookingForTarget)
  me.aiSaveStatus()
  pGoingForward = 0
  pGoingBackward = 0
  pGoingLeft = 0
  pGoingRight = 0
  pBraking = 0
  sndCh = 6
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
  sndList[#crash1] = [#member: member("crash")]
  sndList[#crash2] = [#member: member("crash")]
  sndList[#crash3] = [#member: member("crash")]
  sndList[#impatto1] = [#member: member("impatto")]
  sndList[#impatto2] = [#member: member("impatto")]
  sndList[#impatto3] = [#member: member("impatto")]
  sndOverlap = 100
  me.sndNextStatus(#minimo)
  sndWait = 0
  havok.registerInterest(pmodel.name, #all, 4, 1, #havok_callback, me)
end

on prepareFrame me
  me.probeGround()
  if not voidp(pContact) then
    me.updateShadow()
  end if
end

on exitFrame me
  if G.Run then
    if pCorrector > 0 then
      pCorrector = pCorrector - 1
      if pCorrector = 0 then
        rb = havok.rigidBody(pmodel.name)
        rb.corrector.enabled = 0
      end if
    else
      me.driveController()
      me.soundController()
      me.snd3DManager()
    end if
  end if
end

on probeGround me
  ground = world.modelsUnderRay(pmodel.worldPosition, pDown, 3, #detailed)
  repeat with i = 1 to ground.count()
    pObjectUnder = ground[i].model.name
    if not (pObjectUnder contains pmodel.name) then
      if pObjectUnder contains "Campetto" then
        pGround = #grass
      else
        if pObjectUnder contains "strada" then
          pGround = #track
        else
          if pObjectUnder contains "marciapiede" then
            pGround = #ground
          else
            pGround = #grass
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
      pContact = ground[i].isectPosition
      pheight = ground[i].distance
      return 
    end if
  end repeat
  pGrip = 0
  pContact = VOID
  pObjectUnder = EMPTY
  pheight = 9999
end

on updateShadow me
  t = transform()
  t.position = pContact
  t.translate(pUp * shadowZ)
  t.rotation = pmodel.transform.rotation
  pShadow.transform = t
end

on aiChangeStatus me, newstatus
  aiStatus = newstatus
  aiLastStatusChange = havok.simTime
end

on aiChangeAction me, newAction, NewPos
  aiAction = newAction
  aiPhase = 1
  case aiAction of
    #followPlayer:
      aiLookAt = pPlayer
      aiPointAt = pTarget.worldPosition
      debugTrail.dropMark(aiPointAt)
    #followMarker:
      aiLookAt = VOID
      aiPointAt = NewPos
      debugTrail.dropMark(aiPointAt)
    #lookingForTarget:
      aiLookAt = VOID
      aiPointAt = VOID
      debugTrail.reset()
  end case
end

on aiFindNewTarget me
  case aiPhase of
    1:
      if me.aiLookForPlayer() then
        me.aiChangeStatus(#Ok)
        me.aiChangeAction(#followPlayer)
        return 1
      end if
    2, 3, 4:
      mark = trail.getMark(aiPhase - 1)
      if not voidp(mark) then
        if me.aiLookForMarker(mark) then
          me.aiChangeStatus(#Ok)
          me.aiChangeAction(#followMarker, mark.pos)
          return 1
        end if
      end if
    5, 6, 7:
      if voidp(sprite(spriteNum).camera.worldSpaceToSpriteSpace(pmodel.worldPosition)) then
        mark = trail.getHiddenMark(sprite(spriteNum).camera)
        if not voidp(mark) then
          rb = havok.rigidBody(pmodel.name)
          rb.position = mark.pos + pheight
          ang = vector(1, 0, 0).angleBetween(mark.Dir)
          rb.rotation = [vector(0, 0, 1), ang]
          me.aiChangeStatus(#lost)
          me.aiChangeAction(#lookingForTarget)
          return 1
        end if
      end if
    otherwise:
      aiPhase = 0
  end case
  aiPhase = aiPhase + 1
  return 0
end

on aiLookForPlayer me
  lookFrom = pmodel.worldPosition + pRadarHeight
  lookDir = pPlayer.worldPosition - lookFrom
  radar = world.modelsUnderRay(lookFrom, lookDir, 4, #simple)
  repeat with i = 1 to radar.count
    name = radar[i].name
    if name contains "Trail" or name contains "CPU" then
      nothing()
      next repeat
    end if
    if name contains "AutoPlayer" then
      return 1
      next repeat
    end if
    return 0
  end repeat
  return 0
end

on aiLookForMarker me, mark
  lookFrom = pmodel.worldPosition + pRadarHeight
  lookDir = mark.pos - lookFrom
  radar = world.modelsUnderRay(lookFrom, lookDir, 3, #simple)
  repeat with i = 1 to radar.count
    name = radar[i].name
    if name contains "Trail3" or name contains "CPU" then
      nothing()
      next repeat
    end if
    if radar[1] = mark.model then
      return 1
      next repeat
    end if
    return 0
  end repeat
  return 0
end

on aiSaveStatus me
  aiLastStatus = [#time: havok.simTime, #status: aiStatus, #Action: aiAction, #pos: pmodel.worldPosition, #speed: pCurrentSpeed]
end

on getKeys me, currentFwd, currentRight
  if havok.simTime - aiLastStatus.time > 1 then
    if aiLastStatus.status = aiStatus and aiLastStatus.Action = aiAction then
      if aiStatus = #Ok and pCurrentSpeed < 1 then
        pGoingRight = not pGoingRight
        pGoingLeft = not pGoingLeft
        me.aiChangeStatus(#retro)
      end if
    end if
    me.aiSaveStatus()
  end if
  case aiStatus of
    #retro:
      if havok.simTime - aiLastStatusChange < 1 then
        pGoingForward = 0
        pGoingBackward = 1
        pBraking = 0
        return 
      end if
      pGoingForward = 0
      pGoingBackward = 0
      pBraking = 0
      pGoingRight = 0
      pGoingLeft = 0
      me.aiChangeStatus(#Ok)
      return 
    #lost:
      pGoingForward = 0
      pGoingBackward = 0
      pBraking = 0
      pGoingRight = 0
      pGoingLeft = 0
      me.aiFindNewTarget()
      return 
    #Ok, #searching:
      case aiAction of
        #followPlayer:
          aiPoint = pmodel.worldPosition
          dist = aiPoint.distanceTo(aiPointAt)
          ang = currentFwd.angleBetween(aiPointAt - aiPoint)
          if ang > 90 or dist <= 2 then
            me.aiChangeAction(#followPlayer)
            dist = aiPoint.distanceTo(aiPointAt)
            ang = currentFwd.angleBetween(aiPointAt - aiPoint)
            if ang > 90 or dist <= 2 then
              aiPoint = pmodel.worldPosition
              lato = currentRight.dot(pPlayer.worldPosition - aiPoint)
              pGoingForward = 0
              pGoingBackward = 1
              pBraking = 0
              pGoingRight = lato < 0
              pGoingLeft = lato > 0
              me.aiChangeStatus(#retro)
              return 
            end if
          end if
          lato = currentRight.dot(aiPointAt - aiPoint)
          pGoingRight = lato > 0
          pGoingLeft = lato < 0
          if me.aiLookForPlayer() then
            pGoingForward = 1
            pGoingBackward = 0
            pBraking = 0
            if aiStatus <> #Ok then
              me.aiChangeStatus(#Ok)
            end if
          else
            pGoingForward = 0
            pGoingBackward = 0
            pBraking = 0
            if aiStatus <> #searching then
              me.aiChangeStatus(#searching)
            end if
            if havok.simTime - aiLastStatusChange > 1 then
              pGoingRight = 0
              pGoingLeft = 0
              me.aiChangeStatus(#lost)
            end if
          end if
        #followMarker:
          aiPoint = pmodel.worldPosition
          dist = aiPoint.distanceTo(aiPointAt)
          ang = currentFwd.angleBetween(aiPointAt - aiPoint)
          lato = currentRight.dot(aiPointAt - aiPoint)
          pGoingRight = lato > 0
          pGoingLeft = lato < 0
          if dist <= 8 then
            pGoingForward = 0
            pGoingBackward = 0
            me.aiChangeStatus(#lost)
            me.aiChangeAction(#lookingForTarget)
          else
            pGoingForward = 1
            pGoingBackward = 0
            pBraking = 0
          end if
        #lookingForTarget:
          pGoingForward = 0
          pGoingBackward = 0
          pBraking = 0
          me.aiFindNewTarget()
          return 
      end case
  end case
end

on driveController me
  trans = pmodel.transform.duplicate()
  trans.position = vector(0, 0, 0)
  trans.scale = vector(1, 1, 1)
  currentFwd = trans * pForward
  currentAxis = trans * pUp
  currentRight = currentFwd.cross(currentAxis)
  me.getKeys(currentFwd, currentRight)
  if pheight < pMaxHeight then
    rb = havok.rigidBody(pmodel.name)
    currentVel = rb.linearVelocity
    pCurrentSpeed = currentVel.dot(currentFwd)
    pSlideSpeed = currentVel.dot(currentRight)
    pFallSpeed = currentVel.dot(currentAxis)
    propSpeed = min(abs(pCurrentSpeed) / pMaxSpeed, 1)
    pAngularVel = rb.angularVelocity
    mass = rb.mass
    if pGoingForward then
      diff = pMaxSpeed - pCurrentSpeed
      imp = diff * pAccGain * mass * pGrip * currentFwd
      rb.applyImpulse(imp)
    end if
    if pGoingBackward then
      diff = -pMaxSpeed / 2 - pCurrentSpeed
      imp = diff * pDecGain * mass * pGrip * currentFwd
      rb.applyImpulse(imp)
    end if
    if pBraking then
      imp = -pCurrentSpeed * pBrakeGain * mass * currentFwd
      rb.applyImpulse(imp)
    end if
    mTS = min(abs(pCurrentSpeed), (1.0 - propSpeed) * pMaxTurnSpeed)
    canTurn = abs(pAngularVel.dot(currentAxis)) < mTS
    if canTurn then
      if pGoingLeft then
        imp = currentAxis * (pTurnGain * mass)
        if pGoingBackward then
          imp = -imp
        end if
        rb.applyAngularImpulse(imp)
      end if
      if pGoingRight then
        imp = currentAxis * (-pTurnGain * mass)
        if pGoingBackward then
          imp = -imp
        end if
        rb.applyAngularImpulse(imp)
      end if
    end if
    if not pBraking then
      imp = currentRight * (-pSlideSpeed * mass * pGrip)
      rb.applyImpulse(imp)
    end if
    if canTurn = 0 or pGoingLeft = 0 and pGoingRight = 0 then
      imp = currentAxis * pAngularVel.dot(currentAxis) * (-pReTurnGain * mass)
      rb.applyAngularImpulse(imp)
    end if
    if currentVel.magnitude > pminspeed then
      imp = -currentVel * (pDrag * mass)
      rb.applyImpulse(imp)
    end if
  end if
  if currentAxis.dot(pUp) > 0.5 then
    pUpsideDown = VOID
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
    sound(sndCh).play(sndList[sndStatus])
  else
    snd = duplicate(sndList[sndStatus])
    snd[#startTime] = sndList[sndStatus].member.duration * (1 - percentage)
    sound(sndCh).play(snd)
  end if
  sndWait = 2
end

on soundController me
  if sndWait > 0 then
    sndWait = sndWait - 1
    return 
  end if
  sndPercentage = sound(sndCh).elapsedTime / sndList[sndStatus].member.duration
  nearly_finished = sound(sndCh).endTime - sound(sndCh).elapsedTime < sndOverlap
  running = pGoingForward or pGoingBackward
  if pheight >= pMaxHeight then
    case sndStatus of
      #sgommata:
        if nearly_finished then
          me.sndNextStatus(#fuorigiri)
        end if
      otherwise:
        me.sndNextStatus(#sgommata)
    end case
  else
    case sndStatus of
      #retro:
        if pGoingForward then
          me.sndNextStatus(#prima)
        else
          if not pGoingBackward then
            me.sndNextStatus(#minimo)
          end if
        end if
      #minimo:
        if pGoingForward then
          if pGround = #grass then
            me.sndNextStatus(#ridotta)
          else
            me.sndNextStatus(#prima)
          end if
        else
          if pGoingBackward then
            me.sndNextStatus(#retro)
          end if
        end if
      #medio:
        if pGoingForward then
          if pGround <> #grass then
            me.sndNextStatus(#seconda)
          end if
        else
          if pGoingBackward then
            me.sndNextStatus(#retro)
          else
            me.sndNextStatus(#scalata, 0.80000000000000004)
          end if
        end if
      #ridotta:
        if pGoingForward then
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
        if pGoingForward then
          if pGround = #grass then
            me.sndNextStatus(#ridotta)
          else
            if nearly_finished then
              me.sndNextStatus(#seconda)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.80000000000000004)
        end if
      #seconda:
        if pGoingForward then
          if pGround = #grass then
            me.sndNextStatus(#scalatina, 0.80000000000000004)
          else
            if nearly_finished then
              me.sndNextStatus(#terza)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.59999999999999998)
        end if
      #terza:
        if pGoingForward then
          if pGround = #grass then
            me.sndNextStatus(#scalatina, 0.59999999999999998)
          else
            if nearly_finished then
              me.sndNextStatus(#quarta)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.40000000000000002)
        end if
      #quarta:
        if pGoingForward then
          if pGround = #grass then
            me.sndNextStatus(#scalatina, 0.20000000000000001)
          else
            if nearly_finished then
              me.sndNextStatus(#quinta)
            end if
          end if
        else
          me.sndNextStatus(#scalata, 0.20000000000000001)
        end if
      #quinta:
        if pGoingForward then
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
        if not pGoingForward then
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
          me.sndNextStatus(#prima)
        end if
      #scalata:
        if not running then
          if nearly_finished then
            me.sndNextStatus(#minimo)
          end if
        else
          if pGoingBackward then
            me.sndNextStatus(#retro)
          else
            me.sndNextStatus(#prima)
          end if
        end if
      #scalatina:
        if pGoingForward then
          if pGround <> #grass then
            me.sndNextStatus(#seconda)
          else
            if nearly_finished then
              me.sndNextStatus(#medio)
            end if
          end if
        else
          if pGoingBackward then
            me.sndNextStatus(#retro)
          else
            me.sndNextStatus(#scalata, 0.59999999999999998)
          end if
        end if
    end case
  end if
end

on snd3DManager me
  if sndWait > 0 then
    return 
  end if
  camera = sprite(spriteNum).camera
  dist = camera.worldPosition.distanceTo(pmodel.worldPosition)
  vol = min(210 * (10 / dist), 210)
  Dir = pmodel.worldPosition - camera.worldPosition
  radar = world.modelsUnderRay(camera.worldPosition, Dir, 1, #simple)
  if radar.count = 1 then
    if radar[1] = pmodel then
      vol = vol + 40
    end if
  end if
  sound(sndCh).volume = vol
  cameraRight = camera.transform * vector(1, 0, 0)
  cameraRight.normalize()
  Dir.normalize()
  sound(sndCh).pan = -50 * Dir.dot(cameraRight)
end

on havok_callback me, cd
  if cd[2] contains "palazzo" or cd[2] contains "box" then
    if aiStatus <> #retro then
      if not voidp(aiPointAt) then
        trans = pmodel.transform.duplicate()
        currentRight = pmodel.transform * pForward.cross(pUp)
        aiPoint = pmodel.worldPosition
        lato = currentRight.dot(aiPointAt - aiPoint)
        pGoingRight = lato < 0
        pGoingLeft = lato > 0
      end if
      me.aiChangeStatus(#retro)
    end if
  end if
end

on correctorMatrix
  if pCorrector = 0 then
    rb = havok.rigidBody(pmodel.name)
    rb.corrector.enabled = 1
    rb.corrector.threshold = 1
    rb.corrector.multiplier = 5
    rb.corrector.level = 2
    rb.corrector.maxTries = 100
    rb.corrector.maxDistance = 10
    trans = pmodel.transform.duplicate()
    trans.rotation.x = 0
    p = pmodel.worldPosition + vector(0, 0, 2)
    rb.correctorMoveTo(p, trans.axisAngle, vector(0, 0, 0), vector(0, 0, 0))
    pCorrector = 10
    sndStatus = #minimo
  end if
end
