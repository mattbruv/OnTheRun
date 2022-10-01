-- Cast Internal BehaviorScript pixelLink.ls

on beginSprite me
  sprite(me.spriteNum).cursor = [member("pugnoCursor").number, member("pugnoMask").number]
end

on mouseUp me
  gotoNetPage("http://www.officinepixel.com", "_new")
end
