local stream = require('..')

local Numbers = stream.Readable:extend()

function Numbers:initialize(count, options)
  local opt = options or {}
  stream.Readable.initialize(self, opt)
  self.current = 1
  self.count = count
end

function Numbers:_read()
  if self.current > self.count then
    self:push(nil)
    return
  else
    self:push(tostring(self.current))
    self.current = self.current + 1
  end
end

local concat = stream.Concat:new()
concat:string(function(data)
  print(data)
end)

Numbers:new(9):pipe(concat)
