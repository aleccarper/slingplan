require 'rubhub'
require 'colorize'

pwd = `pwd`
@repo = pwd[pwd.rindex('/')+1..-1].strip
@owner = 'CriticalMech'

def init
  @gh = Github.new(ENV['GITHUB_USERNAME'], ENV['GITHUB_PASSWORD'])
  fetch
  puts
end

def fetch
  results = []
  page = 1
  while(true)
    p = @gh.issues.listRepoIssues(@repo, user: @owner, state: 'open', per_page: 100, page: page)
    if p.count == 0
      break
    else
      page += 1
      results << p
    end
  end
  @open = results.flatten

  page = 1
  results = []
  while(true)
    p = @gh.issues.listRepoIssues(@repo, user: @owner, state: 'closed', per_page: 100, page: page)
    if p.count == 0
      break
    else
      page += 1
      results << p
    end
  end
  @closed = results.flatten
end

def puts_header
  puts "  ID\tTitle"
  puts '-' * 60
end

def list_issues
  if @open.blank?
    return no_issues
  end
  puts_header
  @open.each do |issue|
    puts "  %s\t%s" % [issue['number'], issue['title'].colorize(:light_black)]
  end
end

def no_issues
  puts 'There are no open issues!'.colorize(:light_green)
end

def stats
  open = "#{@open.count.to_s.colorize(:light_red)} open"
  closed = "#{@closed.count.to_s.colorize(:light_green)} closed"
  puts "  %s / %s" % [open, closed]
end

def close_issue(ids)
  puts_header
  ids.each do |id|
    issue = JSON.parse(@gh.issues.editIssue(@repo, id, user: @owner, state: 'closed'))
    unless (n = issue['number']).nil?
      puts "%s%s\t%s" % [
        '- '.colorize(:light_red),
        issue['number'].to_s.colorize(:red),
        issue['title'].colorize(:light_black)
      ]
    end
  end
end

def create_issue(titles)
  puts_header
  titles.each do |title|
    issue = JSON.parse(@gh.issues.createIssue(@repo, title, user: @owner))
    unless (n = issue['number']).nil?
      puts "%s%s\t%s" % [
        '+ '.colorize(:light_green),
        issue['number'].to_s.colorize(:green),
        issue['title'].colorize(:light_black)
      ]
    end
  end
end



namespace :issues do

  desc 'create issue'
  task :create, [:title] => :environment do |t, args|
    init
    create_issue(args.to_a)
    fetch
    puts
    stats
    puts
  end

  desc 'close issue'
  task :close, [:id] => :environment do |t, args|
    init
    close_issue(args.to_a)
    fetch
    puts
    stats
    puts
  end

  desc 'list open issues'
  task :list => :environment do
    init
    list_issues
    puts
    stats
    puts
  end

  task :default => ['issues:list']
end

task :issues do
  Rake::Task["issues:list"].invoke
end
