-- Cast Lingo BehaviorScript DriveCPU1.ls

property gForward, gUp, gDown, pMaxSpeed, pminspeed, pAccGain, pDecGain, pBrakeGain, pTurnGain, pReTurnGain, pGrip, pDrag, pMaxHeight, pRadarHeight, spriteNum, pSprite, world, pmodel, pPlayer, pTarget, pShadow, pcamera, pHavok, aiStatus, aiLastStatusChange, aiLastCheck, aiLastStatus, aiInitialLato, aiAction, aiPhase, aiLastActionChange, aiLookAt, pGoingForward, pGoingBackward, pGoingLeft, pGoingRight, pBraking, pMass, pheight, pObjectUnder, pMainDirector, pContact, pNormal, pCurrentSpeed, pSlideSpeed, pFallSpeed, pAngularVel, pSphere, pCurrentFwd, pCurrentAxis, pCurrentRight, pFullRetro, sndCh, sndList, sndStatus, sndWait
global G, havok, human, animation, CPU1, trail

on beginSprite me
  CPU1 = me
  gForward = G.forward
  gUp = G.up
  gDown = -G.up
  pSprite = sprite(me.spriteNum)
  world = pSprite.member
  pmodel = world.model("FurgoneCPU")
  pPlayer = world.model("AutoPlayer")
  pTarget = world.model("Target1")
  pcamera = world.camera("MainCamera")
  pHavok = havok.rigidBody(pmodel.name)
  pMass = pHavok.mass
  pSphere = pmodel.boundingSphere[2]
  pShadow = new(script("shadow"), pmodel, "ombracpu", gUp, G.shadowHeight)
  pMaxSpeed = 120.0
  pAccGain = 0.10000000000000001 * pMass
  pDecGain = 0.10000000000000001 * pMass
  pBrakeGain = 0.10000000000000001 * pMass
  pTurnGain = 0.20000000000000001 * pMass
  pReTurnGain = pTurnGain
  pGrip = 0.29999999999999999
  pDrag = 0.02 * pMass
  pMaxHeight = 2
  pRadarHeight = vector(0, 0, 3)
  aiLookAt = [#pos: vector(0, 0, 0), #Dir: vector(0, 0, 0), #model: VOID]
  me.aiChangeStatus(#retro)
  me.aiChangeAction(#lookingForTarget)
  pGoingForward = 0
  pGoingBackward = 0
  pGoingLeft = 0
  pGoingRight = 0
  pBraking = 0
  pFullRetro = 0
  sndCh = 5
  sndList = [:]
  sndList[#avanti] = [[#member: member("1")], [#member: member("2")], [#member: member("3")], [#member: member("4")], [#member: member("5")], [#member: member("manetta"), #loopCount: 0]]
  sndList[#retro] = [[#member: member("retro+loop"), #loopStartTime: 2724, #loopCount: 0]]
  sndList[#aria] = [[#member: member("sgommata")], [#member: member("fuorigiri"), #loopCount: 0]]
  sndList[#slittamento] = [[#member: member("screech")]]
  sndList[#scalata] = [[#member: member("scalata")]]
  sndList[#frenata] = [[#member: member("freno")]]
  me.sndNextStatus(#none)
  havok.registerInterest(pmodel.name, #all, 4, 1, #havok_callback, me)
end

on prepareFrame me
  me.probeGround()
  if not voidp(pContact) then
    pShadow.updateShadow(pContact, pNormal)
  end if
end

on exitFrame me
  if G.Run then
    me.driveController()
    me.soundController()
    me.snd3DManager()
  end if
end

on probeGround me
  ground = world.modelsUnderRay(pmodel.worldPosition, gDown, 3, #detailed)
  repeat with i = 1 to ground.count()
    pObjectUnder = ground[i].model.name
    if not (pObjectUnder contains pmodel.name) then
      pContact = ground[i].isectPosition
      pNormal = ground[i].isectNormal
      pheight = ground[i].distance
      return 
    end if
  end repeat
  pContact = VOID
  pObjectUnder = EMPTY
  pheight = 9999
end

on driveController me
  trans = pmodel.transform.duplicate()
  trans.position = vector(0, 0, 0)
  trans.scale = vector(1, 1, 1)
  pCurrentFwd = trans * gForward
  pCurrentAxis = trans * gUp
  pCurrentRight = pCurrentFwd.cross(pCurrentAxis)
  ang = pHavok.rotation
  t = transform()
  t.rotate(vector(0, 0, 0), ang[1], ang[2])
  oldx = t.rotation.x
  oldy = t.rotation.y
  if abs(oldx) > 30 or abs(oldy) > 30 then
    t.rotation.x = min(30, max(-30, oldx))
    t.rotation.y = min(30, max(-30, oldy))
    pHavok.rotation = t.axisAngle
  end if
  if havok.simTime - aiLastCheck > 1 then
    me.aiCheckStatus()
  end if
  if havok.simTime - aiLastActionChange > 1 then
    me.aiCheckAction()
  end if
  me.aiPerformAction()
  if pheight < pMaxHeight then
    currentVel = pHavok.linearVelocity
    pCurrentSpeed = currentVel.dot(pCurrentFwd)
    pSlideSpeed = currentVel.dot(pCurrentRight)
    pFallSpeed = currentVel.dot(pCurrentAxis)
    propSpeed = min(abs(pCurrentSpeed) / pMaxSpeed, 1)
    pAngularVel = pHavok.angularVelocity
    if pGoingForward then
      diff = pMaxSpeed - pCurrentSpeed
      imp = diff * pAccGain * pGrip * pCurrentFwd
      pHavok.applyImpulse(imp)
    end if
    if pGoingBackward then
      diff = -pMaxSpeed / 2 - pCurrentSpeed
      imp = diff * pDecGain * pGrip * pCurrentFwd
      pHavok.applyImpulse(imp)
    end if
    if pBraking then
      imp = -pCurrentSpeed * pBrakeGain * pCurrentFwd
      pHavok.applyImpulse(imp)
    end if
    if pGoingLeft > 0 then
      imp = pCurrentAxis * pTurnGain * pGoingLeft
      pHavok.applyAngularImpulse(imp)
    end if
    if pGoingRight > 0 then
      imp = pCurrentAxis * -pTurnGain * pGoingRight
      pHavok.applyAngularImpulse(imp)
    end if
    if not pBraking then
      imp = pCurrentRight * (-pSlideSpeed * pMass * pGrip)
      pHavok.applyImpulse(imp)
    end if
    if pGoingRight = 0 and pGoingLeft = 0 then
      imp = pCurrentAxis * pAngularVel.dot(pCurrentAxis) * -pReTurnGain
      pHavok.applyAngularImpulse(imp)
    end if
    imp = -currentVel * pDrag
    pHavok.applyImpulse(imp)
  end if
end

on sndNextStatus me, newstatus
  sndStatus = newstatus
  if newstatus = #none then
    sound(sndCh).setPlayList([])
    sound(sndCh).stop()
  else
    sound(sndCh).setPlayList([])
    sound(sndCh).stop()
    sound(sndCh).setPlayList(sndList[sndStatus])
    sound(sndCh).play()
  end if
  sndWait = 2
end

on soundController me
  if sndWait > 0 then
    sndWait = sndWait - 1
    return 
  end if
  if pheight >= pMaxHeight then
    newstatus = #aria
  else
    if pBraking then
      newstatus = #frenata
    else
      if pGoingForward then
        newstatus = #avanti
      else
        if pGoingBackward then
          newstatus = #retro
        else
          newstatus = sndStatus
        end if
      end if
    end if
  end if
  if sndStatus <> newstatus then
    me.sndNextStatus(newstatus)
  end if
end

on snd3DManager me
  if not G.snd3D or sndWait > 0 or sndStatus = #none then
    return 
  end if
  dist = pPlayer.worldPosition.distanceTo(pmodel.worldPosition)
  vol = min(200 * (10 / dist), 200)
  sound(sndCh).volume = vol
  Dir = pmodel.worldPosition - pPlayer.worldPosition
  Dir.normalize()
  sound(sndCh).pan = -50 * Dir.dot(pCurrentRight)
end

on havok_callback me, cd
  if aiStatus = #lost then
    return 
  end if
  if cd[2] contains "azz" then
    if aiStatus = #retro then
      me.aiChangeStatus(#Ok)
    else
      me.aiChangeStatus(#retro)
    end if
  else
    if cd[2] contains "player" then
      if abs(human.pCurrentSpeed) < 15 then
        me.aiChangeStatus(#retro)
        pFullRetro = 1
      end if
    end if
  end if
end

on aiChangeStatus me, newstatus
  aiLastStatus = [#status: aiStatus, #Action: aiAction, #pos: pmodel.worldPosition, #speed: pCurrentSpeed]
  if aiStatus <> newstatus then
    aiStatus = newstatus
    aiLastStatusChange = havok.simTime
    aiInitialLato = VOID
    pFullRetro = 0
  end if
end

on aiCheckStatus me
  if aiLastStatus.status = aiStatus and aiLastStatus.Action = aiAction then
    if havok.simTime - aiLastStatusChange > 4 then
      if pGoingForward and pCurrentSpeed < 1 then
        me.aiChangeStatus(#retro)
      end if
    end if
  end if
  me.aiChangeStatus(aiStatus)
  aiLastCheck = havok.simTime
end

on aiChangeAction me, newAction, mark
  aiAction = newAction
  aiPhase = 1
  aiLastActionChange = havok.simTime
  case aiAction of
    #followPlayer:
      aiLookAt.model = pPlayer
      aiLookAt.pos = pTarget.worldPosition
      aiLookAt.Dir = VOID
    #followMarker:
      aiLookAt.model = VOID
      if not voidp(mark) then
        aiLookAt.pos = mark.pos
        aiLookAt.Dir = mark.Dir
      else
        aiLookAt.Dir = VOID
      end if
    #lookingForTarget:
      aiLookAt.model = VOID
      aiLookAt.pos = VOID
      aiLookAt.Dir = VOID
      me.aiChangeStatus(#lost)
  end case
end

on aiCheckAction me
  aiLastActionChange = havok.simTime
  case aiAction of
    #followPlayer:
      if me.aiLookForPlayer() then
        if aiStatus <> #Ok then
          me.aiChangeStatus(#Ok)
        end if
      else
        if aiStatus <> #searching then
          me.aiChangeStatus(#searching)
        else
          me.aiChangeAction(#followMarker, VOID)
          return 
        end if
      end if
      if abs(pCurrentFwd.angleBetween(aiLookAt.pos - pmodel.worldPosition)) > 45 then
        if pmodel.worldPosition.distanceTo(aiLookAt.pos) > 20 then
          if me.aiHidden(pmodel.worldPosition) then
            Dir = aiLookAt.pos - pmodel.worldPosition
            ang = vector(1, 0, 0).angleBetween(Dir)
            verso = sign(vector(0, 1, 0).dot(Dir))
            havokang = [vector(0, 0, 1), verso * ang]
            vel = pHavok.linearVelocity.magnitude
            pos = pHavok.position
            if pHavok.attemptMoveTo(pos, havokang) then
              pHavok.position.z = pos.z
              Dir.normalize()
              pHavok.linearVelocity = Dir * vel
              pHavok.angularVelocity = vector(0, 0, 0)
              if aiStatus = #retro then
                me.aiChangeStatus(#Ok)
              end if
            end if
          end if
        end if
      end if
    #followMarker:
      if me.aiLookForPlayer() then
        me.aiChangeStatus(#Ok)
        me.aiChangeAction(#followPlayer)
        return 
      end if
      if me.aiHidden(pmodel.worldPosition) then
        if me.aiHidden(aiLookAt.pos) then
          if not voidp(aiLookAt.Dir) then
            ang = vector(1, 0, 0).angleBetween(aiLookAt.Dir)
            verso = sign(vector(0, 1, 0).dot(aiLookAt.Dir))
            havokang = [vector(0, 0, 1), verso * ang]
            vel = pHavok.linearVelocity.magnitude
          else
            havokang = pHavok.rotation
          end if
          if pHavok.attemptMoveTo(aiLookAt.pos + vector(0, 0, pMaxHeight), havokang) then
            pHavok.interpolatingMoveTo(aiLookAt.pos, havokang)
            if not voidp(aiLookAt.Dir) then
              aiLookAt.Dir.normalize()
              pHavok.linearVelocity = aiLookAt.Dir * max(vel, human.pCurrentSpeed)
            end if
            me.aiChangeAction(#lookingForTarget)
          end if
        end if
      end if
    #lookingForTarget:
      me.aiFindNewTarget()
  end case
end

on aiFindNewTarget me
  if aiPhase = 1 then
    if me.aiLookForPlayer() then
      me.aiChangeStatus(#Ok)
      me.aiChangeAction(#followPlayer)
      return 1
    end if
  else
    mark = trail.getMark(aiPhase - 1)
    if voidp(mark) then
      aiPhase = 1
      return 0
    end if
    if me.aiHidden(mark.pos) then
      if me.aiHidden(pmodel.worldPosition) then
        ang = vector(1, 0, 0).angleBetween(mark.Dir)
        verso = sign(vector(0, 1, 0).dot(mark.Dir))
        havokang = [vector(0, 0, 1), verso * ang]
        vel = pHavok.linearVelocity.magnitude
        if pHavok.attemptMoveTo(mark.pos + vector(0, 0, pMaxHeight), havokang) then
          pHavok.interpolatingMoveTo(mark.pos, havokang)
          mark.Dir.normalize()
          pHavok.linearVelocity = mark.Dir * vel
          me.aiChangeStatus(#Ok)
          me.aiChangeAction(#followPlayer)
          trail.deleteMark(mark)
          return 1
        end if
      end if
    end if
  end if
  aiPhase = aiPhase + 1
  return 0
end

on aiLookForPlayer me
  lookFrom = pmodel.worldPosition + pRadarHeight
  lookDir = pPlayer.worldPosition - lookFrom
  radar = world.modelsUnderRay(lookFrom, lookDir, 6, #simple)
  repeat with i = 1 to radar.count
    name = radar[i].name
    if name contains "AutoPlayer" or name contains "Target" then
      return 1
    end if
    if name contains "azz" then
      return 0
    end if
  end repeat
  return 0
end

on aiHidden me, pos
  if not voidp(pcamera.worldSpaceToSpriteSpace(pos + vector(pSphere, 0, 0))) then
    return 0
  end if
  if not voidp(pcamera.worldSpaceToSpriteSpace(pos + vector(-pSphere, 0, 0))) then
    return 0
  end if
  if not voidp(pcamera.worldSpaceToSpriteSpace(pos + vector(0, pSphere, 0))) then
    return 0
  end if
  if not voidp(pcamera.worldSpaceToSpriteSpace(pos + vector(0, -pSphere, 0))) then
    return 0
  end if
  return 1
end

on aiPerformAction me
  if aiAction = #followPlayer and aiStatus <> #searching then
    aiLookAt.pos = pTarget.worldPosition
  end if
  if not voidp(aiLookAt.pos) then
    targetDir = (aiLookAt.pos - pmodel.worldPosition).getNormalized()
    lato = pCurrentRight.dot(targetDir)
    ang = targetDir.angleBetween(pCurrentFwd)
    if voidp(aiInitialLato) then
      aiInitialLato = sign(lato)
    end if
  end if
  case aiStatus of
    #retro:
      pGoingForward = 0
      pBraking = 0
      if havok.simTime - aiLastStatusChange < 1.5 then
        pGoingBackward = 1
        if not voidp(aiLookAt.pos) and not pFullRetro then
          if sign(lato) = aiInitialLato then
            pGoingRight = max(lato, 0)
            pGoingLeft = max(-lato, 0)
            return 
          end if
        else
          return 
        end if
      end if
      pGoingBackward = 0
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
      if sign(lato) = aiInitialLato then
        pGoingRight = max(lato, 0)
        pGoingLeft = max(-lato, 0)
      else
        pGoingRight = 0
        pGoingLeft = 0
        aiInitialLato = VOID
        pHavok.angularmomentum = vector(0, 0, 0)
      end if
      pBraking = 0
      pGoingBackward = 0
      if ang < 45 then
        pGoingForward = 1
      else
        dist = pmodel.worldPosition.distanceTo(aiLookAt.pos)
        if dist > 100 then
          pGoingForward = pCurrentSpeed < 20
        else
          if ang < 90 then
            pGoingForward = pCurrentSpeed < 10
          else
            me.aiChangeStatus(#retro)
            return 
          end if
        end if
      end if
      if aiAction = #followMarker then
        dist = pmodel.worldPosition.distanceTo(aiLookAt.pos)
        if dist <= 8 then
          pGoingForward = 0
          pGoingBackward = 0
          me.aiChangeAction(#lookingForTarget)
        end if
      end if
  end case
end
