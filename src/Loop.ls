-- Cast Lingo BehaviorScript Loop.ls

global ffxExit

on beginSprite
  ffxExit = 1
end

on exitFrame
  go(the frame)
end
