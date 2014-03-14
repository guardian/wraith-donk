class BuildQueue

  def initialize
    @filename = 'build_queue.json'
    @queue=nil
  end

  def queue
    unless File.exists? @filename
      File.open(@filename, 'w') { |file| file.write('{"queue":[]}') }
    end
    if @queue.nil?
      @queue = JSON.parse(File.read(@filename))
    end
    @queue['queue']
  end

  def add(config, build_label)
    queue.push({:config => config, :label => build_label})
    save
  end

  def length
    queue.length
  end

  def next
    x = queue.first
    queue.pop
    return x['config'], x['label']
  end

  def empty?
    queue.empty?
  end

  def save
    File.open(@filename, 'w') { |file| file.write(@queue.to_json) }
  end

end
