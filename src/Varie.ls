-- Cast Lingo MovieScript Varie.ls

on sign x
  if x > 0 then
    return 1
  else
    if x < 0 then
      return -1
    else
      return 0
    end if
  end if
end

on rnd maxVal
  return random(maxVal * 100) mod maxVal + 1
end
