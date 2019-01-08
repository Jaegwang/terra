assert( int8 :min() == -2LL ^ 7)
assert( int8 :max() ==  2LL ^ 7 - 1)
assert( int16:min() == -2LL ^ 15)
assert( int16:max() ==  2LL ^ 15 - 1)
assert( int32:min() == -2LL ^ 31)
assert( int32:max() ==  2LL ^ 31 - 1)
assert( int64:min() == -2LL ^ 63)
assert( int64:max() ==  2LL ^ 63 - 1)
assert(uint8 :min() ==  0)
assert(uint8 :max() ==  0xFF)
assert(uint16:min() ==  0)
assert(uint16:max() ==  0xFFFF)
assert(uint32:min() ==  0)
assert(uint32:max() ==  0xFFFFFFFF)
assert(uint64:min() ==  0)
assert(uint64:max() ==  0xFFFFFFFFFFFFFFFFULL)

assert(float:min() ==  terralib.cast(float, -math.huge))
assert(float:max() ==  terralib.cast(float, math.huge))
assert(double:min() ==  terralib.cast(double, -math.huge))
assert(double:max() ==  terralib.cast(double, math.huge))

local c = terralib.includec("stdio.h")
c.printf("%hd %hd %d %d %ld %ld\n", int16:min(), int16:max(), int32:min(), int32:max(), int64:min(), int64:max())
c.printf("%hu %hu %u %u %lu %lu\n", uint16:min(), uint16:max(), uint32:min(), uint32:max(), uint64:min(), uint64:max())
c.printf("%f %f %lf %lf\n", float:min(), float:max(), double:min(), double:max())