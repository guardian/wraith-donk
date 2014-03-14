class BuildHistory
  def initialize(config)
    @build_history_file = "#{config}.builds.json";
    @config = config
    @history = nil;
  end

  def history
    unless File.exists? @build_history_file
      File.open(@build_history_file, 'w') { |file| file.write('{"builds":[]}') }
    end
    if @history.nil?
      @history = JSON.parse(File.read(@build_history_file))
    end
    @history['builds']
  end

  def add(label)
    history.push(label)
    save
  end

  def save
    File.open(@build_history_file, 'w') { |file| file.write(@history.to_json) }
  end

  def cleanup
    if history.length > 10
      (history.length-10).times {
        FileUtils.rm_rf "public/history/#{@config}/#{history[0]}"
        history.shift
      }
    end
    save
  end


end
