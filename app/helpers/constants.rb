module Size
  MAX_SIZE = 400
  MAX_WIDTH = 1024
  MAX_HEIGHT = 1024
end

module Jpeg_endings
  SHORT = '.jpg'
  SHORT_UPPER = '.JPG'
  FULL = '.jpeg'
  FULL_UPPER = '.JPEG'
  MAPPING = [SHORT[1..3], SHORT_UPPER[1..3], FULL[1..4], FULL_UPPER[1..4]]
  MAPPING_DOT = [SHORT, SHORT_UPPER, FULL, FULL_UPPER]
end