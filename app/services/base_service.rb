class BaseService
  attr_reader :result, :errors

  def initialize(**args)
    @errors = []
  end

  def call
    raise NotImplementedError
  end

  def success?
    @errors.empty?
  end
end
