-- Cast Lingo BehaviorScript enterHighScores.ls

on beginSprite me
  sprite(me.spriteNum).cursor = [member("pugnoCursor").number, member("pugnoMask").number]
end

on endSprite me
  sprite(me.spriteNum).cursor = -1
end

on mouseUp me
  go(the frame + 1)
end

on mouseEnter me
  sprite(me.spriteNum - 1).ink = 3
end

on mouseLeave me
  sprite(me.spriteNum - 1).ink = 1
end
