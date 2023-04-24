local keys = tonumber(ARGV[1])
local value_size = tonumber(ARGV[2])

for i = 1, keys do
  local key = "key-" .. i
  local value = string.rep("a", value_size)
  redis.call("SET", key, value)
end
