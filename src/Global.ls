-- Cast Lingo MovieScript Global.ls

global G

on G p, v
  if stringp(p) then
    p = symbol(p)
  end if
  if not ilk(G, #propList) then
    G = [:]
    sort(G)
  end if
  if the paramCount = 2 then
    old_value = getaProp(G, p)
    if voidp(v) then
      deleteProp(G, p)
    else
      setaProp(G, p, v)
    end if
    return old_value
  else
    return getaProp(G, p)
  end if
end

on gLoad lf
  if voidp(lf) then
    lf = member("*GLOBALS")
  else
    if stringp(lf) then
      lf = member(lf)
    end if
  end if
  if not ilk(G, #propList) then
    G = [:]
    sort(G)
  end if
  oldDelimiter = the itemDelimiter
  the itemDelimiter = "="
  i = 0
  p = VOID
  Overwrite = 1
  v = EMPTY
  tot = the number of lines in the text of lf
  repeat with i = 1 to tot
    L = line i of the text of lf
    if chars(strLTrim(L), 1, 2) = "--" then
      next repeat
    end if
    if isEmpty(L) then
      if not voidp(p) then
        update_prop(Overwrite, p, v, lf, i)
        p = VOID
      end if
      next repeat
    end if
    if voidp(p) then
      p = item 1 of L
      v = item 2 of L
      if word 1 of p = "static" then
        p = symbol(word 2 of p)
        Overwrite = 0
      else
        p = symbol(p)
        Overwrite = 1
      end if
      if not isEmpty(v) then
        update_prop(Overwrite, p, v, lf, i)
        p = VOID
      end if
      next repeat
    end if
    put L after v
  end repeat
  if not voidp(p) then
    update_prop(Overwrite, p, v, lf, i)
    p = VOID
  end if
  the itemDelimiter = oldDelimiter
end

on gUnLoad lf
  if voidp(lf) then
    lf = member("*GLOBALS")
  else
    if stringp(lf) then
      lf = member(lf)
    end if
  end if
  if not ilk(G, #propList) then
    return 
  end if
  oldDelimiter = the itemDelimiter
  the itemDelimiter = "="
  i = 0
  p = VOID
  toBeDeleted = 1
  v = EMPTY
  tot = the number of lines in the text of lf
  repeat with i = 1 to tot
    L = line i of the text of lf
    if chars(strLTrim(L), 1, 2) = "--" then
      next repeat
    end if
    if isEmpty(L) then
      if not voidp(p) then
        if toBeDeleted then
          deleteProp(G, p)
        end if
        p = VOID
      end if
      next repeat
    end if
    if voidp(p) then
      p = item 1 of L
      v = item 2 of L
      if word 1 of p = "static" then
        p = symbol(word 2 of p)
        toBeDeleted = 0
      else
        p = symbol(p)
        toBeDeleted = 1
      end if
      if not isEmpty(v) then
        if toBeDeleted then
          deleteProp(G, p)
        end if
        p = VOID
      end if
    end if
  end repeat
  if not voidp(p) then
    if toBeDeleted then
      deleteProp(G, p)
    end if
    p = VOID
  end if
  the itemDelimiter = oldDelimiter
end

on gUpdate prop, newvalue, lf
  if voidp(lf) then
    lf = member("*GLOBALS")
  else
    if stringp(lf) then
      lf = member(lf)
    end if
  end if
  if stringp(prop) then
    prop = symbol(prop)
  end if
  oldDelimiter = the itemDelimiter
  the itemDelimiter = "="
  i = 0
  p = VOID
  v = EMPTY
  tot = the number of lines in the text of lf
  response = "Globale non trovata nel field " & lf.name
  repeat with i = 1 to tot
    L = line i of the text of lf
    if chars(strLTrim(L), 1, 2) = "--" then
      next repeat
    end if
    if isEmpty(L) then
      p = VOID
      next repeat
    end if
    if voidp(p) then
      p = item 1 of L
      v = item 2 of L
      if word 1 of p = "static" then
        p = symbol(word 2 of p)
      else
        p = symbol(p)
      end if
      if p = prop then
        if isEmpty(v) then
          response = "Non e' possibile aggiornare automaticamente globali multi-linea"
          exit repeat
        end if
        delete item 2 of line i of field lf
        put adjust_newvalue(newvalue) after item 2 of line i of field lf
        response = VOID
        exit repeat
        next repeat
      end if
      if not isEmpty(v) then
        p = VOID
      end if
    end if
  end repeat
  the itemDelimiter = oldDelimiter
  if not voidp(response) then
    Assert(1, "gUpdate(" & prop & ")", response)
  end if
end

on gAppend prop, newvalue, lf
  if voidp(lf) then
    lf = member("*GLOBALS")
  else
    if stringp(lf) then
      lf = member(lf)
    end if
  end if
  put string(prop) & "=" & adjust_newvalue(newvalue) & RETURN after field lf
end

on update_prop Overwrite, p, v, lf, i
  if Overwrite or voidp(findPos(G, p)) then
    result = value(v)
    if voidp(result) then
      Assert(voidp(result) and strTrim(v) <> "VOID", "gLoad(" & lf & ")", "Suspect VOID result for #" & p & " at line " & i)
    end if
    setaProp(G, p, result)
  end if
end

on adjust_newvalue newvalue
  if listp(newvalue) then
    return strReplace(string(newvalue), "<Void>", "VOID")
  else
    if stringp(newvalue) then
      return QUOTE & newvalue & QUOTE
    else
      return string(newvalue)
    end if
  end if
end
