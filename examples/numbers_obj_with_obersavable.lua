local stream = require('..')
local fs = require('fs')
local core = require('core')

local numberReader = stream.Readable:extend()

function numberReader:initialize(count, options)
  local opt = options or {}
  opt.objectMode = true
  stream.Readable.initialize(self, opt)
  self.current = 1
  self.count = count
end

function numberReader:_read()
  if self.current > self.count then
    self:push(nil)
    return
  else
    self:push({num = self.current})
    self.current = self.current + 1
  end
end


local numberIncreaser = stream.Transform:extend()

function numberIncreaser:initialize(options)
  local opt = options or {}
  opt.objectMode = true
  stream.Transform.initialize(self, opt)
end

function numberIncreaser:_transform(data, encoding, callback)
  callback(nil, {num = data.num + 1})
end


local stdoutWriter = stream.Writable:extend()

function stdoutWriter:initialize(options)
  local opt = options or {}
  opt.objectMode = true
  stream.Writable.initialize(self, opt)
end

function stdoutWriter:_write(data, encoding, callback)
  print(data.num)
  callback()
end

local observer = stream.Observable:new({objectMode = true})

local outsider = observer:observe()

numberReader:new(9):pipe(observer):pipe(numberIncreaser:new()):pipe(stdoutWriter:new())

outsider:pipe(stdoutWriter:new())
