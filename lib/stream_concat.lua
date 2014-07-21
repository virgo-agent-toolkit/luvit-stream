local Writable = require('./stream_writable').Writable

local Concat = Writable:extend()
function Concat:initialize()
  Writable.initialize(self)
  self._string = ''
end

function Concat:_write(data, encoding, callback)
  self._string = self._string .. data
  callback()
end

function Concat:string(callback)
  self:on('finish', function()
    callback(self._string)
  end)
end

local exports = {}

exports.Concat = Concat

return exports
