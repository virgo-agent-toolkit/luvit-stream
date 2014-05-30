local stream = require('..')

local numberReader = stream.Readable:extend()

function numberReader:initialize(count, options)
  local opt = options or {}
  stream.Readable.initialize(self, opt)
  self.current = 1
  self.count = count
end

function numberReader:_read()
  if self.current > self.count then
    self:push(nil)
    return
  else
    self:push(tostring(self.current))
    self.current = self.current + 1
  end
end

numberReader:new(9):pipe(process.stdout)
