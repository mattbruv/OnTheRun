-- Cast Lingo BehaviorScript Attesa 5 sec.1.ls

property attesa
global G

on beginSprite me
  attesa = VOID
end

on exitFrame
  if voidp(attesa) then
    attesa = the milliSeconds + 5000
    go(the frame)
  else
    if the milliSeconds < attesa then
      go(the frame)
    else
      G.Run = 0
      go("TH1")
    end if
  end if
end
