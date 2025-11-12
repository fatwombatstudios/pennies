class EntryService
  include ServiceSignature

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def update(params)
    entry.assign_attributes params

    if entry.save
      returns data: entry
    else
      returns success: false, data: entry, errors: entry.errors
    end
  end
end
