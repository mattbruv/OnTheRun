-- Cast Lingo ParentScript Tween.ls

property period, type, R, FromX, ToX, x, FromY, ToY, y, KX, KY, K1X, K2X, K1Y, K2Y, Cycle, Hard, start, t, pause_time, mode

on new me
  TweenReset(me)
  return me
end

on TweenStart me, fromXY, toXY, time_t, tween_type, param1
  if voidp(tween_type) then
    tween_type = #cubic
  end if
  if tween_type = #spring and voidp(param1) then
    param1 = 3
  end if
  L = [:]
  if time_t > 0 then
    mode = #time
  else
    if time_t < 0 then
      mode = #step
    else
      TweenReset(me)
      exit
    end if
  end if
  period = abs(time_t)
  type = tween_type
  pause_time = VOID
  if ilk(fromXY, #point) and ilk(toXY, #point) then
    R = 2
    FromX = fromXY.locH
    ToX = toXY.locH
    FromY = fromXY.locV
    ToY = toXY.locV
    case type of
      #linear:
        KX = float(ToX - FromX) / period
        KY = float(ToY - FromY) / period
      #cubic:
        KX = float(12 * (ToX - FromX)) / power(period, 3)
        K1X = float(period * KX) / 4
        K2X = -KX / 6
        KY = float(12 * (ToY - FromY)) / power(period, 3)
        K1Y = float(period * KY) / 4
        K2Y = -KY / 6
      #spring:
        KX = float(12 * (ToX - FromX)) / power(period, 3)
        K1X = float(period * KX) / 4
        K2X = -KX / 6
        KY = float(12 * (ToY - FromY)) / power(period, 3)
        K1Y = float(period * KY) / 4
        K2Y = -KY / 6
        Cycle = float(PI / 2 + 4 * PI) / period
        Hard = param1
    end case
  else
    R = 1
    FromX = fromXY
    ToX = toXY
    case type of
      #linear:
        KX = float(ToX - FromX) / period
      #cubic:
        k = float(12 * (ToX - FromX)) / power(period, 3)
        K1X = float(period * k) / 4
        K2X = -k / 6
      #spring:
        k = float(12 * (ToX - FromX)) / power(period, 3)
        K1X = float(period * k) / 4
        K2X = -k / 6
        Cycle = float(PI / 2 + 4 * PI) / period
        Hard = param1
    end case
  end if
  x = FromX
  y = FromY
  start = the milliSeconds
  t = 0
end

on TweenUpdate me
  if voidp(type) then
    return 0
  end if
  if voidp(pause_time) then
    if mode = #time then
      t = min(the milliSeconds - start, period)
    else
      t = min(t + 1, period)
    end if
    if t = period then
      x = ToX
      y = ToY
      type = VOID
    else
      case type of
        #linear:
          x = FromX + KX * t
          if R = 2 then
            y = FromY + KY * t
          end if
        #cubic:
          x = (K1X + K2X * t) * t * t + FromX
          if R = 2 then
            y = (K1Y + K2Y * t) * t * t + FromY
          end if
        #spring:
          t = period - t
          coef = t * t * sin(t * Cycle) * power(float(t) / period, Hard)
          x = ToX - (K1X + K2X * t) * coef
          if R = 2 then
            y = ToY - (K1Y + K2Y * t) * coef
          end if
      end case
    end if
  end if
  return 1
end

on TweenGet me
  case R of
    1:
      return x
    2:
      return point(x, y)
  end case
end

on TweenPercentage me
  return float(t) / period * 100.0
end

on TweenPause me, onoff
  if onoff then
    if voidp(pause_time) then
      pause_time = the milliSeconds
    end if
  else
    if not voidp(pause_time) then
      start = start + the milliSeconds - pause_time
      pause_time = VOID
    end if
  end if
end

on TweenStop me
  t = period
  x = ToX
  y = ToY
  type = VOID
end

on TweenReset me
  type = VOID
  R = 1
  x = 0
  y = 0
  start = 0
  t = 0
  period = 1
  pause_time = VOID
end
