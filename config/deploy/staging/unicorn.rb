##################################
##### SET THESE VARIABLES ########
##################################
root = "/home/lgbt-timeline-staging/LGBT-Timeline-Staging/current" # path to application current folder
sock_name = "unicorn_LGBT-Timeline-Staging" # must be unique name with no '.'
port_num = 8150 # must be a unique port number for this application
tout = 60 # time in seconds before process dies - need a long time for data uploads
##################################

working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/#{sock_name}.sock"
listen port_num, :tcp_nopush => true
worker_processes 1
timeout tout
