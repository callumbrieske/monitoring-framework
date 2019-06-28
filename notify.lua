_NOTIFY = {

  _STARTUPBUFFER = {},
  
  _CONTROLDATA = {},
  
  _DIRTY = true,
  
  _COUNTSINCEUPDATE = 0,
  
  _TIMER = Timer.New(),
  
  _SEND = function(self, channel, data)
    table.insert(self._STARTUPBUFFER, {channel = channel, data = data})
  end,
  
  _RUN = function()
    _NOTIFY._SEND = function(_, channel, data) Notifications.Publish(channel, data) end -- Update send function.
    _NOTIFY._TIMER.EventHandler = _NOTIFY._UPDATE  -- Pass eventhandler to Update.
    for _, v in ipairs(_NOTIFY._STARTUPBUFFER) do  -- Clear the buffer.
      _NOTIFY:_SEND(v.channel, v.data)
    end
    _NOTIFY._STARTUPBUFFER = nil  -- Destroy temporary queue.
  end,
  
  _UPDATE = function(self)
    -- Update the remote controls.
    if _NOTIFY._DIRTY or _NOTIFY._COUNTSINCEUPDATE >= 10 then
      print("Tick")
      
      _NOTIFY._COUNTSINCEUPDATE = 0
    end
    
    _NOTIFY._COUNTSINCEUPDATE = _NOTIFY._COUNTSINCEUPDATE + 1
    _NOTIFY._DIRTY = false
  end,
  
  _BEGIN = function(self)
    self._TIMER.EventHandler = self._RUN
    self._TIMER:Start(1)
  end,
  
}

_NOTIFY:_BEGIN()
