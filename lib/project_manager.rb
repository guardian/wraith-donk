class ProjectManager
  def projects
    configs = []
    Dir.glob('public/history/*') do |fn|
      project = fn.gsub('public/history/', '')
      builds = BuildHistory.new project
      last_build = builds.history.last

      configs.push({:project => project, :last_build => last_build})
    end
    configs
  end
end
