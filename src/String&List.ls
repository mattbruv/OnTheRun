-- Cast Lingo MovieScript String&List.ls

on getWordList what
  i = 1
  what_list = []
  repeat while word i of what <> EMPTY
    append(what_list, word i of what)
    i = i + 1
  end repeat
  return what_list
end

on getItemList what, delimiter
  if not stringp(what) then
    return []
  end if
  if not stringp(delimiter) then
    delimiter = ","
  end if
  what_list = []
  oldDelimiter = the itemDelimiter
  the itemDelimiter = delimiter
  repeat with i = 1 to the number of items in what
    append(what_list, strTrim(item i of what))
  end repeat
  the itemDelimiter = oldDelimiter
  return what_list
end

on isEmpty what
  blanks = " " & TAB
  n = the number of chars in what
  repeat with i = 1 to n
    if not (blanks contains char i of what) then
      return 0
    end if
  end repeat
  return 1
end

on strReplace input, Search, replace
  if not stringp(Search) then
    Search = string(Search)
  end if
  if not stringp(replace) then
    replace = string(replace)
  end if
  output = EMPTY
  findLen = length(Search) - 1
  repeat while input contains Search
    currOffset = offset(Search, input)
    output = output & char 1 to currOffset of input
    delete char -30000 of output
    output = output & replace
    delete char 1 to currOffset + findLen of input
  end repeat
  output = output & input
  return output
end

on printf input, listOfString
  stringToFind = "%s"
  output = EMPTY
  findLen = length(stringToFind) - 1
  n = 1
  repeat while input contains stringToFind
    currOffset = offset(stringToFind, input)
    output = output & char 1 to currOffset of input
    delete char -30000 of output
    output = output & string(listOfString[n])
    delete char 1 to currOffset + findLen of input
    n = n + 1
  end repeat
  output = output & input
  return output
end

on sprintf mem, input, listOfString
  mem.text = printf(input, listOfString)
end

on numToStr n, sep, big, signed
  if voidp(sep) then
    sep = "'"
  end if
  if voidp(big) then
    big = 0
  end if
  if voidp(signed) then
    signed = 0
  end if
  if n < 0 then
    retval = "-"
    n = abs(n)
  else
    if signed then
      retval = "+"
    else
      retval = EMPTY
    end if
  end if
  if n <= 9 and big <= 3 then
    if big > 2 then
      return retval & "00" & string(n)
    else
      if big > 1 then
        return retval & "0" & string(n)
      else
        return retval & string(n)
      end if
    end if
  else
    if n <= 99 and big <= 3 then
      if big > 2 then
        return retval & "0" & string(n)
      else
        return retval & string(n)
      end if
    else
      if n <= 999 and big <= 3 then
        return retval & string(n)
      else
        return retval & numToStr(n / 1000, sep, big - 3) & sep & n mod 1000 / 100 & n mod 100 / 10 & n mod 10
      end if
    end if
  end if
end

on numToTime n
  m = n / 600
  s = n mod 600 / 10
  d = n mod 10
  if m < 10 then
    m = "0" & m
  else
    m = string(m)
  end if
  if s < 10 then
    s = "0" & s
  else
    s = string(s)
  end if
  return m & ":" & s & "." & d
end

on strNoWrapText nome, lim
  n = length(nome)
  if n > lim then
    return chars(nome, 1, lim) & RETURN & strNoWrapText(chars(nome, lim + 1, length(nome)), lim)
  end if
  return nome
end

on strLimitLongName nome, lim
  n = length(nome)
  if n > lim then
    lim = lim / 2
    return chars(nome, 1, lim - 3) & "..." & chars(nome, length(nome) - lim + 1, length(nome))
  end if
  return nome
end
