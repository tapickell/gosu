if ENV['USER'] == 'jlnr' and `uname`.chomp == 'Darwin' then
  BASENAME = 'To Do.md'
  
  require 'appscript'
  
  desc "Publish OmniFocus tasks on ToDo wiki page"
  task :todo do
    Dir.chdir('../Gosu Wiki') do
      sh 'git pull >/dev/null'
    
      File.open "../Gosu Wiki/#{BASENAME}", "w" do |wiki_page|
        doc = Appscript.app("OmniFocus").default_document
        my_projects = doc.folders["Solo Game-Dev"].projects.get
        gosu_projects = my_projects.select { |p| p.name.get =~ /^Gosu/ }
      
        wiki_page.puts "# To Do list"
        wiki_page.puts
        wiki_page.puts "This list of tasks is exported automatically from my OmniFocus projects."
        wiki_page.puts "(Last update: #{Date.today})"
        wiki_page.puts
      
        $shown_tasks = []
      
        def wiki_page.list_tasks_in root, indent = 2
          root.tasks.get.each do |task|
            next if $shown_tasks.include? task or task.completed.get
            $shown_tasks << task
            puts "#{' ' * indent}* #{task.name.get.gsub('_', '\_')}"
            list_tasks_in task, indent + 2 unless task.tasks.get.empty?
          end
        end  
      
        gosu_projects.each do |project|
          wiki_page.puts "\n## #{project.name.get}"
          wiki_page.list_tasks_in project
        end
      end
    
      diff = `git diff -U0 '#{BASENAME}'`
      if diff.chomp.empty? or (diff.count("\n") == 7 and diff =~ /Last update/) then
        puts "Only date has changed; ignoring"
        sh "git checkout '#{BASENAME}'"
      else
        sh "git commit -am 'To Do list refresh' && git push"
      end
    end
  end
end
