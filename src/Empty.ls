-- Cast Lingo BehaviorScript Empty.ls

property spriteNum

on beginSprite me
  sprite(spriteNum).member.text = EMPTY
end

on getBehaviorDescription
  return "Empty" & RETURN & "á Description:" & RETURN & my_description(EMPTY)
end

on getBehaviorTooltip me
  return my_description(RETURN)
end

on my_description crlf
  return "Inizializza con una stringa nulla il testo durante il beginSprite."
end
