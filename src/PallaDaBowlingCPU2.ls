-- Cast Lingo BehaviorScript PallaDaBowlingCPU2.ls

property gForward, gUp, gDown, pMaxSpeed, pminspeed, pAccGain, pDecGain, pBrakeGain, pTurnGain, pReTurnGain, pGrip, pDrag, pMaxHeight, pRadarHeight, spriteNum, pSprite, world, pmodel, pPlayer, pTargetDx, pTargetSx, pShadow, pcamera, pHavok, aiStatus, aiLastStatusChange, aiInitialLato, aiAction, aiPhase, aiLastActionChange, aiWaitBeforeDisappear, aiWaitBeforeAttack, aiLookAt, aiGarage, pHidden, pGoingForward, pGoingBackward, pGoingLeft, pGoingRight, pBraking, pMass, pheight, pObjectUnder, pMainDirector, pContact, pNormal, pCurrentSpeed, pSlideSpeed, pFallSpeed, pAngularVel, pSphere, pCurrentFwd, pCurrentAxis, pCurrentRight, pFullRetro, sndCh, sndList, sndStatus, sndWait
global G, havok, human, CPU2, trail

on beginSprite me
  CPU2 = me
  gForward = G.forward
  gUp = G.up
  gDown = -G.up
  pSprite = sprite(me.spriteNum)
  world = pSprite.member
  pmodel = world.model("JeepCPU01")
  pPlayer = world.model("AutoPlayer")
  pTargetSx = world.model("Target2")
  pTargetDx = world.model("Target3")
  pcamera = world.camera("MainCamera")
  pHavok = havok.rigidBody(pmodel.name)
  pMass = pHavok.mass
  pSphere = pmodel.boundingSphere[2]
  pShadow = new(script("shadow"), pmodel, "ombracpu", gUp, G.shadowHeight)
  pMaxSpeed = 150.0
  pAccGain = 0.04 * pMass
  pDecGain = 0.04 * pMass
  pBrakeGain = 0.10000000000000001 * pMass
  pTurnGain = 0.5 * pMass
  pReTurnGain = pTurnGain
  pGrip = 0.29999999999999999
  pDrag = 0.02 * pMass
  pMaxHeight = 1
  pRadarHeight = vector(0, 0, 3)
  aiWaitBeforeDisappear = 8
  aiWaitBeforeAttack = 8
  aiLookAt = [#pos: vector(0, 0, 0), #model: VOID]
  me.aiChangeStatus(#agguato1)
  me.aiChangeAction(#waitingForAction)
  pHavok.position = vector(-33, -823, 16)
  pHavok.rotation = [vector(0, 0, 1), 0]
  pGoingForward = 0
  pGoingBackward = 0
  pGoingLeft = 0
  pGoingRight = 0
  pBraking = 0
  pFullRetro = 0
  sndCh = 6
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
  if aiAction = #waitingForAction then
    me.aiCheckAction()
    return 
  end if
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
  dist = pPlayer.worldPosition.distanceTo(pmodel.worldPosition)
  if dist > 50 then
    newstatus = #none
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
  if G.snd3D and sndStatus <> #none then
    vol = min(200 * (10 / dist), 200)
    sound(sndCh).volume = vol
    Dir = pmodel.worldPosition - pPlayer.worldPosition
    Dir.normalize()
    sound(sndCh).pan = -50 * Dir.dot(pCurrentRight)
  end if
end

on havok_callback me, cd
  if cd[2] contains "azz" then
    case aiStatus of
      #retro:
        me.aiChangeStatus(#Ok)
      #attack1, #attack2, #attack3:
        me.aiChangeStatus(#Ok)
        me.aiChangeAction(#followPlayer)
      #waiting:
        nothing()
      otherwise:
        me.aiChangeStatus(#retro)
    end case
  else
    if cd[2] contains "player" then
      if abs(human.pCurrentSpeed) < 15 and aiAction = #followPlayer then
        me.aiChangeStatus(#retro)
        pFullRetro = 1
      end if
    end if
  end if
end

on aiGoBackToGarage me
  aiGarage = 1
  pHavok.position = vector(-10, -10, 1)
  pHavok.rotation = [vector(0, 0, 1), 0]
  pHavok.linearVelocity = vector(0, 0, 0)
  pHavok.angularVelocity = vector(0, 0, 0)
  me.sndNextStatus(#none)
end

on aiChangeStatus me, newstatus
  if aiStatus <> newstatus then
    aiStatus = newstatus
    aiLastStatusChange = havok.simTime
    aiInitialLato = VOID
    pFullRetro = 0
  end if
end

on aiChangeAction me, newAction, pos
  aiAction = newAction
  aiPhase = 1
  aiLastActionChange = havok.simTime
  pHidden = VOID
  case aiAction of
    #followPlayer:
      aiLookAt.model = pPlayer
      aiLookAt.pos = pPlayer.worldPosition
    #followMarker:
      aiLookAt.model = VOID
      if not voidp(pos) then
        aiLookAt.pos = pos
      end if
  end case
end

on aiCheckAction me
  aiLastActionChange = havok.simTime
  case aiAction of
    #waitingForAction:
      case aiStatus of
        #agguato1:
          p = pmodel.worldPosition
          delta = min((pPlayer.worldPosition.x - p.x) / 5, 2.5)
          if pPlayer.worldPosition.y > -830 then
            pHavok.linearVelocity = vector(1, 0, 0) * delta / havok.timeStep
            me.aiChangeStatus(#Ok)
            me.aiChangeAction(#followPlayer)
          else
            if pPlayer.worldPosition.y > -880 then
              p.x = p.x + delta
              pHavok.position = p
            end if
          end if
        #waiting:
          if havok.simTime - aiLastStatusChange > aiWaitBeforeAttack and human.pCurrentSpeed > 20 then
            t = transform()
            t.rotation = pcamera.transform.rotation
            p = pcamera.worldPosition - t * vector(0, 0, -5)
            ground = world.modelsUnderRay(p, gDown, 1, #detailed)
            if ground.count = 1 then
              obj = ground[1].model.name
              if obj contains "strada" or obj contains "marciapiede" or obj contains "sterrato" then
                contact = ground[1].isectPosition
                if pHavok.attemptMoveTo(contact + vector(0, 0, 1), pPlayer.transform.axisAngle) then
                  pHavok.position = contact + vector(0, 0, 0.20000000000000001)
                  pHavok.linearVelocity = human.pHavok.linearVelocity
                  me.aiChangeStatus(#attack1)
                  me.aiChangeAction(#followMarker)
                  return 
                end if
              end if
            end if
            aiLastStatusChange = havok.simTime - (aiWaitBeforeAttack - 1)
          end if
      end case
    #followPlayer:
      if me.aiHidden(pmodel.worldPosition) then
        if voidp(pHidden) then
          pHidden = havok.simTime
        end if
        if havok.simTime - pHidden > aiWaitBeforeDisappear then
          me.aiChangeStatus(#waiting)
          me.aiChangeAction(#waitingForAction)
          me.aiGoBackToGarage()
        end if
      else
        pHidden = VOID
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
      if me.aiHidden(pmodel.worldPosition) then
        if voidp(pHidden) then
          pHidden = havok.simTime
        end if
        if havok.simTime - pHidden > aiWaitBeforeDisappear then
          me.aiChangeStatus(#waiting)
          me.aiChangeAction(#waitingForAction)
          me.aiGoBackToGarage()
        end if
      else
        pHidden = VOID
      end if
  end case
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
  case aiAction of
    #waitingForAction:
      pGoingForward = 0
      pGoingBackward = 0
      pBraking = 0
      pGoingRight = 0
      pGoingLeft = 0
      return 
    #followPlayer:
      aiLookAt.pos = pPlayer.worldPosition
      targetDir = (aiLookAt.pos - pmodel.worldPosition).getNormalized()
      lato = pCurrentRight.dot(targetDir)
      ang = targetDir.angleBetween(pCurrentFwd)
      if voidp(aiInitialLato) then
        aiInitialLato = sign(lato)
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
        #Ok:
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
              end if
            end if
          end if
      end case
    #followMarker:
      case aiStatus of
        #attack1:
          aiLookAt.model = pTargetSx
          targetDir = (pTargetSx.worldPosition - pmodel.worldPosition).getNormalized()
          lato = pCurrentRight.dot(targetDir)
          ang = targetDir.angleBetween(pCurrentFwd)
          targetDir = (pTargetDx.worldPosition - pmodel.worldPosition).getNormalized()
          lato2 = pCurrentRight.dot(targetDir)
          if abs(lato2) < abs(lato) then
            aiLookAt.model = pTargetDx
            lato = lato2
          end if
          hav = human.pHavok.angularVelocity
          t = transform()
          t.rotate(vector(0, 0, 0), hav, hav.magnitude)
          hz = t.rotation.z
          pav = pHavok.angularVelocity
          t = transform()
          t.rotate(vector(0, 0, 0), pav, pav.magnitude)
          t.rotation.z = hz
          hlv = human.pHavok.linearVelocity
          plv = pHavok.linearVelocity
          if abs(pCurrentFwd.x) > abs(pCurrentFwd.y) then
            plv.x = (plv.x + hlv.x) / 2
          else
            plv.y = (plv.y + hlv.y) / 2
          end if
          pHavok.linearVelocity = plv
          pHavok.angularVelocity = t.axisAngle[1] * t.axisAngle[2]
          pGoingForward = 1
          pGoingBackward = 0
          pBraking = 0
          pGoingRight = max(lato, 0)
          pGoingLeft = max(-lato, 0)
          if ang > 90 then
            me.aiChangeStatus(#attack2)
          end if
        #attack2:
          targetDir = (aiLookAt.model.worldPosition - pmodel.worldPosition).getNormalized()
          lato = pCurrentRight.dot(targetDir)
          ang = targetDir.angleBetween(pCurrentFwd)
          hav = human.pHavok.angularVelocity
          t = transform()
          t.rotate(vector(0, 0, 0), hav, hav.magnitude)
          hz = t.rotation.z
          pav = pHavok.angularVelocity
          t = transform()
          t.rotate(vector(0, 0, 0), pav, pav.magnitude)
          t.rotation.z = hz
          hlv = human.pHavok.linearVelocity
          plv = pHavok.linearVelocity
          if abs(pCurrentFwd.x) > abs(pCurrentFwd.y) then
            plv.x = (plv.x + hlv.x) / 2
          else
            plv.y = (plv.y + hlv.y) / 2
          end if
          pHavok.linearVelocity = plv
          pHavok.angularVelocity = t.axisAngle[1] * t.axisAngle[2]
          pGoingForward = 1
          pGoingBackward = 0
          pBraking = 0
          pGoingRight = max(lato, 0)
          pGoingLeft = max(-lato, 0)
          if ang > 120 then
            me.aiChangeStatus(#attack3)
          end if
        #attack3:
          targetDir = (aiLookAt.model.worldPosition - pmodel.worldPosition).getNormalized()
          lato = pCurrentRight.dot(targetDir)
          ang = targetDir.angleBetween(pCurrentFwd)
          hav = human.pHavok.angularVelocity
          t = transform()
          t.rotate(vector(0, 0, 0), hav, hav.magnitude)
          hz = t.rotation.z
          pav = pHavok.angularVelocity
          t = transform()
          t.rotate(vector(0, 0, 0), pav, pav.magnitude)
          t.rotation.z = hz
          hlv = human.pHavok.linearVelocity
          plv = pHavok.linearVelocity
          if abs(pCurrentFwd.x) > abs(pCurrentFwd.y) then
            plv.x = (plv.x + hlv.x) / 2
          else
            plv.y = (plv.y + hlv.y) / 2
          end if
          pHavok.linearVelocity = plv
          pHavok.angularVelocity = t.axisAngle[1] * t.axisAngle[2]
          pGoingForward = 0
          pGoingBackward = 0
          pBraking = 1
          pGoingRight = max(lato, 0)
          pGoingLeft = max(-lato, 0)
          if ang < 60 then
            me.aiChangeStatus(#attack2)
          end if
      end case
  end case
end
