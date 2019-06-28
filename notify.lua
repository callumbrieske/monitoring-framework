json = require("rapidjson")

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
    
    local function registerControl(table, ctl)
      local params = {"Value", "String", "Color", "Legend"}
      for i, v in ipairs(params) do
        _NOTIFY._DIRTY = table[v] ~= ctl[v] or _NOTIFY._DIRTY
        table[v] = ctl[v]
      end
    end
    
    for ctlName, ctl in pairs(Controls) do
      if type(ctl) == "table" then
        if type(_NOTIFY._CONTROLDATA[ctlName]) ~= "table" then _NOTIFY._CONTROLDATA[ctlName] = {} end
        for ctlIndex, ctlM in ipairs(ctl) do
          if type(_NOTIFY._CONTROLDATA[ctlName][ctlIndex]) ~= "table" then _NOTIFY._CONTROLDATA[ctlName][ctlIndex] = {} end
          registerControl(_NOTIFY._CONTROLDATA[ctlName][ctlIndex], ctlM)
        end
      else
        if type(_NOTIFY._CONTROLDATA[ctlName]) ~= "table" then _NOTIFY._CONTROLDATA[ctlName] = {} end
        registerControl(_NOTIFY._CONTROLDATA[ctlName], ctl)
      end
    end
    
    if _NOTIFY._DIRTY or _NOTIFY._COUNTSINCEUPDATE >= 10 then
      print(json.encode(_NOTIFY._CONTROLDATA))
      
      _NOTIFY._COUNTSINCEUPDATE = 0
    end
    
    _NOTIFY._COUNTSINCEUPDATE = _NOTIFY._COUNTSINCEUPDATE + 1
    _NOTIFY._DIRTY = false
    _NOTIFY._TIMER:Start(1)
  end,
  
  _BEGIN = function(self)
    self._TIMER.EventHandler = self._RUN
    math.randomseed(os.clock())
    self._TIMER:Start(math.random(1))
  end,
  
}

_NOTIFY:_BEGIN()
