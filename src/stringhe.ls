-- Cast Lingo MovieScript stringhe.ls

on strToken s, n, sep
  oldDel = the itemDelimiter
  the itemDelimiter = sep
  retval = item n of s
  the itemDelimiter = oldDel
  return retval
end

on strRemoveSpaces s
  if voidp(s) then
    return EMPTY
  else
    fine = 0
    repeat while not fine
      blankPos = offset(" ", s)
      if blankPos > 0 then
        delete char blankPos of s
        next repeat
      end if
      fine = 1
    end repeat
    fine = 0
    repeat while not fine
      blankPos = offset(TAB, s)
      if blankPos > 0 then
        delete char blankPos of s
        next repeat
      end if
      fine = 1
    end repeat
    return s
  end if
end

on strLTrim s
  repeat while 1
    if char 1 of s = " " or char 1 of s = TAB then
      delete char 1 of s
      next repeat
    end if
    exit repeat
  end repeat
  return s
end

on strRTrim s
  repeat while 1
    if length(s) = 0 then
      exit repeat
    end if
    if char length(s) of s = " " or char length(s) of s = TAB then
      delete char length(s) of s
      next repeat
    end if
    exit repeat
  end repeat
  return s
end

on strTrim s
  return strRTrim(strLTrim(s))
end

on strRemoveBlankLines s
  i = 1
  repeat while i <= the number of lines in s
    if s = EMPTY then
      exit repeat
    end if
    if strRemoveSpaces(line i of s) = EMPTY then
      delete line i of s
      next repeat
    end if
    i = i + 1
  end repeat
  return s
end

on strLTrimLines s
  repeat while 1
    if strRemoveSpaces(line 1 of s) = EMPTY then
      delete line 1 of s
      if s = EMPTY then
        exit repeat
      end if
      next repeat
    end if
    exit repeat
  end repeat
  return s
end

on strRTrimLines s
  repeat while 1
    if strRemoveSpaces(the last line in s) = EMPTY then
      delete char -30003 of s
      if s = EMPTY then
        exit repeat
      end if
      next repeat
    end if
    exit repeat
  end repeat
  return s
end

on strTrimLines s
  return strRTrimLines(strLTrimLines(s))
end
