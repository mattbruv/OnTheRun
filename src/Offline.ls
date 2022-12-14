-- Cast Lingo MovieScript Offline.ls

global world

on finalize
  spPower = VOID
  spEnergy = VOID
  go("Overlay1")
  lm = []
  lp = []
  repeat with i = 1 to 4
    lm[i] = sprite(i).member.name
    lp[i] = sprite(i).loc
    if lm[i] = "Power" then
      spPower = i
    end if
    if lm[i] = "Energy" then
      spEnergy = i
    end if
  end repeat
  gUpdate(#overlayMember, lm)
  gUpdate(#overlayPosition, lp)
  power1 = sprite(spPower).locH
  energy1 = sprite(spEnergy).locH
  go("Overlay2")
  power2 = sprite(spPower).locH
  energy2 = sprite(spEnergy).locH
  gUpdate(#overlayPowerRange, [#min: power2, #max: power1])
  gUpdate(#overlayEnergyRange, [#min: energy2, #max: energy1])
  world.resetWorld()
  put "Done."
end
