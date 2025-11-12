module ServiceSignature
  Result = Struct.new(:success, :data, :errors) do
    def success?
      success
    end
  end

  def returns(success: true, data: nil, errors: nil)
    Result.new(success, data, errors)
  end
end
