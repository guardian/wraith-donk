class WraithRunner

  def initialize(config_name)
    @config = (config_name)
    @directory = "/public/#{config_name}"
  end

  def directory
    @directory
  end

  def run_wraith
    start = Wraith::CLI.new
    start.capture(@config)
  end

  def has_differences
    Dir.glob("#{directory}/*/*.txt") do |fn|
      data = File.open(fn, 'rb') { |io| io.read }
      @diff = 0 + data.to_i
    end

    unless @diff.is_a?(Numeric)
	    return true
    end
    @diff > 0
  end
end
