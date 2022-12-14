-- Cast Lingo BehaviorScript Overlay.ls

property spriteNum, pSprite, world, pcamera, textureName, tex, powerOverlay, powerOverlayBase, energyOverlay, energyOverlayBase, powerCurrent, energyCurrent, powerPosY, energyPosY, powerMax, energyMax, powerRangeMin, powerRange, energyRangeMin, energyRange, powerBlink, powerBlinking, energyBlink, energyBlinking
global G

on beginSprite me
  pSprite = sprite(spriteNum)
  world = pSprite.member
  pcamera = world.camera("MainCamera")
  textureName = []
  tex = []
  repeat with i = 1 to G.overlayMember.count
    textureName[i] = "Overlay" & G.overlayMember[i]
    tex[i] = world.texture(textureName[i])
    if voidp(tex[i]) then
      tex[i] = world.newTexture(textureName[i], #fromCastMember, member(G.overlayMember[i]))
      tex[i].renderFormat = #rgba4444
    end if
  end repeat
  repeat with i = 1 to textureName.count
    if pcamera.overlay.count < i then
      pcamera.addOverlay(tex[i], G.overlayPosition[i], 0)
    else
      pcamera.overlay[i].source = tex[i]
      pcamera.overlay[i].loc = G.overlayPosition[i]
    end if
    pcamera.overlay[i].blend = 100
    pcamera.overlay[i].regPoint = member(G.overlayMember[i]).regPoint
    case G.overlayMember[i] of
      "PowerBar":
        powerOverlayBase = i
      "Power":
        powerOverlay = i
        powerPosY = G.overlayPosition[i][2]
        powerCurrent = G.overlayPosition[i][1]
        pcamera.overlay[i].blend = 100
      "EnergyBar":
        energyOverlayBase = i
      "Energy":
        energyOverlay = i
        energyPosY = G.overlayPosition[i][2]
        energyCurrent = G.overlayPosition[i][1]
        pcamera.overlay[i].blend = 100
    end case
  end repeat
  powerRangeMin = G.overlayPowerRange.min
  energyRangeMin = G.overlayEnergyRange.min
  powerRange = G.overlayPowerRange.max - G.overlayPowerRange.min
  energyRange = G.overlayEnergyRange.max - G.overlayEnergyRange.min
  powerMax = G.benzaMax
  energyMax = G.carrozzeriaMax
  powerBlink = integer(powerRangeMin + powerRange / 5)
  energyBlink = integer(energyRangeMin + energyRange / 5)
  powerBlinking = 0
  energyBlinking = 0
end

on exitFrame me
  newPower = integer(powerRangeMin + G.benza * powerRange / powerMax)
  newEnergy = integer(energyRangeMin + G.carrozzeria * energyRange / energyMax)
  if newPower <> powerCurrent then
    powerCurrent = powerCurrent + sign(newPower - powerCurrent)
    pcamera.overlay[powerOverlay].loc = point(powerCurrent, powerPosY)
  end if
  if newPower < powerBlink then
    pcamera.overlay[powerOverlayBase].blend = 100 - powerBlinking * 50
    powerBlinking = powerBlinking mod 3 + 1
  else
    if powerBlink <> 0 then
      pcamera.overlay[powerOverlayBase].blend = 100
      powerBlinking = 0
    end if
  end if
  if newEnergy <> energyCurrent then
    if newEnergy < energyCurrent then
      energyCurrent = energyCurrent - 1
    else
      energyCurrent = energyCurrent + max(integer((newEnergy - energyCurrent) / 2), 1)
    end if
    pcamera.overlay[energyOverlay].loc = point(energyCurrent, energyPosY)
  end if
  if newEnergy > energyBlink then
    pcamera.overlay[energyOverlayBase].blend = 100 - energyBlinking * 50
    energyBlinking = energyBlinking mod 3 + 1
  else
    if energyBlink <> 0 then
      pcamera.overlay[energyOverlayBase].blend = 100
      energyBlinking = 0
    end if
  end if
end
