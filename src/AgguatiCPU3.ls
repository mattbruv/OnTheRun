-- Cast Lingo BehaviorScript AgguatiCPU3.ls

property gForward, gUp, gDown, pMaxSpeed, pminspeed, pAccGain, pDecGain, pBrakeGain, pTurnGain, pReTurnGain, pGrip, pDrag, pMaxHeight, pRadarHeight, spriteNum, pSprite, world, pmodel, pPlayer, pTargetDx, pTargetSx, pShadow, pcamera, pHavok, aiStatus, aiLastStatusChange, aiInitialLato, aiAction, aiPhase, aiLastActionChange, aiLastAgguato, aiRunningAwayTarget, aiWaitBeforeDisappear, aiLookAt, aiGarage, pHidden, pGoingForward, pGoingBackward, pGoingLeft, pGoingRight, pBraking, pMass, pheight, pObjectUnder, pMainDirector, pContact, pNormal, pCurrentSpeed, pSlideSpeed, pFallSpeed, pAngularVel, pSphere, pCurrentFwd, pCurrentAxis, pCurrentRight, pFullRetro, sndCh, sndList, sndStatus, sndWait
global G, havok, human, CPU3, trail

on beginSprite me
  CPU3 = me
  gForward = G.forward
  gUp = G.up
  gDown = -G.up
  pSprite = sprite(me.spriteNum)
  world = pSprite.member
  pmodel = world.model("JeepCPU02")
  pPlayer = world.model("AutoPlayer")
  pcamera = world.camera("MainCamera")
  pHavok = havok.rigidBody(pmodel.name)
  pMass = pHavok.mass
  pSphere = pmodel.boundingSphere[2]
  pShadow = new(script("shadow"), pmodel, "ombracpu", gUp, G.shadowHeight)
  pMaxSpeed = 170.0
  pAccGain = 0.06 * pMass
  pDecGain = 0.06 * pMass
  pBrakeGain = 0.10000000000000001 * pMass
  pTurnGain = 0.59999999999999998 * pMass
  pReTurnGain = pTurnGain
  pGrip = 0.29999999999999999
  pDrag = 0.02 * pMass
  pMaxHeight = 1
  pRadarHeight = vector(0, 0, 3)
  aiWaitBeforeDisappear = 4
  aiLookAt = [#pos: vector(0, 0, 0), #model: VOID]
  me.aiGoTo(1)
  pmodel.transform.position = pHavok.position
  pShadow.updateShadow(pHavok.position, vector(0, 0, 1))
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
    if aiStatus <> #waiting then
      me.aiCheckAction()
    else
      if havok.simTime - aiLastActionChange > 1 then
        me.aiCheckAction()
      end if
      return 
    end if
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
      #waiting:
        nothing()
      otherwise:
        me.aiChangeStatus(#retro)
    end case
  else
    if cd[2] contains "player" then
      if aiAction = #waitingForAction then
        me.aiChangeStatus(#Ok)
        me.aiChangeAction(#followPlayer)
      else
        if abs(human.pCurrentSpeed) < 15 then
          me.aiChangeStatus(#retro)
          pFullRetro = 1
        end if
      end if
    end if
  end if
end

on aiGoBackToGarage me
  aiGarage = 1
  pHavok.position = vector(10, 10, 1)
  pHavok.rotation = [vector(0, 0, 1), 0]
  pHavok.linearVelocity = vector(0, 0, 0)
  pHavok.angularVelocity = vector(0, 0, 0)
  me.sndNextStatus(#none)
end

on aiGoTo me, agguato_num
  aiLastAgguato = agguato_num
  aiGarage = 0
  case agguato_num of
    1:
      pHavok.position = vector(-496, -797, 0.5)
      pHavok.rotation = [vector(0, 0, 1), 90]
      aiRunningAwayTarget = vector(-443, -889, 0.5)
      me.aiChangeStatus(#agguato1)
    2:
      pHavok.position = vector(-479.5, -1100, 0.5)
      pHavok.rotation = [vector(0, 0, 1), 270]
      aiRunningAwayTarget = vector(-479, -1197, 0.5)
      me.aiChangeStatus(#inPiazza)
    3:
      pHavok.position = vector(-446, -1295, 0.5)
      pHavok.rotation = [vector(0, 0, 1), 270]
      aiRunningAwayTarget = vector(-479, -1197, 0.5)
      me.aiChangeStatus(#vicoloCieco)
    4:
      pHavok.position = vector(34, -1162, 0.5)
      pHavok.rotation = [vector(0, 0, 1), 270]
      aiRunningAwayTarget = vector(34, -1162, 0.5)
      me.aiChangeStatus(#tunnel2)
    5:
      pHavok.position = vector(-380, -1210, -14)
      pHavok.rotation = [vector(0, 0, 1), 180]
      aiRunningAwayTarget = vector(-380, -1210, -14)
      me.aiChangeStatus(#tunnel1)
    6:
      pHavok.position = vector(350, -1280, 0.5)
      pHavok.rotation = [vector(0, 0, 1), 180]
      aiRunningAwayTarget = vector(100, -1280, 5)
      me.aiChangeStatus(#agguato2)
    7:
      pHavok.position = vector(305, -1390, 0.5)
      pHavok.rotation = [vector(0, 0, 1), 30]
      aiRunningAwayTarget = vector(305, -1390, 5)
      me.aiChangeStatus(#parcheggio)
    8:
      pHavok.position = vector(705, -561, -14)
      pHavok.rotation = [vector(0, 0, 1), 270]
      aiRunningAwayTarget = vector(705, -561, -14)
      me.aiChangeStatus(#canalone)
    9:
      pHavok.position = vector(770, 79, 0.5)
      pHavok.rotation = [vector(0, 0, 1), 90]
      aiRunningAwayTarget = vector(940, 176, 0.5)
      me.aiChangeStatus(#finale)
  end case
  me.aiChangeAction(#waitingForAction)
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
    #runningAway:
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
      pwp = pPlayer.worldPosition
      case aiStatus of
        #agguato1:
          p = pmodel.worldPosition
          delta = min((pwp.y - p.y) / 5, 2.5)
          if pwp.x < -490 or pwp.x < -440 and pwp.y > -750 then
            pHavok.linearVelocity = vector(0, 1, 0) * delta / havok.timeStep
            me.aiChangeStatus(#Ok)
            me.aiChangeAction(#followPlayer)
          else
            if pwp.x < -460 then
              p.y = p.y + delta
              pHavok.position = p
            else
              if pwp.x < -440 and pwp.y < -900 then
                me.aiChangeStatus(#waiting)
                me.aiChangeAction(#waitingForAction)
                me.aiGoBackToGarage()
              end if
            end if
          end if
        #inPiazza:
          if pwp.x > -543 and pwp.x < -393 and pwp.y < -1107 and pwp.y > -1200 then
            if not me.aiHidden(pmodel.worldPosition) then
              me.aiChangeStatus(#Ok)
              me.aiChangeAction(#followPlayer)
            end if
          end if
          if pwp.z > 0 and pwp.y < -1345 and pwp.x > -460 and pwp.x < -430 then
            me.aiGoTo(3)
          end if
        #vicoloCieco:
          if pwp.y > -1340 then
            me.aiChangeStatus(#Ok)
            me.aiChangeAction(#followPlayer)
          end if
        #tunnel2:
          if pwp.x > 25 then
            me.aiChangeStatus(#Ok)
            me.aiChangeAction(#followPlayer)
          end if
        #tunnel1:
          if pwp.y < -1100 then
            me.aiChangeStatus(#Ok)
            me.aiChangeAction(#followPlayer)
          end if
        #agguato2:
          if pwp.x > 100 then
            me.aiChangeStatus(#Ok)
            me.aiChangeAction(#followPlayer)
          end if
        #parcheggio:
          if pwp.y < -1380 then
            me.aiChangeStatus(#Ok)
            me.aiChangeAction(#followPlayer)
          end if
        #canalone:
          if pwp.y > -1700 then
            me.aiChangeStatus(#Ok)
            me.aiChangeAction(#followPlayer)
          end if
        #finale:
          if pwp.y > 75 then
            me.aiChangeStatus(#Ok)
            me.aiChangeAction(#followPlayer)
          end if
        #waiting:
          if not aiGarage then
            if me.aiHidden(pmodel.worldPosition) then
              if voidp(pHidden) then
                pHidden = havok.simTime
              end if
              if havok.simTime - pHidden > aiWaitBeforeDisappear then
                me.goBackToGarage()
              else
                pHidden = VOID
              end if
            end if
          end if
          case aiLastAgguato of
            1:
              if pwp.y < -1000 then
                me.aiGoTo(2)
              end if
            2, 3:
              if pwp.y < -1000 then
                me.aiGoTo(4)
              end if
            4:
              if pwp.z < -10 then
                me.aiGoTo(5)
              end if
            5, 6, 7, 8:
              me.aiGoTo(aiLastAgguato + 1)
          end case
      end case
    #followPlayer:
      pwp = pPlayer.worldPosition
      goaway = 0
      case aiLastAgguato of
        1:
          if pwp.y < -885 then
            goaway = 1
          end if
        2, 3:
          if pwp.y > -1070 and pwp.x < -465 then
            goaway = 1
          end if
        4:
          if pwp.x > -140 and pwp.y > -1000 then
            goaway = 1
          end if
        5:
          if pwp.z > -1 then
            goaway = 1
          end if
        6:
          if pwp.y < -1360 then
            goaway = 1
          end if
        7:
          if pwp.x > 670 then
            goaway = 1
          end if
        8:
          if pwp.y > 0 then
            goaway = 1
          end if
        9:
          nothing()
      end case
      if goaway then
        me.aiChangeAction(#runningAway, aiRunningAwayTarget)
        return 
      end if
      if me.aiHidden(pmodel.worldPosition) then
        if voidp(pHidden) then
          pHidden = havok.simTime
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
    #runningAway:
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
      pBraking = 1
      pGoingRight = 0
      pGoingLeft = 0
      return 
    #followPlayer:
      aiLookAt.pos = pPlayer.worldPosition
      targetDir = (aiLookAt.pos - pmodel.worldPosition).getNormalized()
      lato = pCurrentRight.dot(targetDir)
      ang = targetDir.angleBetween(pCurrentFwd)
      ang2 = pHavok.linearVelocity.angleBetween(human.pHavok.linearVelocity)
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
            if ang2 > 90 then
              pGoingRight = max(lato, 0) * 10
              pGoingLeft = max(-lato, 0) * 10
            else
              pGoingRight = max(lato, 0)
              pGoingLeft = max(-lato, 0)
            end if
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
    #runningAway:
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
          if havok.simTime - aiLastStatusChange < 1 then
            pGoingBackward = 1
            if not voidp(aiLookAt.pos) then
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
  end case
end
