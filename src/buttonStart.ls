-- Cast Internal BehaviorScript buttonStart.ls

on beginSprite me
  sprite(me.spriteNum).cursor = [member("pugnoCursor").number, member("pugnoMask").number]
end

on mouseUp me
  go(the frame + 1)
end
