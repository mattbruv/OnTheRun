-- Cast Lingo BehaviorScript 6.ls

on beginSprite me
  repeat with n = 1 to 100
    sprite(n).cursor = -1
  end repeat
end

on exitFrame me
  go(the frame)
end
