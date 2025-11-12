class EntryService
  Result = Struct.new(:success, :entry, :errors) do
    def success?
      success
    end
  end

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def update(params)
    entry.assign_attributes(params)

    if entry.save
      Result.new(true, entry, nil)
    else
      Result.new(false, entry, entry.errors)
    end
  end
end
