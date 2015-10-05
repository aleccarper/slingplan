require 'colorize'

def heroku_run_clean(&block)
  Bundler.with_clean_env &block
end

def build_shell_command(cmd)
  "echo '#{cmd} rescue exit' | heroku run rails c --app slingplan-production"
end

# creation
def initialize_beta_tester
  cmd = "BetaTester.new(email: \"#{ENV['EMAIL']}\", password: \"#{ENV['PASSWORD']}\")"
  [cmd, "#{cmd}.save", eval(cmd)]
end

def create_beta_tester(cmd)
  puts "\nSaving BetaTester on Heroku:\n".colorize(:green)
  shell_command = build_shell_command(cmd)
  puts system(shell_command).split("\n").map { |l| "\t#{l}\n" }.join.colorize(:light_black)
end

def show_beta_tester_errors(beta_tester)
  puts "\nError adding BetaTester:\n".colorize(:light_red)
  errors = beta_tester.errors.full_messages
  puts errors.map { |e| "\t#{e}" }.join("\n") + "\n\n"
end



# listing
def show_existing
  puts "\nGetting BetaTesters from Heroku:\n".colorize(:green)
  cmd = "BetaTester.all.map(&:email)"
  shell_command = build_shell_command(cmd)
  puts system(shell_command)
end



namespace :beta do

  desc 'Validate BetaTester locally and create on heroku if valid'
  task :add, [:email, :password] => :environment do
    heroku_run_clean do
      cmd_new, cmd_create, beta_tester = initialize_beta_tester
      if beta_tester.valid?
        create_beta_tester cmd_create
      else
        show_beta_tester_errors beta_tester
      end
    end
  end

  desc 'Show all beta testers on production'
  task :list => :environment do
    heroku_run_clean do
      show_existing
    end
  end

end

task beta: 'beta:list'
