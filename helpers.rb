def sanitize_string(string)
  return string.gsub(/[ <>.]/, "_")
end

