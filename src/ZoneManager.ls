-- Cast Lingo MovieScript ZoneManager.ls

global world, human, G

on zoneManager pType, pDelta, pTime, pDuration, pSystemTime
  if G.Run then
    if not soundBusy(4) then
      G.soundTrack = G.soundTrack mod G.soundTrackList.count + 1
    end if
  end if
  if not voidp(human) then
    if human.pObjectUnder contains "zona" then
      n = the number of chars in the pObjectUnder of human
      newZ = value(chars(human.pObjectUnder, n - 1, n))
      if newZ <> G.currentZone then
        zoneChange(newZ)
      end if
    end if
  end if
end

on zoneChange newZ
  G.currentZone = newZ
  zona = G.zone01[newZ]
  repeat with z = 1 to G.zoneNumber
    if zona[z] then
      if not G.zone[z].isInWorld() then
        G.zone[z].addToWorld()
      end if
      next repeat
    end if
    if G.zone[z].isInWorld() then
      G.zone[z].removeFromWorld()
    end if
  end repeat
end
