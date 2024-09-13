require 'json'
require 'time'

class WorkingOn
  DATA_FILE = File.join(Dir.home, '.working_on.json')

  def self.run(args)
    instance = new
    if args.empty?
      puts "Usage: working_on <project> or working_on --logoff or working_on --note <note> or working_on --projects"
    elsif args[0] == '--logoff'
      instance.log_off
    elsif args[0] == '--projects'
      instance.list_projects
    elsif args[0] == '--note' && args.size > 1
      instance.add_note(args[1..-1].join(' '))
    else
      instance.start_project(args[0])
    end
  end

  def initialize
    @data = load_data
  end

  def list_projects
    projects = @data['projects'] || {}
    puts "Projects: #{projects.keys.join(', ')}"
  end

  def start_project(project)
    current_time = Time.now.to_i
    log_previous_project(current_time)
    @data['current_project'] = project
    @data['last_start_time'] = current_time
    @data['session'] = current_time.to_s
    initialize_project
    save_data
    puts "Now working on: #{project}"
  end

  def log_off
    current_time = Time.now.to_i
    log_previous_project(current_time)
    @data['current_project'] = nil
    @data['last_start_time'] = nil
    save_data
    puts "Logged off. Have a great day!"
  end

  def add_note(note)
    if @data['current_project']
      initialize_project

      session = @data['session']

      @data['projects'][@data['current_project']]['sessions'][session]['notes'] << {
        'timestamp' => Time.now.to_i,
        'content' => note
      }

      save_data
      puts "Note added to project: #{@data['current_project']}"
    else
      puts "Error: No project currently active. Start a project first."
    end
  end

  private

  def initialize_project
    project = @data['current_project']
    session = @data['session']
    start_time = @data['last_start_time']

    @data['projects'] ||= {}
    @data['projects'][project] ||= { 'sessions' => {} }
    @data['projects'][project]['sessions'][session] ||= { 'start_time' => start_time, 'notes' => [] }
  end

  def log_previous_project(end_time)
    if @data['current_project']
      session = @data['session']
      project = @data['current_project']
      start_time = @data['last_start_time']

      initialize_project

      @data['projects'][project]['sessions'][session]['end_time'] = end_time
      @data['projects'][project]['sessions'][session]['duration'] = end_time
      @data['projects'][project]['sessions'][session]['formatted'] = {
        start_time: Time.at(start_time).to_s,
        end_time: Time.at(end_time).to_s,
      }

      duration = (end_time - start_time) / 3600.0  # Convert to hours for display
      puts "Logged #{duration.round(2)} hours for project: #{project}"
    end
  end

  def load_data
    File.exist?(DATA_FILE) ? JSON.parse(File.read(DATA_FILE)) : {}
  end

  def save_data
    File.write(DATA_FILE, JSON.pretty_generate(@data))
  end

  def calculate_total_time(project)
    return 0 unless @data['projects'] && @data['projects'][project]

    @data['projects'][project]['time_intervals'].sum do |start_time, end_time|
      end_time - start_time
    end
  end
end

