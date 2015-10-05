
namespace :plans do

  desc 'Calculate plans based on tier 1 monthly'
  task :calculate, [:base, :steps] => :environment do |t, args|
    base = args[:base].to_i
    steps = args[:steps].split('-').map(&:strip).map(&:to_i)

    puts "Tier\t\tMonthly\tYearly"
    steps.to_a.each.with_index do |n, i|
      monthly = base * n - (base * i)
      monthly_result = '%.2f' % ((monthly.to_f) - 0.01)
      yearly_result = '%.2f' % (((monthly * 12) - (monthly).to_f) - 0.01)
      puts "Tier #{i+1}: \t#{monthly_result}\t#{yearly_result}"
    end
  end
end
