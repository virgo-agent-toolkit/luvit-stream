local utils = require('utils')
local Readable = require('./stream_readable').Readable
local Writable = require('./stream_writable').Writable

local Duplex = Readable:extend()

for k,v in pairs(Writable) do
  if not Duplex[k] and k ~= 'meta' then
    Duplex[k] = v
  end
end

function Duplex:initialize(options)
  --[[
  if (!(this instanceof Duplex))
    return new Duplex(options);
  --]]

  Readable.initialize(self, options)
  Writable.initialize(self, options)

  if options and options.readable == false then
    self.readable = false
  end

  if options and options.writable == false then
    self.writable = false
  end

  self.allowHalfOpen = true
  if options and options.allowHalfOpen == false then
    self.allowHalfOpen = false
  end

  self:once('end', utils.bind(onend, self))
end

--[[
// the no-half-open enforcer
--]]
function onend(self)
  --[[
  // if we allow half-open state, or if the writable side ended,
  // then we're ok.
  --]]
  if self.allowHalfOpen or self._writableState.ended then
    return
  end

  --[[
  // no more data can be written.
  // But allow more writes to happen in this tick.
  --]]
  process.nextTick(utils.bind(self._end, self))
end

local exports = {}

exports.Duplex = Duplex

return exports
