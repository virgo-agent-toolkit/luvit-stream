--[[
--Observable is a stream that can be observed outside the pipeline. observe()
--returns a new Readable stream that emits all data that passes through this
--stream. Streams created by observe() do not affect back-pressure.
--]]

local table = require('table')

local Transform = require('./stream_transform').Transform
local Readable = require('./stream_readable').Readable

local Observable = Transform:extend()

function Observable:initialize(options)
  --[[
  if (!(this instanceof PassThrough))
    return new PassThrough(options)
  --]]

  Transform.initialize(self, options)

  self.options = options
  self.observers = {}
end

function Observable:_transform(chunk, encoding, cb)
  for k,v in pairs(self.observers) do
    v:push(chunk, encoding)
  end
  cb(nil, chunk)
end

function Observable:observe()
  local _self = self
  local obs = Readable:new(self.options)
  obs._read = function() end
  table.insert(self.observers, obs)
  return obs
end

local exports = {}

exports.Observable = Observable

return exports
