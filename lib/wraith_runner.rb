class WraithRunner
  attr_reader :directory

  def initialize(config_name, build_number)
    @config = (config_name)
    @original_directory = "public/#{config_name}"
    @directory = "public/history/#{config_name}/#{build_number}"
  end

  def run_wraith
    start = Wraith::CLI.new
    start.capture(@config)
    FileUtils.rm_rf @directory
    FileUtils.mkdir_p @directory
    FileUtils.mv Dir.glob("#{@original_directory}/*"), @directory, :force => true
  end

  def has_differences?
    Dir.glob("#{@directory}/*/*.txt") do |fn|
      data = File.open(fn, 'rb') { |io| io.read }
      @diff = 0 + data.to_i
    end

    unless @diff.is_a?(Numeric)
      return true
    end
    @diff > 0
  end
end
