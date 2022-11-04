class DateTime
  def as_json(options = nil)
    iso8601(3)
  end
end
