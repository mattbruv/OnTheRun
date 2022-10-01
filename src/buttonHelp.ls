-- Cast Internal BehaviorScript buttonHelp.ls

on beginSprite me
  sprite(me.spriteNum).cursor = [member("pugnoCursor").number, member("pugnoMask").number]
end

on mouseUp me
  go(label("help"))
end
