@dir = "/root/kotori"
worker_processes 2
working_directory @dir
preload_app true
timeout 30
listen "#{@dir}/tmp/kotori.sock", :backlog => 64
pid "#{@dir}/tmp/pids/unicorn.pid"
stderr_path "#{@dir}/log/unicorn.stderr.log"
stdout_path "#{@dir}/log/unicorn.stdout.log"