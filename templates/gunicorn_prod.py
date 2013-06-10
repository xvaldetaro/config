import multiprocessing

bind = "127.0.0.1:<app_port>"
workers = multiprocessing.cpu_count() * 2 + 1
user = "<user>"
loglevel = "info"
accesslog = "<log_dir>/g_access.log"
errorlog = "<log_dir>/g_error.log"
proc_name = "gunicorn_<proj_name>"