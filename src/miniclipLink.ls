-- Cast Internal BehaviorScript miniclipLink.ls

on beginSprite me
  sprite(me.spriteNum).cursor = [member("pugnoCursor").number, member("pugnoMask").number]
end

on mouseUp me
  gotoNetPage("http://www.miniclip.com", "_new")
end
