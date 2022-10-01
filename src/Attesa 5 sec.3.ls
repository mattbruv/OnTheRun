-- Cast Lingo BehaviorScript Attesa 5 sec.3.ls

property attesa
global G, human

on beginSprite me
  attesa = VOID
end

on exitFrame
  if voidp(attesa) then
    attesa = the milliSeconds + 5000
    human.pShadow.hideShadow()
    go(the frame)
  else
    if the milliSeconds < attesa then
      human.pShader.blend = max(0, (attesa - 3500 - the milliSeconds) * 100 / 1500)
      human.pShaderStop.blend = max(0, (attesa - 3500 - the milliSeconds) * 100 / 1500)
      go(the frame)
    else
      human.pShader.blend = 100
      human.pShaderStop.blend = 100
      human.pShadow.showShadow()
      G.Run = 0
      go("TH3")
    end if
  end if
end
