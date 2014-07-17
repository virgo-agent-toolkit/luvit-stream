local stream = require('..')
local fs = require('fs')
local core = require('core')

local Numbers = stream.Readable:extend()

function Numbers:initialize(count, options)
  local opt = options or {}
  opt.objectMode = true
  stream.Readable.initialize(self, opt)
  self.current = 1
  self.count = count
end

function Numbers:_read()
  if self.current > self.count then
    self:push(nil)
    return
  else
    self:push({num = self.current})
    self.current = self.current + 1
  end
end


local NumberIncreaser = stream.Transform:extend()

function NumberIncreaser:initialize(options)
  local opt = options or {}
  opt.objectMode = true
  stream.Transform.initialize(self, opt)
end

function NumberIncreaser:_transform(data, encoding, callback)
  callback(nil, {num = data.num + 1})
end


local Stringify = stream.Transform:extend()

function Stringify:initialize(options)
  local opt = options or {}
  opt.objectMode = true
  stream.Transform.initialize(self, opt)
end

function Stringify:_transform(data, encoding, callback)
  if data and data.num then
    callback(nil, tostring(data.num))
  end
end

Numbers:new(9):pipe(NumberIncreaser:new()):pipe(Stringify:new()):pipe(process.stdout)
